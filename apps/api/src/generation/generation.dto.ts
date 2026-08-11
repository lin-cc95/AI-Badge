import { IsArray, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateGenerationTaskDto {
  @IsString()
  styleId: string;

  @IsString()
  personaId: string;

  @IsArray()
  @IsString({ each: true })
  tags: string[];

  @IsOptional()
  @IsString()
  @MaxLength(500)
  prompt?: string;

  @IsOptional()
  @IsString()
  referenceAssetId?: string;
}

