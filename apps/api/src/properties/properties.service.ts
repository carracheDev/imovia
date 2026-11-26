import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomBytes, randomUUID } from 'node:crypto';
import {
  AccountStatus,
  LocationLevel,
  MediaUploadStatus,
  NotificationType,
  PropertyAvailability,
  PropertyPublicationStatus,
  UserRole,
} from '../generated/prisma/enums.js';
import { Prisma } from '../generated/prisma/client.js';
import type { AuthenticatedUser } from '../auth/authenticated-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { GOOGLE_COORDINATE_CACHE_MAX_AGE_MS } from '../places/places.constants.js';
import { PlacesService } from '../places/places.service.js';
import {
  MAX_IMAGE_SIZE_BYTES,
  ObjectStorageService,
} from '../storage/object-storage.service.js';
import type { CreatePropertyDto } from './dto/create-property.dto.js';
import type { CreateMediaUploadDto } from './dto/create-media-upload.dto.js';
import type { ListPropertiesDto } from './dto/list-properties.dto.js';
import type { UpdatePropertyDto } from './dto/update-property.dto.js';
import type { SubmitPropertyDto } from './dto/submit-property.dto.js';
import type { ModerationDecisionDto } from './dto/moderation-decision.dto.js';

const publicPropertySelect = {
  id: true,
  slug: true,
  title: true,
  description: true,
  category: true,
  operationType: true,
  price: true,
  currency: true,
  availability: true,
  createdAt: true,
  publishedAt: true,
  ownerDisplayName: true,
  details: true,
  visitInstructions: true,
  googlePlaceId: true,
  location: { select: { id: true, name: true, level: true } },
  media: {
    where: {
      uploadStatus: MediaUploadStatus.READY,
      isApproved: true,
      mediaType: 'PHOTO',
    },
    orderBy: { position: 'asc' },
    select: { id: true, position: true, isCover: true },
  },
  advertiser: {
    select: {
      id: true,
      firstName: true,
      lastName: true,
      agentProfile: { select: { displayName: true, verificationStatus: true } },
      ownerProfile: { select: { displayName: true } },
    },
  },
} as const;

const publicAccountEligibility = {
  advertiser: { is: { accountStatus: AccountStatus.ACTIVE } },
  OR: [
    { ownerUserId: null },
    { owner: { is: { accountStatus: AccountStatus.ACTIVE } } },
  ],
} satisfies Prisma.PropertyWhereInput;

