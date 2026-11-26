import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';
import { ReportCategory } from '../../generated/prisma/enums.js';

export class CreateReportDto {
  @IsEnum(ReportCategory) category!: ReportCategory;
  @IsString() @MinLength(10) @MaxLength(2000) description!: string;
  @IsOptional() @IsEmail() @MaxLength(254) reporterEmail?: string;
}
