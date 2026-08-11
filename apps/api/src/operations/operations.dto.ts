import { IsArray, IsIn, IsOptional, IsString } from 'class-validator';

export class DiagnosticDto {
  @IsString()
  deviceId: string;
  @IsString()
  appVersion: string;
  @IsString()
  systemVersion: string;
  @IsArray()
  @IsString({ each: true })
  includedFields: string[];
}

export class TelemetryDto {
  @IsString()
  name: string;
  @IsIn(['info', 'warning', 'error'])
  level: string;
  @IsOptional()
  properties?: Record<string, string | number | boolean | null>;
}