@Injectable()
export class PropertiesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: ObjectStorageService,
    private readonly places: PlacesService,
  ) {}

  async listPublic(query: ListPropertiesDto) {
    if (
      query.priceMin !== undefined &&
      query.priceMax !== undefined &&
      this.toMinorUnits(query.priceMin) > this.toMinorUnits(query.priceMax)
    ) {
      throw new BadRequestException('priceMin cannot be greater than priceMax');
    }
    const hasCenter =
      query.centerLatitude !== undefined ||
      query.centerLongitude !== undefined ||
      query.radiusKm !== undefined;
    if (
      hasCenter &&
      (query.centerLatitude === undefined ||
        query.centerLongitude === undefined ||
        query.radiusKm === undefined)
    ) {
      throw new BadRequestException(
        'centerLatitude, centerLongitude, and radiusKm must be provided together',
      );
    }

    if (hasCenter) return this.listNearby(query);

    const searchTerm = query.q?.trim();
    const where = {
      publicationStatus: PropertyPublicationStatus.PUBLISHED,
      availability: 'AVAILABLE' as const,
      AND: [
        publicAccountEligibility,
        ...(searchTerm
          ? [
              {
                OR: [
                  { title: { contains: searchTerm, mode: 'insensitive' as const } },
                  {
                    location: {
                      is: {
                        name: {
                          contains: searchTerm,
                          mode: 'insensitive' as const,
                        },
                      },
                    },
                  },
                ],
              },
            ]
          : []),
      ],
      ...(query.category ? { category: query.category } : {}),
      ...(query.operationType ? { operationType: query.operationType } : {}),
      ...(query.locationId ? { locationId: query.locationId } : {}),
      ...(query.priceMin || query.priceMax
        ? {
            price: {
              ...(query.priceMin ? { gte: query.priceMin } : {}),
              ...(query.priceMax ? { lte: query.priceMax } : {}),
            },
          }
        : {}),
    };
    const [items, total] = await Promise.all([
      this.prisma.property.findMany({
        where,
        select: publicPropertySelect,
        orderBy: { createdAt: 'desc' },
        skip: (query.page - 1) * query.pageSize,
        take: query.pageSize,
      }),
      this.prisma.property.count({ where }),
    ]);

    return {
      items,
      pagination: {
        page: query.page,
        pageSize: query.pageSize,
        total,
        totalPages: Math.ceil(total / query.pageSize),
      },
    };
  }

  async getPublicBySlug(slug: string) {
    const property = await this.prisma.property.findFirst({
      where: {
        slug,
        publicationStatus: PropertyPublicationStatus.PUBLISHED,
        availability: 'AVAILABLE',
        ...publicAccountEligibility,
      },
      select: publicPropertySelect,
    });
    if (!property) throw new NotFoundException('Property not found');
    return property;
  }

  async getPublicContact(slug: string) {
    const property = await this.prisma.property.findFirst({
      where: {
        slug,
        publicationStatus: PropertyPublicationStatus.PUBLISHED,
        availability: 'AVAILABLE',
        ...publicAccountEligibility,
      },
      select: {
        allowPhoneContact: true,
        allowWhatsAppContact: true,
        contactPhone: true,
        contactWhatsApp: true,
      },
    });
    if (!property) throw new NotFoundException('Property not found');
    return {
      phone: property.allowPhoneContact ? property.contactPhone : null,
      whatsApp: property.allowWhatsAppContact ? property.contactWhatsApp : null,
    };
  }

  async listLocations(parentId?: string) {
    return this.prisma.location.findMany({
      where: parentId ? { parentId } : { parentId: null },
      select: { id: true, name: true, slug: true, level: true, parentId: true },
      orderBy: { name: 'asc' },
    });
  }

  async createDraft(user: AuthenticatedUser, input: CreatePropertyDto) {
    this.assertAdvertiserRole(user);
    const ownerUserId = user.roles.includes(UserRole.OWNER)
      ? user.id
      : input.ownerUserId;
    if (!ownerUserId)
      throw new BadRequestException(
        'The property owner is required for an agent listing',
      );
    const owner = await this.prisma.user.findUnique({
      where: { id: ownerUserId },
      select: { id: true, roles: true, accountStatus: true },
    });
    if (
      !owner ||
      !owner.roles.includes(UserRole.OWNER) ||
      owner.accountStatus !== 'ACTIVE'
    )
      throw new BadRequestException('An active owner account is required');
    if (input.locationId && input.googlePlaceId) {
      throw new BadRequestException(
        'Choose either a CARANOVA location or a Google place',
      );
    }
    if (input.locationId) {
      await this.assertSelectableLocation(input.locationId);
    }
    const place = input.googlePlaceId
      ? await this.places.getDetails(input.googlePlaceId)
      : undefined;

    const slug = `${this.slugify(input.title)}-${randomBytes(4).toString('hex')}`;
    return this.prisma.$transaction(async (transaction) => {
      const property = await transaction.property.create({
        data: {
          slug,
          advertiserUserId: user.id,
          ownerUserId,
          ownerDisplayName: input.ownerDisplayName,
          locationId: input.locationId,
          ...(place
            ? {
                googlePlaceId: place.placeId,
                latitude: place.latitude,
                longitude: place.longitude,
                googleCoordinatesFetchedAt: new Date(),
              }
            : {}),
          title: input.title.trim(),
          description: input.description.trim(),
          category: input.category,
          operationType: input.operationType,
          price: input.price,
          details: input.details as Prisma.InputJsonValue | undefined,
          contactPhone: input.contactPhone,
          contactWhatsApp: input.contactWhatsApp,
          visitInstructions: input.visitInstructions,
          allowPhoneContact: input.allowPhoneContact ?? false,
          allowWhatsAppContact: input.allowWhatsAppContact ?? false,
          publicationStatus: PropertyPublicationStatus.DRAFT,
        },
        select: {
          id: true,
          slug: true,
          title: true,
          description: true,
          category: true,
          operationType: true,
          price: true,
          currency: true,
          availability: true,
          publicationStatus: true,
          locationId: true,
          googlePlaceId: true,
          ownerUserId: true,
          ownerDisplayName: true,
          details: true,
          contactPhone: true,
          contactWhatsApp: true,
          allowPhoneContact: true,
          allowWhatsAppContact: true,
          visitInstructions: true,
          createdAt: true,
          updatedAt: true,
        },
      });
      await transaction.propertyStatusHistory.create({
        data: {
          propertyId: property.id,
          status: PropertyPublicationStatus.DRAFT,
          changedById: user.id,
        },
      });
      return property;
    });
  }

  async listMine(user: AuthenticatedUser) {
    return this.prisma.property.findMany({
      where: {
        OR: [
          { ownerUserId: user.id },
          { AND: [{ advertiserUserId: user.id }, { ownerUserId: null }] },
          {
            AND: [
              { advertiserUserId: user.id },
              { publicationStatus: PropertyPublicationStatus.DRAFT },
              { assignments: { none: { agentUserId: user.id } } },
            ],
          },
          { assignments: { some: { agentUserId: user.id, revokedAt: null } } },
        ],
      },
      select: {
        id: true,
        slug: true,
        title: true,
        category: true,
        operationType: true,
        price: true,
        availability: true,
        publicationStatus: true,
        locationId: true,
        googlePlaceId: true,
        ownerUserId: true,
        ownerDisplayName: true,
        details: true,
        contactPhone: true,
        contactWhatsApp: true,
        allowPhoneContact: true,
        allowWhatsAppContact: true,
        visitInstructions: true,
        media: {
          orderBy: { position: 'asc' },
          select: {
            id: true,
            contentType: true,
            uploadStatus: true,
            sizeBytes: true,
            position: true,
            isCover: true,
            isApproved: true,
          },
        },
        createdAt: true,
        updatedAt: true,
      },
      orderBy: { updatedAt: 'desc' },
    });
  }

  async getStatusHistory(user: AuthenticatedUser, propertyId: string) {
    const property = await this.prisma.property.findUnique({
      where: { id: propertyId },
      select: { advertiserUserId: true, ownerUserId: true },
    });
    if (
      !property ||
      !(await this.canManageProperty(
        user.id,
        propertyId,
        property.advertiserUserId,
        property.ownerUserId,
      ))
    )
      throw new NotFoundException('Property not found');
    return this.prisma.propertyStatusHistory.findMany({
      where: { propertyId },
      select: {
        id: true,
        status: true,
        reason: true,
        createdAt: true,
        changedBy: { select: { id: true, firstName: true, lastName: true } },
        reviewer: { select: { id: true, firstName: true, lastName: true } },
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  async updateAvailability(
    user: AuthenticatedUser,
    propertyId: string,
    availability: PropertyAvailability,
  ) {
    const property = await this.prisma.property.findUnique({
      where: { id: propertyId },
      select: {
        advertiserUserId: true,
        ownerUserId: true,
        availability: true,
        publicationStatus: true,
      },
    });
    if (!property) throw new NotFoundException('Property not found');
    if (
      !(await this.canManageProperty(
        user.id,
        propertyId,
        property.advertiserUserId,
        property.ownerUserId,
      ))
    )
      throw new ForbiddenException('You cannot change this property');
    if (
      property.publicationStatus !== PropertyPublicationStatus.PUBLISHED &&
      property.publicationStatus !== PropertyPublicationStatus.SUSPENDED
    )
      throw new ConflictException(
        'Only published or suspended properties can change availability',
      );
    const updated = await this.prisma.$transaction(async (tx) => {
      const result = await tx.property.update({
        where: { id: propertyId },
        data: { availability },
      });
      await tx.auditLog.create({
        data: {
          actorUserId: user.id,
          action: 'PROPERTY_AVAILABILITY_CHANGED',
          objectType: 'Property',
          objectId: propertyId,
          propertyId,
          before: { availability: property.availability },
          after: { availability },
        },
      });
      return result;
    });
    return { id: updated.id, availability: updated.availability };
  }

  async createMediaUpload(
    user: AuthenticatedUser,
    propertyId: string,
    input: CreateMediaUploadDto,
  ) {
    this.assertAdvertiserRole(user);
    const property = await this.prisma.property.findUnique({
      where: { id: propertyId },
      select: {
        advertiserUserId: true,
        ownerUserId: true,
        publicationStatus: true,
      },
    });
    if (!property) throw new NotFoundException('Property not found');
    if (
      !(await this.canManageProperty(
        user.id,
        propertyId,
        property.advertiserUserId,
        property.ownerUserId,
      ))
    ) {
      throw new ForbiddenException(
        'You can only add media to your own properties',
      );
    }
    if (
      property.publicationStatus !== PropertyPublicationStatus.DRAFT &&
      property.publicationStatus !== PropertyPublicationStatus.NEEDS_CHANGES
    ) {
      throw new ConflictException(
        'Media can only be added to drafts or properties needing changes',
      );
    }

    const count = await this.prisma.propertyMedia.count({
      where: { propertyId },
    });
    if (count >= 20)
      throw new BadRequestException('A property can have at most 20 photos');

    const extension = input.contentType.split('/')[1];
    const storageKey = `pending/${propertyId}/${randomUUID()}.${extension}`;
    const upload = await this.storage.createImageUpload(
      storageKey,
      input.contentType,
    );
    const media = await this.prisma.propertyMedia.create({
      data: {
        propertyId,
        mediaType: 'PHOTO',
        storageKey,
        contentType: input.contentType,
        position: count,
        isCover: count === 0,
      },
      select: { id: true },
    });

    return {
      mediaId: media.id,
      uploadUrl: upload.url,
      fields: upload.fields,
      expiresInSeconds: 300,
      maxSizeBytes: MAX_IMAGE_SIZE_BYTES,
    };
  }

  async completeMediaUpload(
    user: AuthenticatedUser,
    propertyId: string,
    mediaId: string,
  ) {
    this.assertAdvertiserRole(user);
    const media = await this.prisma.propertyMedia.findFirst({
      where: {
        id: mediaId,
        propertyId,
      },
      select: {
        id: true,
        storageKey: true,
        contentType: true,
        uploadStatus: true,
        property: {
          select: {
            publicationStatus: true,
            advertiserUserId: true,
            ownerUserId: true,
          },
        },
      },
    });
    if (!media) throw new NotFoundException('Property media not found');
    if (
      !(await this.canManageProperty(
        user.id,
        propertyId,
        media.property.advertiserUserId,
        media.property.ownerUserId,
      ))
    )
      throw new NotFoundException('Property media not found');
    if (
      media.property.publicationStatus !== PropertyPublicationStatus.DRAFT &&
      media.property.publicationStatus !==
        PropertyPublicationStatus.NEEDS_CHANGES
    ) {
      throw new ConflictException(
        'Media can only be completed for an editable property',
      );
    }
    if (media.uploadStatus === MediaUploadStatus.READY) {
      return { id: media.id, uploadStatus: media.uploadStatus };
    }
    if (media.uploadStatus === MediaUploadStatus.VERIFYING) {
      throw new ConflictException(
        'This media upload is already being verified',
      );
    }

    const claimed = await this.prisma.propertyMedia.updateMany({
      where: {
        id: media.id,
        uploadStatus: MediaUploadStatus.PENDING,
      },
      data: { uploadStatus: MediaUploadStatus.VERIFYING },
    });
    if (claimed.count !== 1) {
      throw new ConflictException(
        'The media upload status changed; reload and try again',
      );
    }

    try {
      let object: Awaited<ReturnType<ObjectStorageService['inspectImage']>>;
      try {
        object = await this.storage.inspectImage(media.storageKey);
      } catch (error) {
        if (
          typeof error === 'object' &&
          error !== null &&
          '$metadata' in error &&
          typeof error.$metadata === 'object' &&
          error.$metadata !== null &&
          'httpStatusCode' in error.$metadata &&
          error.$metadata.httpStatusCode === 404
        ) {
          throw new BadRequestException('The uploaded image was not found');
        }
        throw error;
      }

      if (
        object.sizeBytes === undefined ||
        object.sizeBytes < 1 ||
        object.sizeBytes > MAX_IMAGE_SIZE_BYTES
      ) {
        throw new BadRequestException(
          'The image must be between 1 byte and 5 MB',
        );
      }
      if (object.contentType !== media.contentType) {
        throw new BadRequestException(
          'The uploaded image content type does not match',
        );
      }
      if (
        !(await this.storage.hasExpectedImageSignature(
          media.storageKey,
          media.contentType,
        ))
      ) {
        throw new BadRequestException('The uploaded file is not a valid image');
      }

      const extension = media.contentType.split('/')[1];
      const finalStorageKey = `properties/${propertyId}/${randomUUID()}.${extension}`;
      await this.storage.copyImage(media.storageKey, finalStorageKey);

      const updated = await this.prisma.propertyMedia.updateMany({
        where: {
          id: media.id,
          uploadStatus: MediaUploadStatus.VERIFYING,
        },
        data: {
          storageKey: finalStorageKey,
          uploadStatus: MediaUploadStatus.READY,
          sizeBytes: object.sizeBytes,
        },
      });
      if (updated.count !== 1) {
        await this.storage.deleteImage(finalStorageKey);
        throw new ConflictException(
          'The media upload status changed; reload and try again',
        );
      }
      await this.storage.deleteImage(media.storageKey);
      return { id: media.id, uploadStatus: MediaUploadStatus.READY };
    } finally {
      await this.prisma.propertyMedia.updateMany({
        where: {
          id: media.id,
          uploadStatus: MediaUploadStatus.VERIFYING,
        },
        data: { uploadStatus: MediaUploadStatus.PENDING },
      });
    }
  }

  async getPublicMediaUrl(slug: string, mediaId: string) {
    const media = await this.prisma.propertyMedia.findFirst({
      where: {
        id: mediaId,
        uploadStatus: MediaUploadStatus.READY,
        isApproved: true,
        property: {
          is: {
            slug,
            publicationStatus: PropertyPublicationStatus.PUBLISHED,
            availability: 'AVAILABLE',
            ...publicAccountEligibility,
          },
        },
      },
      select: { storageKey: true },
    });
    if (!media) throw new NotFoundException('Property media not found');
    return { url: await this.storage.createDownloadUrl(media.storageKey) };
  }

  async getOwnMediaUrl(
    user: AuthenticatedUser,
    propertyId: string,
    mediaId: string,
  ) {
    const media = await this.prisma.propertyMedia.findFirst({
      where: {
        id: mediaId,
        propertyId,
        uploadStatus: MediaUploadStatus.READY,
      },
      select: {
        storageKey: true,
        property: { select: { advertiserUserId: true, ownerUserId: true } },
      },
    });
    if (!media) throw new NotFoundException('Property media not found');
    if (
      !(await this.canManageProperty(
        user.id,
        propertyId,
        media.property.advertiserUserId,
        media.property.ownerUserId,
      ))
    )
      throw new NotFoundException('Property media not found');
    return { url: await this.storage.createDownloadUrl(media.storageKey) };
  }

  async setCover(user: AuthenticatedUser, propertyId: string, mediaId: string) {
    this.assertAdvertiserRole(user);
    return this.prisma.$transaction(async (transaction) => {
      const property = await transaction.property.findUnique({
        where: { id: propertyId },
        select: {
          advertiserUserId: true,
          ownerUserId: true,
          publicationStatus: true,
        },
      });
      if (!property) throw new NotFoundException('Property not found');
      if (
        !(await this.canManageProperty(
          user.id,
          propertyId,
          property.advertiserUserId,
          property.ownerUserId,
        ))
      ) {
        throw new ForbiddenException(
          'You can only manage media for your own properties',
        );
      }
      if (
        property.publicationStatus !== PropertyPublicationStatus.DRAFT &&
        property.publicationStatus !== PropertyPublicationStatus.NEEDS_CHANGES
      ) {
        throw new ConflictException(
          'The cover can only be changed on an editable property',
        );
      }

      const updated = await transaction.propertyMedia.updateMany({
        where: {
          id: mediaId,
          propertyId,
          uploadStatus: MediaUploadStatus.READY,
        },
        data: { isCover: true },
      });
      if (updated.count !== 1) {
        throw new NotFoundException('Completed property media not found');
      }
      await transaction.propertyMedia.updateMany({
        where: { propertyId, id: { not: mediaId } },
        data: { isCover: false },
      });
      return { id: mediaId, isCover: true };
    });
  }

  async updateDraft(
    user: AuthenticatedUser,
    id: string,
    input: UpdatePropertyDto,
  ) {
    this.assertAdvertiserRole(user);
    const property = await this.prisma.property.findUnique({
      where: { id },
      select: {
        advertiserUserId: true,
        ownerUserId: true,
        publicationStatus: true,
      },
    });
    if (!property) throw new NotFoundException('Property not found');
    if (
      !(await this.canManageProperty(
        user.id,
        id,
        property.advertiserUserId,
        property.ownerUserId,
      ))
    ) {
      throw new ForbiddenException('You can only edit your own properties');
    }
    if (
      property.publicationStatus !== PropertyPublicationStatus.DRAFT &&
      property.publicationStatus !== PropertyPublicationStatus.NEEDS_CHANGES
    ) {
      throw new ForbiddenException('Only draft properties can be edited');
    }
    if (input.locationId && input.googlePlaceId) {
      throw new BadRequestException(
        'Choose either a CARANOVA location or a Google place',
      );
    }
    if (input.locationId) await this.assertSelectableLocation(input.locationId);
    const place = input.googlePlaceId
      ? await this.places.getDetails(input.googlePlaceId)
      : undefined;

    return this.prisma.property.update({
      where: { id },
      data: {
        ...(input.title !== undefined ? { title: input.title.trim() } : {}),
        ...(input.description !== undefined
          ? { description: input.description.trim() }
          : {}),
        ...(input.category !== undefined ? { category: input.category } : {}),
        ...(input.operationType !== undefined
          ? { operationType: input.operationType }
          : {}),
        ...(input.price !== undefined ? { price: input.price } : {}),
        ...(input.ownerDisplayName !== undefined
          ? { ownerDisplayName: input.ownerDisplayName.trim() }
          : {}),
        ...(input.details !== undefined
          ? { details: input.details as Prisma.InputJsonValue }
          : {}),
        ...(input.contactPhone !== undefined
          ? { contactPhone: input.contactPhone }
          : {}),
        ...(input.contactWhatsApp !== undefined
          ? { contactWhatsApp: input.contactWhatsApp }
          : {}),
        ...(input.allowPhoneContact !== undefined
          ? {
              allowPhoneContact: input.allowPhoneContact,
              ...(input.allowPhoneContact ? {} : { contactPhone: null }),
            }
          : {}),
        ...(input.allowWhatsAppContact !== undefined
          ? {
              allowWhatsAppContact: input.allowWhatsAppContact,
              ...(input.allowWhatsAppContact ? {} : { contactWhatsApp: null }),
            }
          : {}),
        ...(input.visitInstructions !== undefined
          ? { visitInstructions: input.visitInstructions }
          : {}),
        ...(input.locationId !== undefined
          ? { locationId: input.locationId }
          : {}),
        ...(input.googlePlaceId !== undefined
          ? {
              locationId: null,
              googlePlaceId: place?.placeId ?? null,
              latitude: place?.latitude ?? null,
              longitude: place?.longitude ?? null,
              googleCoordinatesFetchedAt: place ? new Date() : null,
            }
          : input.locationId !== undefined
            ? {
                googlePlaceId: null,
                latitude: null,
                longitude: null,
                googleCoordinatesFetchedAt: null,
              }
            : {}),
        ...(input.title !== undefined
          ? {
              slug: `${this.slugify(input.title)}-${randomBytes(4).toString('hex')}`,
            }
          : {}),
      },
      select: {
        id: true,
        slug: true,
        title: true,
        description: true,
        category: true,
        operationType: true,
        price: true,
        currency: true,
        availability: true,
        publicationStatus: true,
        locationId: true,
        googlePlaceId: true,
        ownerUserId: true,
        ownerDisplayName: true,
        details: true,
        contactPhone: true,
        contactWhatsApp: true,
        allowPhoneContact: true,
        allowWhatsAppContact: true,
        visitInstructions: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async submitDraft(
    user: AuthenticatedUser,
    id: string,
    input: SubmitPropertyDto,
  ) {
    this.assertAdvertiserRole(user);
    if (!input.authorizationConfirmed) {
      throw new BadRequestException(
        'Publication authorization must be confirmed',
      );
    }
    const expectedAuthorizationType = user.roles.includes(UserRole.AGENT)
      ? 'AUTHORIZED_AGENT'
      : 'OWNER';
    if (input.authorizationType !== expectedAuthorizationType) {
      throw new BadRequestException(
        'The authorization declaration does not match your advertiser role',
      );
    }
    const requiredTermsVersion =
      process.env.PROPERTY_AUTHORIZATION_TERMS_VERSION ?? '1.0';
    if (input.authorizationTermsVersion !== requiredTermsVersion) {
      throw new BadRequestException(
        'The publication authorization terms have changed; review and accept the current version',
      );
    }

    return this.prisma.$transaction(async (transaction) => {
      const property = await transaction.property.findUnique({
        where: { id },
        select: {
          advertiserUserId: true,
          ownerUserId: true,
          publicationStatus: true,
          title: true,
          description: true,
          locationId: true,
          googlePlaceId: true,
          latitude: true,
          longitude: true,
          googleCoordinatesFetchedAt: true,
        },
      });
      if (!property) throw new NotFoundException('Property not found');
      if (
        !(await this.canManageProperty(
          user.id,
          id,
          property.advertiserUserId,
          property.ownerUserId,
        ))
      ) {
        throw new ForbiddenException('You can only submit your own properties');
      }
      if (
        user.roles.includes(UserRole.AGENT) &&
        property.ownerUserId !== user.id
      ) {
        const authorization = await transaction.propertyAssignment.findFirst({
          where: { propertyId: id, agentUserId: user.id, revokedAt: null },
          select: { id: true },
        });
        if (!authorization)
          throw new ForbiddenException(
            'An active owner authorization is required to publish this property',
          );
      }
      if (
        property.publicationStatus !== PropertyPublicationStatus.DRAFT &&
        property.publicationStatus !== PropertyPublicationStatus.NEEDS_CHANGES
      ) {
        throw new ConflictException(
          'Only drafts or properties needing changes can be submitted',
        );
      }
      const hasFreshGoogleCoordinates =
        typeof property.googlePlaceId === 'string' &&
        typeof property.latitude === 'number' &&
        typeof property.longitude === 'number' &&
        property.googleCoordinatesFetchedAt instanceof Date &&
        Date.now() - property.googleCoordinatesFetchedAt.getTime() <
          GOOGLE_COORDINATE_CACHE_MAX_AGE_MS;
      if (!property.locationId && !hasFreshGoogleCoordinates) {
        throw new BadRequestException(
          'A property location is required before submission',
        );
      }
      if (!property.title.trim() || !property.description.trim()) {
        throw new BadRequestException(
          'A property title and description are required before submission',
        );
      }
      const photoCount = await transaction.propertyMedia.count({
        where: {
          propertyId: id,
          mediaType: 'PHOTO',
          uploadStatus: MediaUploadStatus.READY,
        },
      });
      if (photoCount === 0) {
        throw new BadRequestException(
          'At least one photo is required before submission',
        );
      }

      const updated = await transaction.property.updateMany({
        where: {
          id,
          publicationStatus: property.publicationStatus,
          OR: [
            { ownerUserId: user.id },
            { advertiserUserId: user.id, ownerUserId: null },
            {
              assignments: { some: { agentUserId: user.id, revokedAt: null } },
            },
          ],
        },
        data: { publicationStatus: PropertyPublicationStatus.SUBMITTED },
      });
      if (updated.count !== 1) {
        throw new ConflictException(
          'The property status changed; reload and try again',
        );
      }

      await transaction.propertyAuthorization.create({
        data: {
          propertyId: id,
          advertiserUserId: user.id,
          declaration: input.authorizationType,
          termsVersion: requiredTermsVersion,
        },
      });
      await transaction.propertyStatusHistory.create({
        data: {
          propertyId: id,
          status: PropertyPublicationStatus.SUBMITTED,
          changedById: user.id,
        },
      });
      await transaction.auditLog.create({
        data: {
          actorUserId: user.id,
          action: 'PROPERTY_SUBMITTED',
          objectType: 'Property',
          objectId: id,
          propertyId: id,
          after: { status: PropertyPublicationStatus.SUBMITTED },
        },
      });
      await transaction.notification.create({
        data: {
          userId: user.id,
          type: NotificationType.LISTING_SUBMITTED,
          title: 'Annonce envoyée',
          message: 'Votre annonce a été envoyée à l’équipe de modération.',
          propertyId: id,
        },
      });

      return transaction.property.findUniqueOrThrow({
        where: { id },
        select: {
          id: true,
          slug: true,
          publicationStatus: true,
          updatedAt: true,
        },
      });
    });
  }

  async listModerationQueue(page = 1, pageSize = 20) {
    const where = {
      publicationStatus: {
        in: [
          PropertyPublicationStatus.SUBMITTED,
          PropertyPublicationStatus.IN_REVIEW,
        ],
      },
    };
    const [items, total] = await Promise.all([
      this.prisma.property.findMany({
        where,
        select: {
          id: true,
          slug: true,
          title: true,
          description: true,
          category: true,
          operationType: true,
          price: true,
          currency: true,
          createdAt: true,
          advertiser: {
            select: {
              id: true,
              email: true,
              firstName: true,
              lastName: true,
              roles: true,
              ownerProfile: { select: { displayName: true } },
              agentProfile: {
                select: { displayName: true, businessName: true },
              },
            },
          },
          location: { select: { id: true, name: true, level: true } },
          authorizations: {
            orderBy: { acceptedAt: 'desc' },
            take: 1,
            select: { declaration: true, termsVersion: true, acceptedAt: true },
          },
          media: {
            where: {
              mediaType: 'PHOTO',
              uploadStatus: MediaUploadStatus.READY,
            },
            orderBy: { position: 'asc' },
            select: {
              id: true,
              contentType: true,
              isCover: true,
              isApproved: true,
            },
          },
        },
        orderBy: { createdAt: 'asc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.property.count({ where }),
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

  async startModeration(propertyId: string, moderator: AuthenticatedUser) {
    return this.transitionModeration(
      propertyId,
      moderator,
      PropertyPublicationStatus.SUBMITTED,
      PropertyPublicationStatus.IN_REVIEW,
    );
  }

  async approveProperty(propertyId: string, moderator: AuthenticatedUser) {
    const property = await this.prisma.property.findUnique({
      where: { id: propertyId },
      select: {
        publicationStatus: true,
        media: {
          where: {
            mediaType: 'PHOTO',
            uploadStatus: MediaUploadStatus.READY,
            isApproved: true,
          },
          select: { id: true },
        },
      },
    });
    if (!property) throw new NotFoundException('Property not found');
    if (property.publicationStatus !== PropertyPublicationStatus.IN_REVIEW) {
      throw new ConflictException(
        'Only properties under review can be approved',
      );
    }
    if (property.media.length === 0) {
      throw new BadRequestException(
        'At least one approved photo is required before publication',
      );
    }
    return this.transitionModeration(
      propertyId,
      moderator,
      PropertyPublicationStatus.IN_REVIEW,
      PropertyPublicationStatus.PUBLISHED,
    );
  }

  async getModerationMediaUrl(propertyId: string, mediaId: string) {
    const media = await this.prisma.propertyMedia.findFirst({
      where: {
        id: mediaId,
        propertyId,
        uploadStatus: MediaUploadStatus.READY,
        property: {
          is: { publicationStatus: PropertyPublicationStatus.IN_REVIEW },
        },
      },
      select: { storageKey: true },
    });
    if (!media) throw new NotFoundException('Review media not found');
    return { url: await this.storage.createDownloadUrl(media.storageKey) };
  }

  async approveMedia(
    propertyId: string,
    mediaId: string,
    moderator: AuthenticatedUser,
  ) {
    const media = await this.prisma.propertyMedia.findFirst({
      where: { id: mediaId, propertyId },
      select: {
        uploadStatus: true,
        isApproved: true,
        property: { select: { publicationStatus: true } },
      },
    });
    if (!media) throw new NotFoundException('Property media not found');
    if (
      media.property.publicationStatus !== PropertyPublicationStatus.IN_REVIEW
    ) {
      throw new ConflictException(
        'Media can only be approved while the property is under review',
      );
    }
    if (media.uploadStatus !== MediaUploadStatus.READY) {
      throw new ConflictException(
        'Only completed media uploads can be approved',
      );
    }
    if (media.isApproved) return { id: mediaId, isApproved: true };

    const updated = await this.prisma.propertyMedia.updateMany({
      where: {
        id: mediaId,
        propertyId,
        uploadStatus: MediaUploadStatus.READY,
        isApproved: false,
        property: {
          is: { publicationStatus: PropertyPublicationStatus.IN_REVIEW },
        },
      },
      data: {
        isApproved: true,
        approvedById: moderator.id,
        approvedAt: new Date(),
      },
    });
    if (updated.count !== 1)
      throw new ConflictException(
        'Media or property status changed; reload the review',
      );
    await this.prisma.auditLog.create({
      data: {
        actorUserId: moderator.id,
        action: 'PROPERTY_MEDIA_APPROVED',
        objectType: 'PropertyMedia',
        objectId: mediaId,
        propertyId,
        after: { isApproved: true },
      },
    });
    return { id: mediaId, isApproved: true };
  }

  async rejectProperty(
    propertyId: string,
    moderator: AuthenticatedUser,
    input: ModerationDecisionDto,
  ) {
    return this.transitionModeration(
      propertyId,
      moderator,
      PropertyPublicationStatus.IN_REVIEW,
      PropertyPublicationStatus.REJECTED,
      input.reason,
    );
  }

  async requestPropertyChanges(
    propertyId: string,
    moderator: AuthenticatedUser,
    input: ModerationDecisionDto,
  ) {
    return this.transitionModeration(
      propertyId,
      moderator,
      PropertyPublicationStatus.IN_REVIEW,
      PropertyPublicationStatus.NEEDS_CHANGES,
      input.reason,
    );
  }

  async suspendProperty(
    propertyId: string,
    moderator: AuthenticatedUser,
    input: ModerationDecisionDto,
  ) {
    return this.transitionModeration(
      propertyId,
      moderator,
      PropertyPublicationStatus.PUBLISHED,
      PropertyPublicationStatus.SUSPENDED,
      input.reason,
    );
  }

  async restoreProperty(
    propertyId: string,
    moderator: AuthenticatedUser,
    input: ModerationDecisionDto,
  ) {
    return this.transitionModeration(
      propertyId,
      moderator,
      PropertyPublicationStatus.SUSPENDED,
      PropertyPublicationStatus.PUBLISHED,
      input.reason,
    );
  }

  private async listNearby(query: ListPropertiesDto) {
    const latitude = query.centerLatitude;
    const longitude = query.centerLongitude;
    const radiusKm = query.radiusKm;
    if (
      latitude === undefined ||
      longitude === undefined ||
      radiusKm === undefined
    ) {
      throw new BadRequestException(
        'centerLatitude, centerLongitude, and radiusKm must be provided together',
      );
    }

    const freshSince = new Date(
      Date.now() - GOOGLE_COORDINATE_CACHE_MAX_AGE_MS,
    );
    const filters = [
      Prisma.sql`p."publicationStatus"::text = ${PropertyPublicationStatus.PUBLISHED}`,
      Prisma.sql`p."availability"::text = ${'AVAILABLE'}`,
      Prisma.sql`EXISTS (SELECT 1 FROM "User" advertiser WHERE advertiser."id" = p."advertiserUserId" AND advertiser."accountStatus"::text = ${AccountStatus.ACTIVE})`,
      Prisma.sql`(p."ownerUserId" IS NULL OR EXISTS (SELECT 1 FROM "User" owner WHERE owner."id" = p."ownerUserId" AND owner."accountStatus"::text = ${AccountStatus.ACTIVE}))`,
      Prisma.sql`p."latitude" IS NOT NULL`,
      Prisma.sql`p."longitude" IS NOT NULL`,
      Prisma.sql`p."googleCoordinatesFetchedAt" >= ${freshSince}`,
      Prisma.sql`2 * 6371 * asin(sqrt(least(1,
        power(sin(radians(p."latitude" - ${latitude}) / 2), 2) +
        cos(radians(${latitude})) * cos(radians(p."latitude")) *
        power(sin(radians(p."longitude" - ${longitude}) / 2), 2)
      ))) <= ${radiusKm}`,
    ];
    if (query.category) {
      filters.push(Prisma.sql`p."category"::text = ${query.category}`);
    }
    if (query.operationType) {
      filters.push(
        Prisma.sql`p."operationType"::text = ${query.operationType}`,
      );
    }
    if (query.locationId) {
      filters.push(Prisma.sql`p."locationId" = ${query.locationId}`);
    }
    if (query.priceMin) {
      filters.push(Prisma.sql`p."price" >= ${query.priceMin}::numeric`);
    }
    if (query.priceMax) {
      filters.push(Prisma.sql`p."price" <= ${query.priceMax}::numeric`);
    }
    if (query.q?.trim()) {
      const searchTerm = `%${query.q.trim()}%`;
      filters.push(
        Prisma.sql`(p."title" ILIKE ${searchTerm} OR EXISTS (
          SELECT 1 FROM "Location" location
          WHERE location."id" = p."locationId" AND location."name" ILIKE ${searchTerm}
        ))`,
      );
    }

    const where = Prisma.join(filters, ' AND ');
    const [nearby, totalRows] = await Promise.all([
      this.prisma.$queryRaw<{ id: string; distance: number }[]>(
        Prisma.sql`
          SELECT p."id",
            2 * 6371 * asin(sqrt(least(1,
              power(sin(radians(p."latitude" - ${latitude}) / 2), 2) +
              cos(radians(${latitude})) * cos(radians(p."latitude")) *
              power(sin(radians(p."longitude" - ${longitude}) / 2), 2)
            ))) AS distance
          FROM "Property" p
          WHERE ${where}
          ORDER BY distance ASC, p."createdAt" DESC
          LIMIT ${query.pageSize}
          OFFSET ${(query.page - 1) * query.pageSize}
        `,
      ),
      this.prisma.$queryRaw<{ total: number }[]>(
        Prisma.sql`SELECT COUNT(*)::int AS total FROM "Property" p WHERE ${where}`,
      ),
    ]);

    const ids = nearby.map((item) => item.id);
    const properties = ids.length
      ? await this.prisma.property.findMany({
          where: { id: { in: ids } },
          select: publicPropertySelect,
        })
      : [];
    const itemsById = new Map(
      properties.map((property) => [property.id, property]),
    );
    const total = totalRows[0]?.total ?? 0;
    return {
      items: ids
        .map((id) => itemsById.get(id))
        .filter((property) => property !== undefined),
      pagination: {
        page: query.page,
        pageSize: query.pageSize,
        total,
        totalPages: Math.ceil(total / query.pageSize),
      },
    };
  }

  private async assertSelectableLocation(locationId: string): Promise<void> {
    const location = await this.prisma.location.findUnique({
      where: { id: locationId },
      select: { level: true },
    });
    if (
      !location ||
      (location.level !== LocationLevel.ARRONDISSEMENT &&
        location.level !== LocationLevel.NEIGHBORHOOD)
    ) {
      throw new NotFoundException(
        'Choose a valid arrondissement or neighborhood',
      );
    }
  }

  private assertAdvertiserRole(user: AuthenticatedUser): void {
    if (
      !user.roles.includes(UserRole.OWNER) &&
      !user.roles.includes(UserRole.AGENT)
    ) {
      throw new ForbiddenException(
        'An owner or agent profile is required to manage properties',
      );
    }
  }

  private async canManageProperty(
    userId: string,
    propertyId: string,
    advertiserUserId: string,
    ownerUserId: string | null,
  ): Promise<boolean> {
    if (userId === ownerUserId) return true;
    if (userId === advertiserUserId && ownerUserId === null) return true;
    const assignment = await this.prisma.propertyAssignment.findFirst({
      where: { propertyId, agentUserId: userId, revokedAt: null },
      select: { id: true },
    });
    return assignment !== null;
  }

  private async transitionModeration(
    propertyId: string,
    moderator: AuthenticatedUser,
    expectedStatus: PropertyPublicationStatus,
    nextStatus: PropertyPublicationStatus,
    reason?: string,
  ) {
    return this.prisma.$transaction(async (transaction) => {
      const changed = await transaction.property.updateMany({
        where: { id: propertyId, publicationStatus: expectedStatus },
        data: {
          publicationStatus: nextStatus,
          ...(nextStatus === PropertyPublicationStatus.PUBLISHED
            ? { publishedAt: new Date() }
            : {}),
        },
      });
      if (changed.count !== 1) {
        const exists = await transaction.property.findUnique({
          where: { id: propertyId },
          select: { id: true },
        });
        if (!exists) throw new NotFoundException('Property not found');
        throw new ConflictException(
          'The property status changed; reload the moderation queue',
        );
      }

      await transaction.propertyStatusHistory.create({
        data: {
          propertyId,
          status: nextStatus,
          reason,
          reviewerId: moderator.id,
        },
      });

      const owner = await transaction.property.findUniqueOrThrow({
        where: { id: propertyId },
        select: { advertiserUserId: true },
      });
      await transaction.auditLog.create({
        data: {
          actorUserId: moderator.id,
          action: 'PROPERTY_STATUS_CHANGED',
          objectType: 'Property',
          objectId: propertyId,
          reason,
          propertyId,
          before: { status: expectedStatus },
          after: { status: nextStatus },
        },
      });
      const notificationTypes: Partial<
        Record<PropertyPublicationStatus, NotificationType>
      > = {
        [PropertyPublicationStatus.PUBLISHED]:
          NotificationType.LISTING_APPROVED,
        [PropertyPublicationStatus.REJECTED]: NotificationType.LISTING_REJECTED,
        [PropertyPublicationStatus.NEEDS_CHANGES]:
          NotificationType.LISTING_NEEDS_CHANGES,
        [PropertyPublicationStatus.SUSPENDED]:
          NotificationType.LISTING_SUSPENDED,
      };
      const notificationType =
        nextStatus === PropertyPublicationStatus.PUBLISHED &&
        expectedStatus === PropertyPublicationStatus.SUSPENDED
          ? NotificationType.LISTING_RESTORED
          : notificationTypes[nextStatus];
      if (notificationType)
        await transaction.notification.create({
          data: {
            userId: owner.advertiserUserId,
            type: notificationType,
            title: 'Mise à jour de votre annonce',
            message:
              reason ??
              `Le statut de votre annonce est maintenant ${nextStatus}.`,
            propertyId,
          },
        });

      return transaction.property.findUniqueOrThrow({
        where: { id: propertyId },
        select: {
          id: true,
          slug: true,
          publicationStatus: true,
          publishedAt: true,
        },
      });
    });
  }

  private slugify(value: string): string {
    return (
      value
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-|-$/g, '')
        .slice(0, 80) || 'bien'
    );
  }

  private toMinorUnits(value: string): bigint {
    const [whole, fraction = ''] = value.split('.');
    return BigInt(whole) * 100n + BigInt(fraction.padEnd(2, '0'));
  }
}
