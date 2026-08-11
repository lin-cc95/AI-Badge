import { IsHexColor, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateCharacterDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  personaId: string;

  @IsString()
  @IsNotEmpty()
  styleId: string;

  @IsOptional()
  @IsHexColor()
  color?: string;
}

