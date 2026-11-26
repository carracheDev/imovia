import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import {
  AccountStatus,
  ReportStatus,
  UserRole,
} from '../generated/prisma/enums.js';
import { AuthGuard } from '../auth/auth.guard.js';
import type { AuthenticatedUser } from '../auth/authenticated-user.js';
import { CurrentUser } from '../auth/current-user.decorator.js';
import { Roles } from '../auth/roles.decorator.js';
import { RolesGuard } from '../auth/roles.guard.js';
import { AssignAgentDto } from './dto/assign-agent.dto.js';
import { CreateReportDto } from './dto/create-report.dto.js';
import { AccountStatusDto } from './dto/account-status.dto.js';
import { PageQueryDto } from './dto/page-query.dto.js';
import { ReportStatusDto } from './dto/report-status.dto.js';
import { EngagementService } from './engagement.service.js';

@ApiTags('Engagement')
@ApiBearerAuth()
@UseGuards(AuthGuard)
@Controller()
export class EngagementController {
  constructor(private readonly service: EngagementService) {}

  @Get('users/me/favorites') favorites(
    @CurrentUser() user: AuthenticatedUser,
    @Query() q: PageQueryDto,
  ) {
    return this.service.listFavorites(user, q.page, q.pageSize);
  }
  @Post('users/me/favorites/:propertyId') favorite(
    @CurrentUser() user: AuthenticatedUser,
    @Param('propertyId') propertyId: string,
  ) {
    return this.service.addFavorite(user, propertyId);
  }
  @Delete('users/me/favorites/:propertyId') unfavorite(
    @CurrentUser() user: AuthenticatedUser,
    @Param('propertyId') propertyId: string,
  ) {
    return this.service.removeFavorite(user, propertyId);
  }
  @Get('users/me/notifications') notifications(
    @CurrentUser() user: AuthenticatedUser,
    @Query() q: PageQueryDto,
  ) {
    return this.service.notifications(user, q.page, q.pageSize);
  }
  @Patch('users/me/notifications/:id/read') readNotification(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.service.markNotificationRead(user, id);
  }
  @Post('properties/:propertyId/reports') report(
    @CurrentUser() user: AuthenticatedUser,
    @Param('propertyId') propertyId: string,
    @Body() body: CreateReportDto,
  ) {
    return this.service.createPropertyReport(propertyId, user, body);
  }
  @Post('users/:targetUserId/reports') reportUser(
    @CurrentUser() user: AuthenticatedUser,
    @Param('targetUserId') targetUserId: string,
    @Body() body: CreateReportDto,
  ) {
    return this.service.createUserReport(targetUserId, user, body);
  }
  @Post('properties/:propertyId/assignments')
  @UseGuards(RolesGuard)
  @Roles(UserRole.OWNER)
  assign(
    @CurrentUser() user: AuthenticatedUser,
    @Param('propertyId') propertyId: string,
    @Body() body: AssignAgentDto,
  ) {
    return this.service.assignAgent(propertyId, user, body);
  }
  @Get('properties/:propertyId/assignments')
  @UseGuards(RolesGuard)
  @Roles(UserRole.OWNER)
  listAssignments(
    @CurrentUser() user: AuthenticatedUser,
    @Param('propertyId') propertyId: string,
  ) {
    return this.service.listPropertyAgents(propertyId, user);
  }
  @Delete('properties/:propertyId/assignments/:agentUserId')
  @UseGuards(RolesGuard)
  @Roles(UserRole.OWNER)
  revoke(
    @CurrentUser() user: AuthenticatedUser,
    @Param('propertyId') propertyId: string,
    @Param('agentUserId') agentUserId: string,
  ) {
    return this.service.revokeAgent(propertyId, agentUserId, user);
  }
}

@ApiTags('Public reports')
@Controller('public/properties/:propertyId/reports')
export class PublicReportsController {
  constructor(private readonly service: EngagementService) {}
  @Post() report(
    @Param('propertyId') propertyId: string,
    @Body() body: CreateReportDto,
  ) {
    return this.service.createPropertyReport(propertyId, undefined, body);
  }
}

@ApiTags('Public reports')
@Controller('public/users/:targetUserId/reports')
export class PublicUserReportsController {
  constructor(private readonly service: EngagementService) {}
  @Post() report(
    @Param('targetUserId') targetUserId: string,
    @Body() body: CreateReportDto,
  ) {
    return this.service.createUserReport(targetUserId, undefined, body);
  }
}

@ApiTags('Admin')
@ApiBearerAuth()
@UseGuards(AuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.MODERATOR)
@Controller('admin')
export class AdminEngagementController {
  constructor(private readonly service: EngagementService) {}
  @Get('reports') reports(@Query() q: PageQueryDto) {
    return this.service.listReports(q.page, q.pageSize, q.status);
  }
  @Patch('reports/:id') updateReport(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() body: ReportStatusDto,
  ) {
    return this.service.updateReport(
      id,
      user,
      body.status as ReportStatus,
      body.reason,
    );
  }
  @Get('users') users(@Query() q: PageQueryDto) {
    return this.service.adminUsers(q.page, q.pageSize, q.q);
  }
  @Get('audit-logs') auditLogs(@Query() q: PageQueryDto) {
    return this.service.auditLogs(q.page, q.pageSize);
  }
  @Roles(UserRole.ADMIN)
  @Patch('users/:id/status')
  setUserStatus(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() body: AccountStatusDto,
  ) {
    return this.service.setUserStatus(
      id,
      body.status as AccountStatus,
      user,
      body.reason,
    );
  }
}
