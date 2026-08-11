import { IsIn, IsOptional, IsString } from 'class-validator';

export class BindDeviceDto {
  @IsString()
  deviceId: string;
  @IsString()
  pairingToken: string;
}

export class ActionBindingDto {
  @IsString()
  deviceId: string;
  @IsIn(['tap', 'doubleTap', 'longPress', 'shake', 'lift'])
  eventType: string;
  @IsString()
  feedbackType: string;
  @IsOptional()
  @IsString()
  text?: string;
  @IsOptional()
  @IsString()
  assetId?: string;
}

