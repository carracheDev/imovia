import { createHash, randomBytes, randomUUID } from 'node:crypto';
import { Test, TestingModule } from '@nestjs/testing';
import { ValidationPipe } from '@nestjs/common';
import type { INestApplication } from '@nestjs/common';
import request from 'supertest';
import type { App } from 'supertest/types';
import { UserRole, LocationLevel } from '../src/generated/prisma/enums.js';
import { AppModule } from '../src/app.module.js';
import { PrismaService } from '../src/prisma/prisma.service.js';
import { ObjectStorageService } from '../src/storage/object-storage.service.js';

describe('Property lifecycle with local services', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  let storage: ObjectStorageService;
  const runId = randomUUID();

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(
      new ValidationPipe({
        transform: true,
        whitelist: true,
        forbidNonWhitelisted: true,
      }),
    );
    prisma = moduleFixture.get(PrismaService);
    storage = moduleFixture.get(ObjectStorageService);
    await app.init();
  }, 30_000);

  afterAll(async () => {
    if (app) await app.close();
  });

  it('rejects unauthenticated draft creation and leaves no property behind', async () => {
    const owner = await createUser('owner');
    try {
      await request(app.getHttpServer())
        .post('/api/properties')
        .send(propertyInput())
        .expect(401);

      expect(
        await prisma.property.count({
          where: { advertiserUserId: owner.id, title: propertyInput().title },
        }),
      ).toBe(0);
    } finally {
      await removeFixture(owner.id);
    }
  });

  it('creates a draft, uploads its photo, and persists the submission', async () => {
    const owner = await createUser('submission-owner');
    const location = await createLocation();

    try {
      const { propertyId, mediaId } = await createAndSubmitProperty(
        owner.token,
        location.id,
        'Soumission vérifiée',
      );

      const persisted = await prisma.property.findUniqueOrThrow({
        where: { id: propertyId },
        include: {
          media: true,
          authorizations: true,
          statusHistory: { orderBy: { createdAt: 'asc' } },
        },
      });
      expect(persisted.publicationStatus).toBe('SUBMITTED');
      expect(persisted.media).toMatchObject([
        { id: mediaId, uploadStatus: 'READY', isCover: true },
      ]);
      expect(persisted.authorizations).toHaveLength(1);
      expect(persisted.statusHistory.map(({ status }) => status)).toEqual([
        'DRAFT',
        'SUBMITTED',
      ]);
    } finally {
      await removeFixture(owner.id);
      await prisma.location.deleteMany({ where: { id: location.id } });
    }
  }, 30_000);

  it('moderates a submitted property and serves its approved photo publicly', async () => {
    const owner = await createUser('publication-owner');
    const moderator = await createUser('moderator', [
      UserRole.MODERATOR,
      UserRole.ADMIN,
    ]);
    const location = await createLocation();

    try {
      const { propertyId, mediaId, slug } = await createAndSubmitProperty(
        owner.token,
        location.id,
        'Publication vérifiée',
      );

      await request(app.getHttpServer())
        .post(`/api/admin/properties/${propertyId}/start-review`)
        .set('Authorization', `Bearer ${moderator.token}`)
        .expect(201);
      await request(app.getHttpServer())
        .post(`/api/admin/properties/${propertyId}/media/${mediaId}/approve`)
        .set('Authorization', `Bearer ${moderator.token}`)
        .expect(201)
        .expect({ id: mediaId, isApproved: true });
      await request(app.getHttpServer())
        .post(`/api/admin/properties/${propertyId}/approve`)
        .set('Authorization', `Bearer ${moderator.token}`)
        .expect(201);

      const publicProperty = await request(app.getHttpServer())
        .get(`/api/properties/${slug}`)
        .expect(200);
      expect(publicProperty.body).toMatchObject({
        id: propertyId,
        media: [{ id: mediaId }],
      });

      const publicMedia = await request(app.getHttpServer())
        .get(`/api/properties/${slug}/media/${mediaId}`)
        .expect(200);
      expect(publicMedia.body.url).toMatch(/^http/);

      const persisted = await prisma.property.findUniqueOrThrow({
        where: { id: propertyId },
        select: {
          publicationStatus: true,
          media: { select: { isApproved: true } },
        },
      });
      expect(persisted).toEqual({
        publicationStatus: 'PUBLISHED',
        media: [{ isApproved: true }],
      });
    } finally {
      await removeFixture(owner.id);
      await prisma.session.deleteMany({ where: { userId: moderator.id } });
      await prisma.user.deleteMany({ where: { id: moderator.id } });
      await prisma.location.deleteMany({ where: { id: location.id } });
    }
  }, 30_000);

  async function createUser(
    label: string,
    roles: UserRole[] = [UserRole.OWNER],
  ) {
    const user = await prisma.user.create({
      data: {
        email: `${label}-${runId}@caranova.test`,
        firstName: 'Test',
        lastName: label,
        roles,
      },
    });
    const token = randomBytes(32).toString('base64url');
    await prisma.session.create({
      data: {
        userId: user.id,
        tokenHash: createHash('sha256').update(token).digest('hex'),
        expiresAt: new Date(Date.now() + 60_000),
      },
    });
    return { id: user.id, token };
  }

  async function createLocation() {
    return prisma.location.create({
      data: {
        name: `Runtime ${runId.slice(0, 8)}`,
        slug: `runtime-${runId.slice(0, 8)}`,
        level: LocationLevel.NEIGHBORHOOD,
      },
    });
  }

  function propertyInput(title = 'Parcours annonceur CARANOVA') {
    return {
      title: `${title} ${runId.slice(0, 8)}`,
      description:
        'Maison lumineuse avec jardin, proche des commodités et des transports.',
      category: 'HOUSE',
      operationType: 'RENT',
      price: '150000',
    };
  }

  async function createAndSubmitProperty(
    token: string,
    locationId: string,
    title: string,
  ) {
    const created = await request(app.getHttpServer())
      .post('/api/properties')
      .set('Authorization', `Bearer ${token}`)
      .send({ ...propertyInput(title), locationId })
      .expect(201);
    const { id: propertyId, slug } = created.body as {
      id: string;
      slug: string;
    };

    const upload = await request(app.getHttpServer())
      .post(`/api/properties/me/${propertyId}/media/upload-url`)
      .set('Authorization', `Bearer ${token}`)
      .send({ contentType: 'image/png' })
      .expect(201);
    const form = new FormData();
    for (const [key, value] of Object.entries(upload.body.fields)) {
      form.append(key, String(value));
    }
    form.append(
      'file',
      new Blob(
        [
          Buffer.from(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/r3cAAAAASUVORK5CYII=',
            'base64',
          ),
        ],
        { type: 'image/png' },
      ),
      'runtime.png',
    );
    const s3Upload = await fetch(upload.body.uploadUrl as string, {
      method: 'POST',
      body: form,
    });
    expect(s3Upload.ok).toBe(true);

    const mediaId = upload.body.mediaId as string;
    await request(app.getHttpServer())
      .post(`/api/properties/me/${propertyId}/media/${mediaId}/complete`)
      .set('Authorization', `Bearer ${token}`)
      .expect(201)
      .expect({ id: mediaId, uploadStatus: 'READY' });
    await request(app.getHttpServer())
      .post(`/api/properties/me/${propertyId}/submit`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        authorizationConfirmed: true,
        authorizationType: 'OWNER',
        authorizationTermsVersion:
          process.env.PROPERTY_AUTHORIZATION_TERMS_VERSION ?? '1.0',
      })
      .expect(201);

    return { propertyId, mediaId, slug };
  }

  async function removeFixture(userId: string) {
    const properties = await prisma.property.findMany({
      where: { advertiserUserId: userId },
      select: {
        id: true,
        media: { select: { storageKey: true } },
      },
    });
    for (const property of properties) {
      for (const media of property.media) {
        await storage.deleteImage(media.storageKey);
      }
      await prisma.propertyAuthorization.deleteMany({
        where: { propertyId: property.id },
      });
      await prisma.propertyStatusHistory.deleteMany({
        where: { propertyId: property.id },
      });
      await prisma.propertyMedia.deleteMany({
        where: { propertyId: property.id },
      });
    }
    await prisma.property.deleteMany({ where: { advertiserUserId: userId } });
    await prisma.session.deleteMany({ where: { userId } });
    await prisma.user.deleteMany({ where: { id: userId } });
  }
});
