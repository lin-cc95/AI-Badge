# AI 吧唧

AI 吧唧是一套“AI 角色创作 + 随身 BLE 显示终端”的内测 MVP。当前仓库实现了第一条可演示纵向链路：

`内测登录 → 新手引导 → 角色生成 → 虚拟设备配对 → 资源同步 → 动作测试 → AI 对话`

## 已实现

- Flutter 设计系统与 8 组核心界面，采用浅色管理页 + 深色沉浸页。
- 明确的设备状态机和 `DevicePort`，内置可运行的虚拟设备适配器。
- NestJS 模块化 API、JWT/Argon2id 内测登录、标准错误结构和幂等写请求。
- 角色、生成任务 SSE、设备绑定、动作映射、对话 SSE、固件策略和诊断接口。
- PostgreSQL/Prisma 数据模型、Redis/BullMQ Worker、MinIO 与 Docker Compose。
- 独立虚拟设备 HTTP 工具，可注入断连、校验失败、低电量和存储不足。
- OpenAPI 3.1 契约、单元测试、UI/BLE/追踪文档。

真实 BLE 与 OTA 固件尚未实现：UUID、鉴权、命令帧、资源格式和恢复协议必须先由硬件方冻结，详见 `docs/BLE_V1_GATE.md`。

## 本地启动

第一次使用、日常启动、关闭、重启和常见故障，请先阅读：

- [iPhone 模拟器启动与关闭指南](docs/IOS_SIMULATOR_RUNBOOK.md)

### 后端

```bash
pnpm install
cp apps/api/.env.example apps/api/.env
pnpm --filter @ai-badge/api start:dev
```

API：`http://localhost:3000/v1`  
Swagger：`http://localhost:3000/v1/docs`  
健康检查：`http://localhost:3000/v1/health`

内测账号：`demo` / `Badge123!`

完整基础设施在安装 Docker 后运行：

```bash
docker compose --env-file infra/.env.example -f infra/docker-compose.yml up --build
```

### Flutter

需要 Flutter 3.44.7 或兼容的稳定版本。首次补齐原生工程目录：

```bash
cd apps/mobile
flutter create --platforms=ios,android --project-name ai_badge .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/v1
```

不传 `API_BASE_URL` 时，App 使用确定性 Mock 和内嵌虚拟设备，可完全离线演示。
Android 模拟器连接宿主机时请把地址改为 `http://10.0.2.2:3000/v1`；真机使用开发机局域网地址并配置允许的开发网络策略。

如果 `flutter create` 提示已有文件，保留现有 `lib/`、`test/`、`pubspec.yaml` 和 `analysis_options.yaml`。

### 虚拟设备服务

Flutter App 默认使用内嵌 `VirtualDeviceAdapter`。独立故障注入服务可通过以下命令启动：

```bash
pnpm --filter @ai-badge/virtual-device dev
curl -X POST http://localhost:4100/pair
curl -X POST http://localhost:4100/fault/disconnect
curl -X POST http://localhost:4100/sync
```

## 验证

```bash
pnpm build
pnpm test
cd apps/mobile && flutter analyze && flutter test
```

当前 iOS 模拟器流程已在 Flutter 3.44.9、Xcode 26.6 和 iOS 26.5 Simulator 上验证通过。
# AI-Badge
