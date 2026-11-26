import {
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';
import { ReportStatus } from '../../generated/prisma/enums.js';
export class ReportStatusDto {
  @IsEnum(ReportStatus) status!: ReportStatus;
  @IsOptional() @IsString() @MinLength(5) @MaxLength(1000) reason?: string;
}
