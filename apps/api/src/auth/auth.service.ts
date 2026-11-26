import {
  Injectable,
  BadRequestException,
  HttpException,
  HttpStatus,
  Logger,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common';
import { Inject } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  createHash,
  createHmac,
  randomBytes,
  randomInt,
  timingSafeEqual,
} from 'node:crypto';
import type { UserRole } from '../generated/prisma/client.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { AuthenticatedUser } from './authenticated-user.js';
import type { UpdateProfileDto } from './dto/update-profile.dto.js';
import { EMAIL_OTP_DELIVERY } from './email-otp-delivery.js';
import type { EmailOtpDelivery } from './email-otp-delivery.js';

const OTP_LIFETIME_MS = 5 * 60 * 1000;
const OTP_RESEND_DELAY_MS = 60 * 1000;
const OTP_WINDOW_MS = 60 * 60 * 1000;
const MAX_OTP_REQUESTS_PER_HOUR = 5;
const MAX_OTP_ATTEMPTS = 5;
const SESSION_LIFETIME_MS = 30 * 24 * 60 * 60 * 1000;
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const OTP_PATTERN = /^\d{6}$/;

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly otpPepper: string;

  constructor(
    private readonly prisma: PrismaService,
    config: ConfigService,
    @Inject(EMAIL_OTP_DELIVERY)
    private readonly emailOtpDelivery: EmailOtpDelivery,
  ) {
    this.otpPepper = config.getOrThrow<string>('AUTH_OTP_PEPPER');
    if (Buffer.byteLength(this.otpPepper, 'utf8') < 32) {
      throw new Error('AUTH_OTP_PEPPER must contain at least 32 bytes');
    }
  }

  async requestOtp(emailInput: string): Promise<{ message: string }> {
    const email = this.normalizeEmail(emailInput);
    const now = new Date();
    const challenge = await this.prisma.$transaction(async (transaction) => {
      await transaction.$queryRaw`
        WITH lock_result AS MATERIALIZED (
          SELECT pg_advisory_xact_lock(hashtext(${email}))
        )
        SELECT TRUE AS locked FROM lock_result
      `;

      const recentChallenges = await transaction.otpChallenge.count({
        where: {
          email,
          createdAt: { gte: new Date(now.getTime() - OTP_WINDOW_MS) },
        },
      });
      if (recentChallenges >= MAX_OTP_REQUESTS_PER_HOUR) {
        throw new HttpException(
          'Too many verification requests. Please try again later.',
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }

      const latestChallenge = await transaction.otpChallenge.findFirst({
        where: {
          email,
          createdAt: { gte: new Date(now.getTime() - OTP_RESEND_DELAY_MS) },
        },
        orderBy: { createdAt: 'desc' },
        select: { id: true },
      });
      if (latestChallenge) {
        throw new HttpException(
          'Please wait before requesting another verification code.',
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }

      await transaction.otpChallenge.updateMany({
        where: { email, consumedAt: null },
        data: { consumedAt: now },
      });

      const code = randomInt(0, 1_000_000).toString().padStart(6, '0');
      const created = await transaction.otpChallenge.create({
        data: {
          email,
          codeHash: this.hashOtp(email, code),
          expiresAt: new Date(now.getTime() + OTP_LIFETIME_MS),
        },
        select: { id: true },
      });
      return { id: created.id, code };
    });

    try {
      await this.emailOtpDelivery.send(email, challenge.code);
    } catch (error) {
      await this.prisma.otpChallenge.updateMany({
        where: { id: challenge.id, consumedAt: null },
        data: { consumedAt: new Date() },
      });
      this.logger.error('Email OTP delivery failed', error);
      throw new ServiceUnavailableException(
        'Unable to deliver the verification code email',
        {
          cause: error,
        },
      );
    }

    return {
      message:
        'If this address can receive email, a verification code was sent.',
    };
  }

  async verifyOtp(
    emailInput: string,
    code: string,
  ): Promise<{
    sessionToken: string;
    expiresAt: Date;
    user: Omit<AuthenticatedUser, 'sessionId'>;
  }> {
    const email = this.normalizeEmail(emailInput);
    if (!OTP_PATTERN.test(code)) {
      throw new UnauthorizedException(
        'The verification code is invalid or expired',
      );
    }

    const now = new Date();
    const sessionToken = randomBytes(32).toString('base64url');
    const sessionTokenHash = this.hashToken(sessionToken);
    const expiresAt = new Date(now.getTime() + SESSION_LIFETIME_MS);

    const result = await this.prisma.$transaction(async (transaction) => {
      const challenge = await transaction.otpChallenge.findFirst({
        where: {
          email,
          consumedAt: null,
          expiresAt: { gt: now },
          attempts: { lt: MAX_OTP_ATTEMPTS },
        },
        orderBy: { createdAt: 'desc' },
        select: { id: true, codeHash: true },
      });
      if (!challenge) {
        return { invalid: true as const };
      }

      const suppliedHash = this.hashOtp(email, code);
      if (!this.safeHashEquals(challenge.codeHash, suppliedHash)) {
        await transaction.otpChallenge.updateMany({
          where: {
            id: challenge.id,
            consumedAt: null,
            expiresAt: { gt: now },
            attempts: { lt: MAX_OTP_ATTEMPTS },
          },
          data: { attempts: { increment: 1 } },
        });
        return { invalid: true as const };
      }

      const consumed = await transaction.otpChallenge.updateMany({
        where: {
          id: challenge.id,
          codeHash: suppliedHash,
          consumedAt: null,
          expiresAt: { gt: now },
          attempts: { lt: MAX_OTP_ATTEMPTS },
        },
        data: { consumedAt: now },
      });
      if (consumed.count !== 1) {
        return { invalid: true as const };
      }

      const user = await transaction.user.upsert({
        where: { email },
        create: { email, emailVerifiedAt: now },
        update: { emailVerifiedAt: now },
        select: {
          id: true,
          email: true,
          firstName: true,
          lastName: true,
          roles: true,
          accountStatus: true,
        },
      });
      const session = await transaction.session.create({
        data: { userId: user.id, tokenHash: sessionTokenHash, expiresAt },
        select: { id: true },
      });
      return { user, sessionId: session.id, invalid: false as const };
    });

    if (result.invalid) {
      throw new UnauthorizedException(
        'The verification code is invalid or expired',
      );
    }

    return { sessionToken, expiresAt, user: result.user };
  }

  async getUserForToken(token: string): Promise<AuthenticatedUser> {
    if (!/^[A-Za-z0-9_-]{43}$/.test(token)) {
      throw new UnauthorizedException('The session is invalid or expired');
    }
    const session = await this.prisma.session.findFirst({
      where: {
        tokenHash: this.hashToken(token),
        revokedAt: null,
        expiresAt: { gt: new Date() },
      },
      select: {
        id: true,
        user: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
            roles: true,
            accountStatus: true,
          },
        },
      },
    });
    if (!session) {
      throw new UnauthorizedException('The session is invalid or expired');
    }
    if (session.user.accountStatus !== 'ACTIVE') {
      throw new UnauthorizedException('This account is suspended');
    }
    return { ...session.user, sessionId: session.id };
  }

  async revokeSession(user: AuthenticatedUser): Promise<{ message: string }> {
    await this.prisma.session.updateMany({
      where: { id: user.sessionId, userId: user.id, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return { message: 'Session closed' };
  }

  async updateProfile(
    user: AuthenticatedUser,
    input: UpdateProfileDto,
  ): Promise<{
    id: string;
    email: string | null;
    firstName: string | null;
    lastName: string | null;
    roles: UserRole[];
    ownerProfile: { displayName: string | null } | null;
    agentProfile: {
      displayName: string | null;
      businessName: string | null;
    } | null;
  }> {
    return this.prisma.$transaction(async (transaction) => {
      const existing = await transaction.user.findUniqueOrThrow({
        where: { id: user.id },
        select: { roles: true },
      });
      const roles =
        input.role && !existing.roles.includes(input.role)
          ? [...existing.roles, input.role]
          : existing.roles;
      const updated = await transaction.user.update({
        where: { id: user.id },
        data: {
          firstName: input.firstName,
          lastName: input.lastName,
          roles,
        },
        select: {
          id: true,
          email: true,
          firstName: true,
          lastName: true,
          roles: true,
        },
      });

      if (input.role === 'OWNER') {
        await transaction.ownerProfile.upsert({
          where: { userId: user.id },
          create: { userId: user.id, displayName: input.displayName },
          update: { displayName: input.displayName },
        });
      }
      if (input.role === 'AGENT') {
        await transaction.agentProfile.upsert({
          where: { userId: user.id },
          create: {
            userId: user.id,
            displayName: input.displayName,
            businessName: input.businessName,
          },
          update: {
            displayName: input.displayName,
            businessName: input.businessName,
          },
        });
      }

      const [ownerProfile, agentProfile] = await Promise.all([
        transaction.ownerProfile.findUnique({
          where: { userId: user.id },
          select: { displayName: true },
        }),
        transaction.agentProfile.findUnique({
          where: { userId: user.id },
          select: { displayName: true, businessName: true },
        }),
      ]);

      return { ...updated, ownerProfile, agentProfile };
    });
  }

  private normalizeEmail(email: string): string {
    const normalized = email.trim().toLowerCase();
    if (normalized.length > 254 || !EMAIL_PATTERN.test(normalized)) {
      throw new BadRequestException('A valid email address is required');
    }
    return normalized;
  }

  private hashOtp(email: string, code: string): string {
    return createHmac('sha256', this.otpPepper)
      .update(`${email}:${code}`)
      .digest('hex');
  }

  private hashToken(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }

  private safeHashEquals(expected: string, actual: string): boolean {
    const expectedBytes = Buffer.from(expected, 'hex');
    const actualBytes = Buffer.from(actual, 'hex');
    return (
      expectedBytes.length === actualBytes.length &&
      timingSafeEqual(expectedBytes, actualBytes)
    );
  }
}
