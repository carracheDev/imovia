import { IsString, MaxLength, MinLength } from 'class-validator';

export class AssignAgentDto {
  @IsString() @MinLength(1) @MaxLength(64) agentUserId!: string;
  @IsString() @MinLength(10) @MaxLength(1000) authorization!: string;
  @IsString() @MinLength(1) @MaxLength(32) termsVersion!: string;
}
