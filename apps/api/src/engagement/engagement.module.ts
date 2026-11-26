import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module.js';
import {
  EngagementController,
  PublicReportsController,
  PublicUserReportsController,
  AdminEngagementController,
} from './engagement.controller.js';
import { EngagementService } from './engagement.service.js';
@Module({
  imports: [AuthModule],
  controllers: [
    EngagementController,
    PublicReportsController,
    PublicUserReportsController,
    AdminEngagementController,
  ],
  providers: [EngagementService],
})
export class EngagementModule {}
