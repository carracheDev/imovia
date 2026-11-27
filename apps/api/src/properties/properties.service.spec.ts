import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, ForbiddenException } from '@nestjs/common';
import {
  UserRole,
  PropertyPublicationStatus,
} from '../generated/prisma/enums.js';
import type { AuthenticatedUser } from '../auth/authenticated-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { ObjectStorageService } from '../storage/object-storage.service.js';
import { PlacesService } from '../places/places.service.js';
import { PropertiesService } from './properties.service.js';

describe('PropertiesService media uploads', () => {
  let service: PropertiesService;
  const transaction = {
    property: {
      findUnique: vi.fn(),
    },
    propertyMedia: {
      count: vi.fn(),
    },
  };
  const prisma = {
    $queryRaw: vi.fn(),
    $transaction: vi.fn(
      (callback: (client: typeof transaction) => Promise<unknown>) =>
        callback(transaction),
    ),
    property: {
      findMany: vi.fn(),
      findUnique: vi.fn(),
      count: vi.fn(),
    },
    propertyMedia: {
      count: vi.fn(),
      create: vi.fn(),
    },
    propertyAssignment: {
      findFirst: vi.fn().mockResolvedValue(null),
    },
    location: {
      findMany: vi.fn(),
    },
  };
  const storage = {
    createImageUpload: vi.fn(),
  };
  const places = {
    getDetails: vi.fn(),
  };
  const user: AuthenticatedUser = {
    id: 'advertiser-id',
    email: 'owner@example.test',
    firstName: 'Ada',
    lastName: 'Lovelace',
    roles: [UserRole.OWNER],
    sessionId: 'session-id',
    accountStatus: 'SUSPENDED'
  };

  beforeEach(async () => {
    vi.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PropertiesService,
        { provide: PrismaService, useValue: prisma },
        { provide: ObjectStorageService, useValue: storage },
        { provide: PlacesService, useValue: places },
      ],
    }).compile();
    service = module.get(PropertiesService);
  });

  it('searches locations and returns their administrative path', async () => {
    prisma.location.findMany.mockResolvedValue([
      {
        id: 'neighborhood-id',
        name: 'Cotonou-centre',
        slug: 'cotonou-centre',
        level: 'NEIGHBORHOOD',
        parentId: 'arrondissement-id',
        parent: {
          name: '1er arrondissement',
          level: 'ARRONDISSEMENT',
          parent: {
            name: 'Cotonou',
            level: 'COMMUNE',
            parent: { name: 'Littoral', level: 'DEPARTMENT', parent: null },
          },
        },
      },
      {
        id: 'commune-id',
        name: 'Cotonou',
        slug: 'cotonou',
        level: 'COMMUNE',
        parentId: 'department-id',
        parent: {
          name: 'Littoral',
          level: 'DEPARTMENT',
          parent: null,
        },
      },
    ]);

    const results = await service.searchLocations(' Cotonou ');

    expect(prisma.location.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { name: { contains: 'Cotonou', mode: 'insensitive' } },
        take: 100,
      }),
    );
    expect(results[0]).toMatchObject({
      id: 'commune-id',
      name: 'Cotonou',
      path: 'Littoral · Cotonou',
    });
    expect(results[1]).toMatchObject({
      id: 'neighborhood-id',
      path: 'Littoral · Cotonou · 1er arrondissement · Cotonou-centre',
    });
  });

  it('accepts one-character location prefixes and rejects an empty query', async () => {
    prisma.location.findMany.mockResolvedValue([]);
    await expect(service.searchLocations(' Z ')).resolves.toEqual([]);
    await expect(service.searchLocations(' ')).rejects.toBeInstanceOf(
      BadRequestException,
    );
    expect(prisma.location.findMany).toHaveBeenCalledTimes(1);
  });

  it('combines public eligibility with title and location search', async () => {
    prisma.property.findMany.mockResolvedValue([]);
    prisma.property.count.mockResolvedValue(0);

    await service.listPublic({ q: 'Cotonou', page: 1, pageSize: 1 });

    const where = prisma.property.findMany.mock.calls[0][0]?.where;
    expect(where).toMatchObject({
      publicationStatus: PropertyPublicationStatus.PUBLISHED,
      availability: 'AVAILABLE',
      AND: [
        expect.objectContaining({
          advertiser: { is: { accountStatus: 'ACTIVE' } },
        }),
        {
          OR: [
            { title: { contains: 'Cotonou', mode: 'insensitive' } },
            {
              location: {
                is: {
                  name: { contains: 'Cotonou', mode: 'insensitive' },
                },
              },
            },
          ],
        },
      ],
    });
    expect(prisma.property.count).toHaveBeenCalledWith({ where });
  });

  it("does not let an advertiser upload media to another user's property", async () => {
    prisma.property.findUnique.mockResolvedValue({
      advertiserUserId: 'another-user',
      publicationStatus: PropertyPublicationStatus.DRAFT,
    });

    await expect(
      service.createMediaUpload(user, 'property-id', {
        contentType: 'image/jpeg',
      }),
    ).rejects.toBeInstanceOf(ForbiddenException);
    expect(storage.createImageUpload).not.toHaveBeenCalled();
    expect(prisma.propertyMedia.create).not.toHaveBeenCalled();
  });

  it('creates a private upload form and marks the first completed photo as cover', async () => {
    prisma.property.findUnique.mockResolvedValue({
      advertiserUserId: user.id,
      ownerUserId: null,
      publicationStatus: PropertyPublicationStatus.DRAFT,
    });
    prisma.propertyMedia.count.mockResolvedValue(0);
    prisma.propertyMedia.create.mockResolvedValue({ id: 'media-id' });
    storage.createImageUpload.mockResolvedValue({
      url: 'https://storage.example.test/upload',
      fields: { key: 'properties/property-id/image.jpeg' },
    });

    const result = await service.createMediaUpload(user, 'property-id', {
      contentType: 'image/jpeg',
    });

    expect(result).toMatchObject({
      mediaId: 'media-id',
      uploadUrl: 'https://storage.example.test/upload',
      maxSizeBytes: 5 * 1024 * 1024,
    });
    expect(prisma.propertyMedia.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          propertyId: 'property-id',
          mediaType: 'PHOTO',
          contentType: 'image/jpeg',
          position: 0,
          isCover: true,
        }),
      }),
    );
  });

  it('does not allow pending uploads to satisfy the photo requirement for submission', async () => {
    transaction.property.findUnique.mockResolvedValue({
      advertiserUserId: user.id,
      ownerUserId: null,
      publicationStatus: PropertyPublicationStatus.DRAFT,
      title: 'Maison à louer',
      description: 'Une description suffisante pour publier cette annonce.',
      locationId: 'location-id',
      googlePlaceId: null,
      latitude: null,
      longitude: null,
      googleCoordinatesFetchedAt: null,
    });
    transaction.propertyMedia.count.mockResolvedValue(0);

    await expect(
      service.submitDraft(user, 'property-id', {
        authorizationConfirmed: true,
        authorizationType: 'OWNER',
        authorizationTermsVersion: '1.0',
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
    expect(transaction.propertyMedia.count).toHaveBeenCalledWith({
      where: {
        propertyId: 'property-id',
        mediaType: 'PHOTO',
        uploadStatus: 'READY',
      },
    });
  });

  it('uses the selected center and radius for nearby catalogue queries', async () => {
    prisma.$queryRaw
      .mockResolvedValueOnce([{ id: 'nearby-property', distance: 2 }])
      .mockResolvedValueOnce([{ total: 1 }]);
    prisma.property.findMany.mockResolvedValue([{ id: 'nearby-property' }]);

    const result = await service.listPublic({
      centerLatitude: 6.3654,
      centerLongitude: 2.4183,
      radiusKm: 5,
      page: 1,
      pageSize: 12,
    });

    expect(prisma.$queryRaw).toHaveBeenCalledTimes(2);
    expect(result.items).toEqual([{ id: 'nearby-property' }]);
    expect(result.pagination).toMatchObject({ total: 1, totalPages: 1 });
    expect(prisma.property.findMany).toHaveBeenCalledWith(
      expect.objectContaining({ where: { id: { in: ['nearby-property'] } } }),
    );
  });

  it('requires all proximity search parameters together', async () => {
    await expect(
      service.listPublic({
        centerLatitude: 6.3654,
        page: 1,
        pageSize: 12,
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
