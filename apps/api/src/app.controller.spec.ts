import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller.js';
import { PrismaService } from './prisma/prisma.service.js';

describe('AppController', () => {
  let appController: AppController;
  const prisma = {
    $queryRaw: vi.fn().mockResolvedValue([{ '?column?': 1 }]),
  };

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [{ provide: PrismaService, useValue: prisma }],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('health check', () => {
    it('confirms the API and database are available', async () => {
      await expect(appController.check()).resolves.toEqual({
        status: 'ok',
        database: 'connected',
      });
      expect(prisma.$queryRaw).toHaveBeenCalledOnce();
    });
  });
});
