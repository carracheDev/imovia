import { IsBoolean, IsIn, IsString, Matches, MaxLength } from 'class-validator';

export class SubmitPropertyDto {
  @IsBoolean()
  authorizationConfirmed!: boolean;

  @IsString()
  @IsIn(['OWNER', 'AUTHORIZED_AGENT'])
  authorizationType!: 'OWNER' | 'AUTHORIZED_AGENT';

  @IsString()
  @Matches(/^[a-zA-Z0-9._-]{1,32}$/)
  @MaxLength(32)
  authorizationTermsVersion!: string;
}
