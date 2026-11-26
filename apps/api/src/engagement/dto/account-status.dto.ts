import { IsEnum, IsString, MaxLength, MinLength } from 'class-validator';
import { AccountStatus } from '../../generated/prisma/enums.js';
export class AccountStatusDto {
  @IsEnum(AccountStatus) status!: AccountStatus;
  @IsString() @MinLength(5) @MaxLength(1000) reason!: string;
}
