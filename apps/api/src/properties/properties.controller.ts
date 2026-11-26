import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { AuthGuard } from '../auth/auth.guard.js';
import type { AuthenticatedUser } from '../auth/authenticated-user.js';
import { CurrentUser } from '../auth/current-user.decorator.js';
import { Roles } from '../auth/roles.decorator.js';
import { RolesGuard } from '../auth/roles.guard.js';
import { UserRole } from '../generated/prisma/enums.js';
import { CreatePropertyDto } from './dto/create-property.dto.js';
import { CreateMediaUploadDto } from './dto/create-media-upload.dto.js';
import { ListPropertiesDto } from './dto/list-properties.dto.js';
import { ModerationDecisionDto } from './dto/moderation-decision.dto.js';
import { SubmitPropertyDto } from './dto/submit-property.dto.js';
import { UpdatePropertyDto } from './dto/update-property.dto.js';
import { PropertiesService } from './properties.service.js';
import { PageQueryDto } from '../engagement/dto/page-query.dto.js';
import { UpdateAvailabilityDto } from './dto/update-availability.dto.js';

@ApiTags('Properties')
@Controller('properties')
export class PropertiesController {
  constructor(private readonly properties: PropertiesService) {}

  @Get()
  listPublic(@Query() query: ListPropertiesDto) {
    return this.properties.listPublic(query);
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(AuthGuard, RolesGuard)
  @Roles(UserRole.OWNER, UserRole.AGENT)
  createDraft(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: CreatePropertyDto,
  ) {
    return this.properties.createDraft(user, body);
  }

  @Get('me/list')
  @ApiBearerAuth()
  @UseGuards(AuthGuard)
  listMine(@CurrentUser() user: AuthenticatedUser) {
    return this.properties.listMine(user);
  }

  @Get('me/:id/history')
  @ApiBearerAuth()
  @UseGuards(AuthGuard)
  getHistory(@CurrentUser() user: AuthenticatedUser, @Param('id') id: string) {
    return this.properties.getStatusHistory(user, id);
  }

  @Patch('me/:id/availability')
  @ApiBearerAuth()
  @UseGuards(AuthGuard, RolesGuard)
  @Roles(UserRole.OWNER, UserRole.AGENT)
  updateAvailability(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() body: UpdateAvailabilityDto,
  ) {
    return this.properties.updateAvailability(user, id, body.availability);
  }

  @Patch('me/:id')
  @ApiBearerAuth()
  @UseGuards(AuthGuard, RolesGuard)
  @Roles(UserRole.OWNER, UserRole.AGENT)
  updateDraft(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() body: UpdatePropertyDto,
  ) {
    return this.properties.updateDraft(user, id, body);
  }

  @Post('me/:id/media/upload-url')
  @ApiBearerAuth()
  @UseGuards(AuthGuard, RolesGuard)
  @Roles(UserRole.OWNER, UserRole.AGENT)
  createMediaUpload(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() body: CreateMediaUploadDto,
  ) {
    return this.properties.createMediaUpload(user, id, body);
  }

  @Post('me/:id/media/:mediaId/complete')
  @ApiBearerAuth()
  @UseGuards(AuthGuard, RolesGuard)
  @Roles(UserRole.OWNER, UserRole.AGENT)
  completeMediaUpload(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Param('mediaId') mediaId: string,
  ) {
    return this.properties.completeMediaUpload(user, id, mediaId);
  }

  @Get('me/:id/media/:mediaId/url')
  @ApiBearerAuth()
  @UseGuards(AuthGuard, RolesGuard)
  @Roles(UserRole.OWNER, UserRole.AGENT)
  getOwnMedia(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Param('mediaId') mediaId: string,
  ) {
    return this.properties.getOwnMediaUrl(user, id, mediaId);
  }

  @Patch('me/:id/media/:mediaId/cover')
  @ApiBearerAuth()
  @UseGuards(AuthGuard, RolesGuard)
  @Roles(UserRole.OWNER, UserRole.AGENT)
  setCover(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Param('mediaId') mediaId: string,
  ) {
    return this.properties.setCover(user, id, mediaId);
  }

  @Post('me/:id/submit')
  @ApiBearerAuth()
  @UseGuards(AuthGuard, RolesGuard)
  @Roles(UserRole.OWNER, UserRole.AGENT)
  submit(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() body: SubmitPropertyDto,
  ) {
    return this.properties.submitDraft(user, id, body);
  }

  @Get(':slug/media/:mediaId')
  getPublicMedia(
    @Param('slug') slug: string,
    @Param('mediaId') mediaId: string,
  ) {
    return this.properties.getPublicMediaUrl(slug, mediaId);
  }

  @Get(':slug/contact')
  getPublicContact(@Param('slug') slug: string) {
    return this.properties.getPublicContact(slug);
  }

  @Get(':slug')
  getPublic(@Param('slug') slug: string) {
    return this.properties.getPublicBySlug(slug);
  }
}

@ApiTags('Locations')
@Controller('locations')
export class LocationsController {
  constructor(private readonly properties: PropertiesService) {}

  @Get()
  list(@Query('parentId') parentId?: string) {
    return this.properties.listLocations(parentId);
  }
}

@ApiTags('Property moderation')
@ApiBearerAuth()
@Controller('admin/properties')
@UseGuards(AuthGuard, RolesGuard)
@Roles(UserRole.MODERATOR, UserRole.ADMIN)
export class PropertyModerationController {
  constructor(private readonly properties: PropertiesService) {}

  @Get('queue')
  listQueue(@Query() query: PageQueryDto) {
    return this.properties.listModerationQueue(query.page, query.pageSize);
  }

  @Post(':id/start-review')
  startReview(@CurrentUser() user: AuthenticatedUser, @Param('id') id: string) {
    return this.properties.startModeration(id, user);
  }

  @Post(':id/approve')
  approve(@CurrentUser() user: AuthenticatedUser, @Param('id') id: string) {
    return this.properties.approveProperty(id, user);
  }

  @Get(':id/media/:mediaId/url')
  getReviewMedia(@Param('id') id: string, @Param('mediaId') mediaId: string) {
    return this.properties.getModerationMediaUrl(id, mediaId);
  }

  @Post(':id/media/:mediaId/approve')
  approveMedia(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Param('mediaId') mediaId: string,
  ) {
    return this.properties.approveMedia(id, mediaId, user);
  }

  @Post(':id/reject')
  reject(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() body: ModerationDecisionDto,
  ) {
    return this.properties.rejectProperty(id, user, body);
  }

  @Post(':id/request-changes')
  requestChanges(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() body: ModerationDecisionDto,
  ) {
    return this.properties.requestPropertyChanges(id, user, body);
  }

  @Post(':id/suspend')
  suspend(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() body: ModerationDecisionDto,
  ) {
    return this.properties.suspendProperty(id, user, body);
  }

  @Post(':id/restore')
  restore(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() body: ModerationDecisionDto,
  ) {
    return this.properties.restoreProperty(id, user, body);
  }
}
