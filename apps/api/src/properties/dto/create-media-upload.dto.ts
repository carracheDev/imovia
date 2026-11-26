import { IsIn } from 'class-validator';

export class CreateMediaUploadDto {
  @IsIn(['image/jpeg', 'image/png', 'image/webp'])
  contentType!: string;
}
