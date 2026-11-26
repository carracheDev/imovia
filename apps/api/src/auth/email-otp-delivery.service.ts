import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import nodemailer from 'nodemailer';
import type { EmailOtpDelivery } from './email-otp-delivery.js';
import type { Transporter } from 'nodemailer';

@Injectable()
export class EmailOtpDeliveryService implements EmailOtpDelivery {
  private readonly transporter: Transporter;
  private readonly from: string;

  constructor(config: ConfigService) {
    const host = config.getOrThrow<string>('SMTP_HOST');
    const port = Number(config.get<string>('SMTP_PORT', '1025'));
    if (!Number.isInteger(port) || port < 1 || port > 65535) {
      throw new Error('SMTP_PORT must be a valid TCP port');
    }
    const secure = config.get<string>('SMTP_SECURE') === 'true';
    const requireTls = config.get<string>('SMTP_REQUIRE_TLS') === 'true';
    if (
      config.get<string>('NODE_ENV') === 'production' &&
      !secure &&
      !requireTls
    ) {
      throw new Error('Production email delivery must require TLS');
    }
    const user = config.get<string>('SMTP_USER');
    const pass = config.get<string>('SMTP_PASSWORD');
    if (Boolean(user) !== Boolean(pass)) {
      throw new Error(
        'SMTP_USER and SMTP_PASSWORD must be configured together',
      );
    }
    this.from = config.getOrThrow<string>('SMTP_FROM');
    this.transporter = nodemailer.createTransport({
      host,
      port,
      secure,
      requireTLS: secure || requireTls,
      ...(user && pass ? { auth: { user, pass } } : {}),
    });
  }

  async send(email: string, code: string): Promise<void> {
    await this.transporter.sendMail({
      from: this.from,
      to: email,
      subject: 'Votre code de vérification CARANOVA',
      text: `Votre code de vérification CARANOVA est ${code}. Il expire dans 5 minutes.`,
      html: `<p>Votre code de vérification CARANOVA :</p><p style="font-size:24px;font-weight:bold;letter-spacing:4px">${code}</p><p>Ce code expire dans 5 minutes. Si vous n'êtes pas à l'origine de cette demande, ignorez cet email.</p>`,
    });
  }
}
