import 'dotenv/config';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

const dataPath = fileURLToPath(
  new URL('./data/benin-localities.json', import.meta.url),
);
const catalog = JSON.parse(await readFile(dataPath, 'utf8'));
const levels = ['DEPARTMENT', 'COMMUNE', 'ARRONDISSEMENT', 'NEIGHBORHOOD'];
const nodes = catalog.nodes;

if (!Array.isArray(nodes) || nodes.length === 0) {
  throw new Error('Le catalogue de localités est vide ou invalide.');
}

const nodeByKey = new Map(nodes.map((node) => [node.key, node]));
for (const node of nodes) {
  if (node.parentKey !== null && !nodeByKey.has(node.parentKey)) {
    throw new Error(`Parent absent pour la localité ${node.key}`);
  }
}

if (process.argv.includes('--dry-run')) {
  console.log(
    JSON.stringify({
      source: catalog.source,
      license: catalog.license,
      counts: catalog.counts,
      localitiesWithoutVerifiedArrondissement:
        catalog.localitiesWithoutVerifiedArrondissement,
      dryRun: true,
    }),
  );
  process.exit(0);
}

const connectionString =
  process.env.DIRECT_URL?.trim() || process.env.DATABASE_URL?.trim();
if (!connectionString) {
  throw new Error('DIRECT_URL ou DATABASE_URL doit être configurée.');
}

const [{ PrismaPg }, { PrismaClient }] = await Promise.all([
  import('@prisma/adapter-pg'),
  import('../dist/generated/prisma/client.js'),
]);
const prisma = new PrismaClient({ adapter: new PrismaPg(connectionString) });
const idByKey = new Map();
const insertedByLevel = {};
const batchSize = 500;

if (process.argv.includes('--check')) {
  try {
    const current = await prisma.location.groupBy({
      by: ['level'],
      _count: { _all: true },
    });
    console.log(
      JSON.stringify({
        databaseCheck: true,
        locationsByLevel: Object.fromEntries(
          current.map((group) => [group.level, group._count._all]),
        ),
      }),
    );
  } finally {
    await prisma.$disconnect();
  }
  process.exit(0);
}

try {
  for (const level of levels) {
    const levelNodes = nodes.filter((node) => node.level === level);
    const rows = levelNodes.map((node) => {
      const parentId = node.parentKey === null ? null : idByKey.get(node.parentKey);
      if (node.parentKey !== null && !parentId) {
        throw new Error(`Parent non chargé pour ${node.key}`);
      }
      return {
        name: node.name,
        slug: node.slug,
        level,
        parentId,
      };
    });

    let inserted = 0;
    for (let offset = 0; offset < rows.length; offset += batchSize) {
      const result = await prisma.location.createMany({
        data: rows.slice(offset, offset + batchSize),
        skipDuplicates: true,
      });
      inserted += result.count;
    }

    const persisted = await prisma.location.findMany({
      where: { level },
      select: { id: true, name: true, slug: true, parentId: true },
    });
    const idByParentAndSlug = new Map(
      persisted.map((row) => [`${row.parentId ?? ''}\0${row.slug}`, row]),
    );

    for (const node of levelNodes) {
      const parentId = node.parentKey === null ? null : idByKey.get(node.parentKey);
      const row = idByParentAndSlug.get(`${parentId ?? ''}\0${node.slug}`);
      if (!row) throw new Error(`Localité absente après import : ${node.key}`);
      if (row.name !== node.name) {
        throw new Error(
          `Nom déjà présent avec une autre écriture pour ${node.key}; aucune donnée n’a été remplacée.`,
        );
      }
      idByKey.set(node.key, row.id);
    }

    insertedByLevel[level] = inserted;
  }

  console.log(
    JSON.stringify({
      source: catalog.source,
      counts: catalog.counts,
      insertedByLevel,
      totalInserted: Object.values(insertedByLevel).reduce(
        (total, count) => total + count,
        0,
      ),
      localitiesWithoutVerifiedArrondissement:
        catalog.localitiesWithoutVerifiedArrondissement,
    }),
  );
} finally {
  await prisma.$disconnect();
}
