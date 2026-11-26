export const EMAIL_OTP_DELIVERY = Symbol('EMAIL_OTP_DELIVERY');

export interface EmailOtpDelivery {
  send(email: string, code: string): Promise<void>;
}
