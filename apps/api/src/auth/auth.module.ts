import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AuthController, UsersController } from './auth.controller.js';
import { AuthGuard } from './auth.guard.js';
import { AuthService } from './auth.service.js';
import { EmailOtpDeliveryService } from './email-otp-delivery.service.js';
import { EMAIL_OTP_DELIVERY } from './email-otp-delivery.js';
import { RolesGuard } from './roles.guard.js';

@Module({
  controllers: [AuthController, UsersController],
  providers: [
    AuthService,
    AuthGuard,
    RolesGuard,
    {
      provide: EMAIL_OTP_DELIVERY,
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const host = config.get<string>('SMTP_HOST');
        const from = config.get<string>('SMTP_FROM');
        if (!host || !from) {
          throw new Error(
            'Email OTP requires SMTP_HOST and SMTP_FROM to be configured.',
          );
        }
        return new EmailOtpDeliveryService(config);
      },
    },
  ],
  exports: [AuthService, AuthGuard, RolesGuard],
})
export class AuthModule {}
