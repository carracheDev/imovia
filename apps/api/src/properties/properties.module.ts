import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module.js';
import { PlacesModule } from '../places/places.module.js';
import { StorageModule } from '../storage/storage.module.js';
import {
  LocationsController,
  PropertiesController,
  PropertyModerationController,
} from './properties.controller.js';
import { PropertiesService } from './properties.service.js';

@Module({
  imports: [AuthModule, PlacesModule, StorageModule],
  controllers: [
    PropertiesController,
    LocationsController,
    PropertyModerationController,
  ],
  providers: [PropertiesService],
})
export class PropertiesModule {}
