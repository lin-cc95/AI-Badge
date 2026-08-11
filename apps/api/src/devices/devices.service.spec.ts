import { DevicesService } from './devices.service';

describe('DevicesService', () => {
  it('binds a simulator and stores an action mapping', () => {
    const service = new DevicesService();
    service.bind({ deviceId: 'sim-badge-001', pairingToken: 'demo' });
    const action = service.upsertAction({ deviceId: 'sim-badge-001', eventType: 'tap', feedbackType: 'emotion', text: '嗨' });
    expect(action.version).toBe(1);
    expect(service.listActions('sim-badge-001').items).toHaveLength(1);
  });
});

