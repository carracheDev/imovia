import { IsString, Matches, MaxLength, MinLength } from 'class-validator';

export class AutocompleteDto {
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  input!: string;

  @IsString()
  @Matches(/^[A-Za-z0-9_-]{16,128}$/)
  sessionToken!: string;
}
