import { createServer } from 'node:http';

type DeviceStatus = 'UNBOUND' | 'SCANNING' | 'PAIRING' | 'CONNECTED' | 'TRANSFERRING' | 'OFFLINE' | 'UPGRADING' | 'RECOVERY';
type Fault = 'none' | 'packet-loss' | 'timeout' | 'bad-ack' | 'checksum' | 'low-battery' | 'storage-full' | 'disconnect';

const state = {
  id: 'sim-badge-001',
  model: 'SIM-240',
  status: 'UNBOUND' as DeviceStatus,
  battery: 86,
  storage: { used: 12_582_912, total: 67_108_864 },
  firmware: '0.1.0-sim',
  rssi: -48,
  progress: 0,
  activeFault: 'none' as Fault,
  lastEvent: null as string | null,
};

const json = (response: import('node:http').ServerResponse, status: number, body: unknown) => {
  response.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
  response.end(JSON.stringify(body));
};

const server = createServer(async (request, response) => {
  const url = new URL(request.url ?? '/', 'http://localhost');
  if (request.method === 'GET' && url.pathname === '/state') return json(response, 200, state);
  if (request.method === 'POST' && url.pathname === '/reset') {
    Object.assign(state, { status: 'UNBOUND', progress: 0, activeFault: 'none', battery: 86, lastEvent: null });
    return json(response, 200, state);
  }
  if (request.method === 'POST' && url.pathname === '/pair') {
    state.status = 'SCANNING';
    await new Promise((resolve) => setTimeout(resolve, 200));
    state.status = 'PAIRING';
    await new Promise((resolve) => setTimeout(resolve, 200));
    state.status = 'CONNECTED';
    return json(response, 200, state);
  }
  if (request.method === 'POST' && url.pathname === '/sync') {
    if (state.status !== 'CONNECTED') return json(response, 409, { code: 'BLE-104', message: '设备未连接' });
    if (state.activeFault === 'low-battery') return json(response, 409, { code: 'TRF-LOW-BATTERY', message: '设备电量不足' });
    if (state.activeFault === 'storage-full') return json(response, 409, { code: 'TRF-STORAGE-FULL', message: '设备存储空间不足' });
    state.status = 'TRANSFERRING';
    for (let chunk = 1; chunk <= 10; chunk++) {
      await new Promise((resolve) => setTimeout(resolve, 80));
      state.progress = chunk / 10;
      if (state.activeFault === 'disconnect' && chunk === 5) {
        state.status = 'OFFLINE';
        return json(response, 503, { code: 'TRF-301', message: '同步中断，可以从第 5 个分片继续', resumeChunk: chunk });
      }
      if (state.activeFault === 'checksum' && chunk === 9) {
        state.status = 'CONNECTED';
        return json(response, 422, { code: 'TRF-CHECKSUM', message: '文件校验失败' });
      }
    }
    state.status = 'CONNECTED';
    return json(response, 200, { ...state, receipt: 'SAVED_AND_LOADED' });
  }
  if (request.method === 'POST' && url.pathname.startsWith('/event/')) {
    if (state.status !== 'CONNECTED') return json(response, 409, { code: 'BLE-104', message: '设备未连接' });
    state.lastEvent = url.pathname.split('/').at(-1) ?? null;
    return json(response, 200, { acknowledged: true, event: state.lastEvent, latencyMs: 34 });
  }
  if (request.method === 'POST' && url.pathname.startsWith('/fault/')) {
    const fault = url.pathname.split('/').at(-1) as Fault;
    const allowed: Fault[] = ['none', 'packet-loss', 'timeout', 'bad-ack', 'checksum', 'low-battery', 'storage-full', 'disconnect'];
    if (!allowed.includes(fault)) return json(response, 400, { message: '未知故障类型', allowed });
    state.activeFault = fault;
    if (fault === 'low-battery') state.battery = 8;
    return json(response, 200, state);
  }
  return json(response, 404, { message: 'Not Found' });
});

const port = Number(process.env.VIRTUAL_DEVICE_PORT ?? 4100);
const host = process.env.VIRTUAL_DEVICE_HOST ?? '127.0.0.1';
server.listen(port, host, () => console.info(`AI Badge virtual device listening on http://${host}:${port}`));
