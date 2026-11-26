import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  AccountStatus,
  PropertyPublicationStatus,
  ReportStatus,
  UserRole,
} from '../generated/prisma/enums.js';
import type { AuthenticatedUser } from '../auth/authenticated-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { CreateReportDto } from './dto/create-report.dto.js';
import type { AssignAgentDto } from './dto/assign-agent.dto.js';

@Injectable()
export class EngagementService {
  constructor(private readonly prisma: PrismaService) {}

  async listFavorites(user: AuthenticatedUser, page = 1, pageSize = 20) {
    const where = { userId: user.id };
    const [rows, total] = await Promise.all([
      this.prisma.favorite.findMany({
        where,
        include: {
          property: {
            select: {
              id: true,
              slug: true,
              title: true,
              category: true,
              operationType: true,
              price: true,
              currency: true,
              availability: true,
              publicationStatus: true,
              details: true,
              advertiser: {
                select: {
                  agentProfile: { select: { verificationStatus: true } },
                },
              },
              location: { select: { name: true } },
              media: {
                where: {
                  isCover: true,
                  isApproved: true,
                  uploadStatus: 'READY',
                },
                select: { id: true },
              },
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.favorite.count({ where }),
    ]);
    return {
      items: rows.map(({ property, createdAt }) => ({
        ...property,
        favoritedAt: createdAt,
      })),
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async addFavorite(user: AuthenticatedUser, propertyId: string) {
    const property = await this.prisma.property.findFirst({
      where: {
        id: propertyId,
        publicationStatus: PropertyPublicationStatus.PUBLISHED,
        availability: 'AVAILABLE',
      },
    });
    if (!property) throw new NotFoundException('Property not found');
    await this.prisma.favorite.upsert({
      where: { userId_propertyId: { userId: user.id, propertyId } },
      create: { userId: user.id, propertyId },
      update: {},
    });
    return { propertyId, favorited: true };
  }

  async removeFavorite(user: AuthenticatedUser, propertyId: string) {
    await this.prisma.favorite.deleteMany({
      where: { userId: user.id, propertyId },
    });
    return { propertyId, favorited: false };
  }

  async createPropertyReport(
    propertyId: string,
    user: AuthenticatedUser | undefined,
    input: CreateReportDto,
    ipHash?: string,
  ) {
    const property = await this.prisma.property.findFirst({
      where: {
        id: propertyId,
        publicationStatus: PropertyPublicationStatus.PUBLISHED,
      },
      select: { id: true },
    });
    if (!property) throw new NotFoundException('Property not found');
    if (!user && !input.reporterEmail)
      throw new BadRequestException(
        'An email address is required for an anonymous report',
      );
    const normalizedEmail = input.reporterEmail?.trim().toLowerCase();
    const rateWhere = user
      ? { reporterUserId: user.id }
      : { reporterEmail: normalizedEmail };
    const recent = await this.prisma.report.count({
      where: {
        ...rateWhere,
        createdAt: { gte: new Date(Date.now() - 60 * 60 * 1000) },
      },
    });
    if (recent >= 5)
      throw new HttpException(
        'The report limit for this hour has been reached',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    const report = await this.prisma.report.create({
      data: {
        propertyId,
        reporterUserId: user?.id,
        reporterEmail: normalizedEmail,
        reporterIpHash: ipHash,
        category: input.category,
        description: input.description.trim(),
      },
      select: { id: true, status: true, createdAt: true },
    });
    await this.audit(user?.id, 'REPORT_CREATED', 'Report', report.id, {
      propertyId,
      category: input.category,
    });
    return report;
  }

  async createUserReport(
    targetUserId: string,
    user: AuthenticatedUser | undefined,
    input: CreateReportDto,
  ) {
    const target = await this.prisma.user.findUnique({
      where: { id: targetUserId },
      select: { id: true, accountStatus: true },
    });
    if (!target || target.accountStatus !== AccountStatus.ACTIVE)
      throw new NotFoundException('User not found');
    if (user?.id === targetUserId)
      throw new BadRequestException('You cannot report your own account');
    if (!user && !input.reporterEmail)
      throw new BadRequestException(
        'An email address is required for an anonymous report',
      );
    const normalizedEmail = input.reporterEmail?.trim().toLowerCase();
    const rateWhere = user
      ? { reporterUserId: user.id }
      : { reporterEmail: normalizedEmail };
    const recent = await this.prisma.report.count({
      where: {
        ...rateWhere,
        createdAt: { gte: new Date(Date.now() - 60 * 60 * 1000) },
      },
    });
    if (recent >= 5)
      throw new HttpException(
        'The report limit for this hour has been reached',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    const report = await this.prisma.report.create({
      data: {
        targetUserId,
        reporterUserId: user?.id,
        reporterEmail: normalizedEmail,
        category: input.category,
        description: input.description.trim(),
      },
      select: { id: true, status: true, createdAt: true },
    });
    await this.audit(user?.id, 'USER_REPORTED', 'User', targetUserId, {
      reportId: report.id,
      category: input.category,
    });
    return report;
  }

  async listReports(page = 1, pageSize = 20, status?: ReportStatus) {
    const where = status ? { status } : {};
    const [items, total] = await Promise.all([
      this.prisma.report.findMany({
        where,
        include: {
          property: { select: { id: true, slug: true, title: true } },
          targetUser: {
            select: {
              id: true,
              email: true,
              firstName: true,
              lastName: true,
              accountStatus: true,
            },
          },
          reporter: { select: { id: true, email: true } },
          assignedTo: { select: { id: true, firstName: true, lastName: true } },
        },
        orderBy: { createdAt: 'asc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.report.count({ where }),
    ]);
    return {
      items,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async updateReport(
    id: string,
    actor: AuthenticatedUser,
    status: ReportStatus,
    reason?: string,
  ) {
    const before = await this.prisma.report.findUnique({ where: { id } });
    if (!before) throw new NotFoundException('Report not found');
    if (
      (status === ReportStatus.RESOLVED || status === ReportStatus.DISMISSED) &&
      !reason?.trim()
    )
      throw new BadRequestException('A resolution reason is required');
    if (
      before.status === ReportStatus.RESOLVED ||
      before.status === ReportStatus.DISMISSED
    )
      throw new ConflictException('A closed report cannot be changed');
    const updated = await this.prisma.$transaction(async (tx) => {
      const item = await tx.report.update({
        where: { id },
        data: {
          status,
          resolutionReason: reason?.trim(),
          resolvedAt:
            status === ReportStatus.RESOLVED ||
            status === ReportStatus.DISMISSED
              ? new Date()
              : null,
          assignedToId:
            status === ReportStatus.IN_REVIEW ? actor.id : before.assignedToId,
        },
      });
      await tx.auditLog.create({
        data: {
          actorUserId: actor.id,
          action: 'REPORT_STATUS_CHANGED',
          objectType: 'Report',
          objectId: id,
          reason: reason?.trim(),
          reportId: id,
          before: { status: before.status },
          after: { status },
        },
      });
      return item;
    });
    if (updated.reporterUserId)
      await this.prisma.notification.create({
        data: {
          userId: updated.reporterUserId,
          type: 'REPORT_UPDATED',
          title: 'Mise à jour de votre signalement',
          message: `Le statut de votre signalement est : ${status}.`,
          reportId: id,
        },
      });
    return { id, status: updated.status, resolvedAt: updated.resolvedAt };
  }

  async assignAgent(
    propertyId: string,
    owner: AuthenticatedUser,
    input: AssignAgentDto,
  ) {
    const property = await this.prisma.property.findUnique({
      where: { id: propertyId },
      select: { ownerUserId: true, advertiserUserId: true },
    });
    if (!property) throw new NotFoundException('Property not found');
    if (property.ownerUserId !== owner.id)
      throw new ForbiddenException(
        'Only the property owner can assign an agent',
      );
    const agent = await this.prisma.user.findUnique({
      where: { id: input.agentUserId },
      select: { id: true, roles: true, accountStatus: true },
    });
    if (
      !agent ||
      !agent.roles.includes(UserRole.AGENT) ||
      agent.accountStatus !== AccountStatus.ACTIVE
    )
      throw new BadRequestException('An active agent account is required');
    const assignment = await this.prisma.propertyAssignment.upsert({
      where: { propertyId_agentUserId: { propertyId, agentUserId: agent.id } },
      create: {
        propertyId,
        agentUserId: agent.id,
        assignedById: owner.id,
        authorization: input.authorization.trim(),
        termsVersion: input.termsVersion,
      },
      update: {
        assignedById: owner.id,
        authorization: input.authorization.trim(),
        termsVersion: input.termsVersion,
        grantedAt: new Date(),
        revokedAt: null,
      },
    });
    await this.audit(
      owner.id,
      'AGENT_ASSIGNED',
      'PropertyAssignment',
      assignment.id,
      { propertyId, agentUserId: agent.id },
    );
    return {
      id: assignment.id,
      propertyId,
      agentUserId: agent.id,
      grantedAt: assignment.grantedAt,
    };
  }

  async revokeAgent(
    propertyId: string,
    agentUserId: string,
    owner: AuthenticatedUser,
  ) {
    const row = await this.prisma.propertyAssignment.findUnique({
      where: { propertyId_agentUserId: { propertyId, agentUserId } },
      include: {
        property: { select: { ownerUserId: true, advertiserUserId: true } },
      },
    });
    if (!row) throw new NotFoundException('Assignment not found');
    if (row.property.ownerUserId !== owner.id)
      throw new ForbiddenException(
        'Only the property owner can revoke an agent',
      );
    const result = await this.prisma.propertyAssignment.update({
      where: { id: row.id },
      data: { revokedAt: new Date() },
    });
    await this.audit(owner.id, 'AGENT_REVOKED', 'PropertyAssignment', row.id, {
      propertyId,
      agentUserId,
    });
    return { id: result.id, revokedAt: result.revokedAt };
  }

  async listPropertyAgents(propertyId: string, owner: AuthenticatedUser) {
    const property = await this.prisma.property.findUnique({
      where: { id: propertyId },
      select: { ownerUserId: true },
    });
    if (!property) throw new NotFoundException('Property not found');
    if (property.ownerUserId !== owner.id)
      throw new ForbiddenException(
        'Only the property owner can view its agent authorizations',
      );
    return this.prisma.propertyAssignment.findMany({
      where: { propertyId, revokedAt: null },
      select: {
        id: true,
        authorization: true,
        termsVersion: true,
        grantedAt: true,
        agent: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
            agentProfile: {
              select: {
                displayName: true,
                businessName: true,
                verificationStatus: true,
              },
            },
          },
        },
      },
      orderBy: { grantedAt: 'desc' },
    });
  }

  async notifications(user: AuthenticatedUser, page = 1, pageSize = 20) {
    const where = { userId: user.id };
    const [items, total, unread] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        include: { property: { select: { slug: true } } },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.notification.count({ where }),
      this.prisma.notification.count({ where: { ...where, readAt: null } }),
    ]);
    return {
      items,
      unread,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async markNotificationRead(user: AuthenticatedUser, id: string) {
    const changed = await this.prisma.notification.updateMany({
      where: { id, userId: user.id, readAt: null },
      data: { readAt: new Date() },
    });
    if (!changed.count) {
      const owned = await this.prisma.notification.findFirst({
        where: { id, userId: user.id },
      });
      if (!owned) throw new NotFoundException('Notification not found');
    }
    return { id, read: true };
  }

  async adminUsers(page = 1, pageSize = 20, query?: string) {
    const where = query
      ? {
          OR: [
            { email: { contains: query, mode: 'insensitive' as const } },
            { firstName: { contains: query, mode: 'insensitive' as const } },
            { lastName: { contains: query, mode: 'insensitive' as const } },
          ],
        }
      : {};
    const [items, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        select: {
          id: true,
          email: true,
          phone: true,
          firstName: true,
          lastName: true,
          roles: true,
          accountStatus: true,
          createdAt: true,
          ownerProfile: true,
          agentProfile: true,
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.user.count({ where }),
    ]);
    return {
      items,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async setUserStatus(
    id: string,
    status: AccountStatus,
    actor: AuthenticatedUser,
    reason: string,
  ) {
    if (id === actor.id && status === AccountStatus.SUSPENDED)
      throw new ConflictException('You cannot suspend your own admin account');
    const before = await this.prisma.user.findUnique({
      where: { id },
      select: { accountStatus: true },
    });
    if (!before) throw new NotFoundException('User not found');
    const user = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.user.update({
        where: { id },
        data: { accountStatus: status },
      });
      if (status === AccountStatus.SUSPENDED)
        await tx.session.updateMany({
          where: { userId: id, revokedAt: null },
          data: { revokedAt: new Date() },
        });
      await tx.auditLog.create({
        data: {
          actorUserId: actor.id,
          action: 'ACCOUNT_STATUS_CHANGED',
          objectType: 'User',
          objectId: id,
          reason,
          before: { status: before.accountStatus },
          after: { status },
        },
      });
      return updated;
    });
    return { id: user.id, accountStatus: user.accountStatus };
  }

  async auditLogs(page = 1, pageSize = 50) {
    const [items, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        select: {
          id: true,
          action: true,
          objectType: true,
          objectId: true,
          reason: true,
          before: true,
          after: true,
          createdAt: true,
          actor: {
            select: { id: true, email: true, firstName: true, lastName: true },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.auditLog.count(),
    ]);
    return {
      items,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  private audit(
    actorUserId: string | undefined,
    action: string,
    objectType: string,
    objectId: string,
    after: object,
  ) {
    return this.prisma.auditLog.create({
      data: { actorUserId, action, objectType, objectId, after },
    });
  }
}
