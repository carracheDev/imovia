import { IsEmail, IsString, MaxLength } from 'class-validator';

export class RequestOtpDto {
  @IsString()
  @IsEmail()
  @MaxLength(254)
  email!: string;
}
