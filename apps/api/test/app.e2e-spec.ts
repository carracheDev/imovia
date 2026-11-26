import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module.js';
import { PrismaService } from './../src/prisma/prisma.service.js';
import { ObjectStorageService } from './../src/storage/object-storage.service.js';

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;
  const prismaMock = {
    $queryRaw: async () => [{ '?column?': 1 }],
    property: {
      findMany: vi.fn().mockResolvedValue([]),
      count: vi.fn().mockResolvedValue(0),
    },
    location: {
      findMany: vi.fn().mockResolvedValue([]),
    },
  };

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(prismaMock)
      .overrideProvider(ObjectStorageService)
      .useValue({
        createImageUpload: vi.fn(),
        inspectImage: vi.fn(),
        hasExpectedImageSignature: vi.fn(),
        createDownloadUrl: vi.fn(),
      })
      .compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(
      new ValidationPipe({
        transform: true,
        whitelist: true,
        forbidNonWhitelisted: true,
      }),
    );
    await app.init();
  });

  it('/api/health (GET)', () => {
    return request(app.getHttpServer())
      .get('/api/health')
      .expect(200)
      .expect({ status: 'ok', database: 'connected' });
  });

  it('rejects invalid email addresses for OTP', () => {
    return request(app.getHttpServer())
      .post('/api/auth/otp/request')
      .send({ email: 'not-an-email' })
      .expect(400);
  });

  it('requires authentication for the current-user endpoint', () => {
    return request(app.getHttpServer()).get('/api/auth/me').expect(401);
  });

  it('requires authentication to update a profile', () => {
    return request(app.getHttpServer())
      .patch('/api/users/me/profile')
      .send({ firstName: 'Ada' })
      .expect(401);
  });

  it('only lists published and available properties publicly', async () => {
    await request(app.getHttpServer())
      .get('/api/properties?page=1&pageSize=10')
      .expect(200)
      .expect({
        items: [],
        pagination: { page: 1, pageSize: 10, total: 0, totalPages: 0 },
      });

    expect(prismaMock.property.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { publicationStatus: 'PUBLISHED', availability: 'AVAILABLE' },
      }),
    );
  });

  it('rejects invalid property filters', () => {
    return request(app.getHttpServer())
      .get('/api/properties?category=UNKNOWN')
      .expect(400);
  });

  it('validates Places autocomplete input and session tokens', () => {
    return request(app.getHttpServer())
      .get('/api/places/autocomplete?input=a&sessionToken=short')
      .expect(400);
  });

  it('requires a Places session token to resolve a selected place', () => {
    return request(app.getHttpServer()).get('/api/places/cotonou').expect(400);
  });

  it('requires an authenticated advertiser to create a property', () => {
    return request(app.getHttpServer())
      .post('/api/properties')
      .send({
        title: 'Maison à louer',
        description: 'Une description suffisamment longue pour le test.',
        category: 'HOUSE',
        operationType: 'RENT',
      })
      .expect(401);
  });

  it('requires authentication to request a media upload', () => {
    return request(app.getHttpServer())
      .post('/api/properties/me/property-id/media/upload-url')
      .send({ contentType: 'image/jpeg' })
      .expect(401);
  });

  it('requires authentication to confirm a media upload', () => {
    return request(app.getHttpServer())
      .post('/api/properties/me/property-id/media/media-id/complete')
      .expect(401);
  });

  it('requires authentication to submit a property', () => {
    return request(app.getHttpServer())
      .post('/api/properties/me/property-id/submit')
      .send({})
      .expect(401);
  });

  it('requires authentication to access the moderation queue', () => {
    return request(app.getHttpServer())
      .get('/api/admin/properties/queue')
      .expect(401);
  });

  it('rejects an inverted property price range', () => {
    return request(app.getHttpServer())
      .get('/api/properties?priceMin=200&priceMax=100')
      .expect(400);
  });

  afterEach(async () => {
    if (app) await app.close();
  });
});
