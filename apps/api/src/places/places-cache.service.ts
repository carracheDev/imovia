import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service.js';
import { GOOGLE_COORDINATE_CACHE_MAX_AGE_MS } from './places.constants.js';
import { PlacesService } from './places.service.js';

const REFRESH_AFTER_DAYS = 25;

@Injectable()
export class PlacesCacheService {
  private readonly logger = new Logger(PlacesCacheService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly places: PlacesService,
  ) {}

  @Cron(CronExpression.EVERY_DAY_AT_3AM)
  async refreshCoordinateCache() {
    if (process.env.GOOGLE_MAPS_API_KEY) {
      const refreshBefore = new Date();
      refreshBefore.setDate(refreshBefore.getDate() - REFRESH_AFTER_DAYS);
      const stalePlaces = await this.prisma.property.findMany({
        where: {
          googlePlaceId: { not: null },
          OR: [
            { googleCoordinatesFetchedAt: null },
            { googleCoordinatesFetchedAt: { lte: refreshBefore } },
          ],
        },
        distinct: ['googlePlaceId'],
        select: { googlePlaceId: true },
      });

      for (const { googlePlaceId } of stalePlaces) {
        if (!googlePlaceId) continue;
        try {
          const details = await this.places.getDetails(googlePlaceId);
          await this.prisma.property.updateMany({
            where: { googlePlaceId },
            data: {
              latitude: details.latitude,
              longitude: details.longitude,
              googleCoordinatesFetchedAt: new Date(),
            },
          });
        } catch (error) {
          this.logger.error(
            `Could not refresh coordinates for Google place ${googlePlaceId}`,
            error instanceof Error ? error.stack : undefined,
          );
        }
      }
    }
  }

  @Cron(CronExpression.EVERY_HOUR)
  async expireCoordinateCache() {
    const expireBefore = new Date();
    expireBefore.setTime(
      expireBefore.getTime() - GOOGLE_COORDINATE_CACHE_MAX_AGE_MS,
    );
    await this.prisma.property.updateMany({
      where: { googleCoordinatesFetchedAt: { lte: expireBefore } },
      data: {
        latitude: null,
        longitude: null,
        googleCoordinatesFetchedAt: null,
      },
    });
  }
}
