# AI Badge Flutter app

这是 AI Badge 的 Flutter iOS/Android 客户端。默认不传 `API_BASE_URL` 时使用离线
Mock，可以体验登录、角色生成、虚拟设备配对、同步、动作测试和对话流程。

iOS 构建需要完整 Xcode；Android 构建需要 Android Studio、Android SDK 和可用的
`ANDROID_HOME`。CI 会在 Linux Runner 上构建 Debug APK。

```bash
flutter pub get
flutter run
```

离线演示账号：`demo / Badge123!`。

连接本机 API：

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/v1
```

Android 模拟器应把宿主机地址改为 `http://10.0.2.2:3000/v1`。运行真实 BLE 前请
先阅读仓库根目录的 `docs/BLE_V1_GATE.md`。

验证：

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

许可证继承仓库根目录的 Apache-2.0。
