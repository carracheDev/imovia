import { Module } from '@nestjs/common';
import { PlacesCacheService } from './places-cache.service.js';
import { PlacesController } from './places.controller.js';
import { PlacesService } from './places.service.js';

@Module({
  controllers: [PlacesController],
  providers: [PlacesService, PlacesCacheService],
  exports: [PlacesService],
})
export class PlacesModule {}
