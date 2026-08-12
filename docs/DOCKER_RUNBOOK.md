# AI 吧唧 Docker 配置与操作指南

本地 Compose 栈包含 API、Worker、PostgreSQL、Valkey 和 MinIO。Valkey 是与 Redis
协议兼容的开源数据服务，用于 BullMQ 队列。这个栈用于开发和联调，
不是生产部署模板。API 当前仍使用内存业务数据，启动数据库和对象存储不代表已经完成
持久化接入。

## 一、准备 Docker 与环境变量

启动 Docker Desktop，等待 Docker Engine 就绪：

```bash
docker version
docker compose version
docker info
```

从仓库根目录创建本地配置：

```bash
cp infra/.env.example infra/.env
```

使用下面命令分别生成随机值，并把结果填入 `infra/.env`：

```bash
openssl rand -hex 32
```

至少替换 `POSTGRES_PASSWORD`、`JWT_SECRET`、`MINIO_ROOT_PASSWORD` 和
`DEMO_PASSWORD`。`infra/.env` 已被 Git 忽略，不要把内容放入 Issue、截图、日志或
聊天记录。

## 二、第一次启动

从仓库根目录执行：

```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml up --build -d
```

查看状态：

```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml ps
```

正常情况下，`api`、`postgres`、`redis`、`minio` 和 `worker` 都应处于运行状态；
PostgreSQL、Valkey 和 API 应显示 `healthy`。

## 三、服务地址

所有映射端口默认只监听 `127.0.0.1`：

| 服务 | 本机地址 |
|---|---|
| API | `http://127.0.0.1:3000/v1` |
| 健康检查 | `http://127.0.0.1:3000/v1/health` |
| Swagger | `http://127.0.0.1:3000/v1/docs`，需要 `ENABLE_SWAGGER=true` |
| MinIO API | `http://127.0.0.1:9000` |
| MinIO 控制台 | `http://127.0.0.1:9001` |

MinIO 登录信息来自 `infra/.env` 中的 `MINIO_ROOT_USER` 和
`MINIO_ROOT_PASSWORD`。

## 四、日常操作

启动已有容器：

```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml up -d
```

查看状态和日志：

```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml ps
docker compose --env-file infra/.env -f infra/docker-compose.yml logs -f
```

只看 API 和 Worker：

```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml logs -f api worker
```

停止但保留容器和数据：

```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml stop
```

删除容器和网络但保留数据卷：

```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml down
```

修改代码或依赖后重新构建：

```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml up --build -d
```

## 五、让 Flutter 连接容器 API

iOS Simulator：

```bash
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/v1
```

Android Emulator：

```bash
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1
```

登录账号和密码来自 `infra/.env` 的 `DEMO_USERNAME` 与 `DEMO_PASSWORD`。

## 六、数据与危险操作

`down` 默认保留 PostgreSQL、Valkey 和 MinIO 数据卷。下列操作可能永久删除本机测试
数据，除非已经确认目标和备份，否则不要执行：

```text
docker compose ... down -v
docker volume prune
docker system prune --volumes
```

## 七、常见问题

### 无法连接 Docker daemon

先打开 Docker Desktop，等待引擎启动，再执行 `docker info`。macOS 上 Docker CLI
通常位于 `/Applications/Docker.app/Contents/Resources/bin`。

### 端口被占用

```bash
lsof -nP -iTCP:3000 -sTCP:LISTEN
lsof -nP -iTCP:9000 -sTCP:LISTEN
lsof -nP -iTCP:9001 -sTCP:LISTEN
```

### 容器启动后退出

```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml ps -a
docker compose --env-file infra/.env -f infra/docker-compose.yml logs api worker
```

### 清理构建缓存

先用 `docker system df` 检查占用。删除缓存前确认命令不会涉及其他项目的数据。
