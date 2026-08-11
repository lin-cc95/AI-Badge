import { Body, Controller, Get, Param, Post, Put } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

import { ActionBindingDto, BindDeviceDto } from './devices.dto';
import { DevicesService } from './devices.service';

@ApiTags('devices')
@Controller()
export class DevicesController {
  constructor(private readonly devices: DevicesService) {}
  @Get('devices') list() { return this.devices.list(); }
  @Post('devices/bindings') bind(@Body() input: BindDeviceDto) { return this.devices.bind(input); }
  @Get('devices/:id/action-bindings') listActions(@Param('id') id: string) { return this.devices.listActions(id); }
  @Put('action-bindings') upsertAction(@Body() input: ActionBindingDto) { return this.devices.upsertAction(input); }
}

