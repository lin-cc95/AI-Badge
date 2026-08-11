import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';

import { ActionBindingDto, BindDeviceDto } from './devices.dto';

@Injectable()
export class DevicesService {
  private device: Record<string, unknown> | null = null;
  private readonly actions = new Map<string, ActionBindingDto>();

  list() { return { items: this.device ? [this.device] : [] }; }

  bind(input: BindDeviceDto) {
    if (this.device && this.device.id !== input.deviceId) throw new ConflictException('当前账号已经绑定其他设备');
    this.device = {
      id: input.deviceId,
      model: 'SIM-240',
      name: 'AI Badge Sim',
      status: 'CONNECTED',
      battery: 86,
      storage: { used: 12_582_912, total: 67_108_864 },
      firmware: '0.1.0-sim',
      lastSeenAt: new Date().toISOString(),
    };
    return { device: this.device, binding: { ownerId: 'user-demo', boundAt: new Date().toISOString() } };
  }

  upsertAction(input: ActionBindingDto) {
    if (!this.device) throw new NotFoundException('请先绑定设备');
    this.actions.set(`${input.deviceId}:${input.eventType}`, input);
    return { ...input, version: 1, updatedAt: new Date().toISOString() };
  }

  listActions(deviceId: string) {
    return { items: [...this.actions.values()].filter((item) => item.deviceId === deviceId) };
  }
}

