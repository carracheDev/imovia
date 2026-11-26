import { IsEnum } from 'class-validator';
import { PropertyAvailability } from '../../generated/prisma/enums.js';
export class UpdateAvailabilityDto {
  @IsEnum(PropertyAvailability) availability!: PropertyAvailability;
}
