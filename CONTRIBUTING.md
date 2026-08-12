# Contributing

感谢你参与 AI Badge。提交代码即表示你有权贡献该内容，并同意按照
Apache License 2.0 授权该贡献。

## 开始开发

1. Fork 仓库并从 `main` 创建功能分支。
2. 安装 Node.js 24、pnpm 11.16 和 Flutter 稳定版。
3. 执行 `pnpm install --frozen-lockfile`。
4. 修改代码并补充与风险相称的测试。
5. 提交前执行下方验证命令。

```bash
pnpm build
pnpm lint
pnpm test
pnpm test:e2e
pnpm audit:prod

cd apps/mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## 提交要求

- 一个 Pull Request 聚焦一个问题。
- 不提交 `.env`、密钥、用户数据、真实对话或未获授权的图片。
- 新增接口时同步更新 `packages/openapi/openapi.yaml`。
- 新增依赖时说明用途和许可证，并更新第三方声明。
- BLE 协议改动必须满足 `docs/BLE_V1_GATE.md` 的冻结要求。

安全问题不要提交公开 Issue，请按照 `SECURITY.md` 报告。
