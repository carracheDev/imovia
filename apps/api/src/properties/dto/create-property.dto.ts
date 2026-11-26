import { Transform } from 'class-transformer';
import {
  IsEnum,
  IsBoolean,
  IsNumberString,
  IsObject,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';
import {
  OperationType,
  PropertyCategory,
} from '../../generated/prisma/enums.js';

export class CreatePropertyDto {
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @MinLength(5)
  @MaxLength(120)
  title!: string;

  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @MinLength(20)
  @MaxLength(5000)
  description!: string;

  @IsEnum(PropertyCategory)
  category!: PropertyCategory;

  @IsEnum(OperationType)
  operationType!: OperationType;

  @IsOptional()
  @IsString()
  @IsNumberString()
  @Matches(/^\d{1,12}(?:\.\d{1,2})?$/)
  @MaxLength(15)
  price?: string;

  @IsOptional()
  @IsString()
  @MaxLength(32)
  locationId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  googlePlaceId?: string;

  @IsOptional() @IsString() @MaxLength(64) ownerUserId?: string;
  @IsOptional() @IsString() @MaxLength(160) ownerDisplayName?: string;
  @IsOptional() @IsObject() details?: Record<string, unknown>;
  @IsOptional() @IsString() @MaxLength(32) contactPhone?: string;
  @IsOptional() @IsString() @MaxLength(32) contactWhatsApp?: string;
  @IsOptional() @IsString() @MaxLength(1000) visitInstructions?: string;
  @IsOptional() @IsBoolean() allowPhoneContact?: boolean;
  @IsOptional() @IsBoolean() allowWhatsAppContact?: boolean;
}
