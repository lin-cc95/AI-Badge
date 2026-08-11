# 页面、接口与验收追踪

| 流程 | 页面/组件 | API | 自动化重点 |
|---|---|---|---|
| 内测登录 | `LoginScreen` | `POST /v1/auth/login` | 正确/错误密码、刷新、日志脱敏 |
| 人格与角色 | `CreateScreen` | `GET /personas`、`POST /characters` | 结构化输入、确认后入库 |
| AI 生成 | `GenerationScreen` | `POST /generation-tasks`、SSE events | 后台恢复、审核、三候选、重试 |
| 设备绑定 | `DevicePairScreen` | `POST /devices/bindings` | 权限拒绝、已绑定、校验失败 |
| 内容同步 | `SyncScreen` | 本地 `DevicePort` | 10/50/90% 断开、哈希、最终回执 |
| 动作配置 | `ActionConfigScreen` | `PUT /action-bindings` | 去抖、离线、超时、实机 ACK |
| AI 对话 | `ChatScreen` | `POST /conversations/{id}/messages/stream` | 流式中断、情绪、审核、重试 |
| 设备管理 | `ProfileScreen` | `/firmware`、`/diagnostics` | 低电量、恢复、用户确认上传 |

