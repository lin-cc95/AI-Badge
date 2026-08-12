# AI 吧唧 iPhone 模拟器启动与关闭指南

本文档适用于从任意目录克隆的 AI Badge 仓库，不依赖某个用户名、Flutter 安装路径
或固定的模拟器型号。

## 一、首次检查

安装完整 Xcode、Flutter 稳定版和 CocoaPods，然后执行：

```bash
xcodebuild -version
flutter doctor -v
flutter devices
```

`xcodebuild` 的开发目录应来自完整 Xcode，而不是单独的 Command Line Tools。必要时：

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

首次安装 iOS Runtime 可在 `Xcode → Settings → Components` 中完成。

## 二、启动 App

从仓库根目录执行：

```bash
open -a Simulator
cd apps/mobile
flutter pub get
flutter run
```

如果有多个设备，先查看设备 ID：

```bash
flutter devices
```

然后把下面的 `DEVICE_ID` 替换为列表中的实际 ID：

```bash
flutter run -d DEVICE_ID
```

终端出现以下提示表示调试已启动：

```text
Flutter run key commands.
r Hot reload.
R Hot restart.
q Quit.
```

App 默认使用离线 Mock，不需要 API 或 Docker。离线账号为 `demo`，密码为
`Badge123!`。

## 三、开发快捷键

保持 `flutter run` 的终端处于运行状态：

| 按键 | 作用 |
|---|---|
| `r` | 热重载界面与大多数 Dart 代码 |
| `R` | 完整重启 App |
| `d` | 断开调试但保留 App |
| `q` | 停止 App 并退出调试 |
| `h` | 显示帮助 |

这些按键不需要 `Command`，通常也不需要回车。

## 四、关闭与重启

只停止 Flutter 调试：在运行终端按 `q`。

终端已经关闭时，可以停止当前模拟器中的 App：

```bash
xcrun simctl terminate booted com.aibadge.aiBadge
```

只关闭 Simulator 窗口：按 `Command + Q`。完全关闭虚拟设备：

```bash
xcrun simctl shutdown booted
```

模拟器卡住时：

```bash
xcrun simctl shutdown all
open -a Simulator
```

然后回到仓库根目录重新运行：

```bash
cd apps/mobile
flutter run
```

## 五、再次打开已经安装的 App

不需要重新编译时：

```bash
open -a Simulator
xcrun simctl launch --terminate-running-process booted com.aibadge.aiBadge
```

如果提示没有 booted device，请先在 Simulator 的 `File → Open Simulator` 中选择
一个设备，或使用 `xcrun simctl list devices available` 查看可用设备。

## 六、连接本机 API

先在仓库根目录启动 API：

```bash
pnpm --filter @ai-badge/api start:dev
```

另开一个终端，从仓库根目录执行：

```bash
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/v1
```

此时登录凭据来自 `apps/api/.env`，不一定是离线 Mock 的密码。

## 七、常见问题

### `open -a Simulator` 没有输出

成功时通常没有终端输出。检查 Dock、使用 `Command + Tab`，或执行：

```bash
xcrun simctl list devices booted
```

### `xcodebuild requires Xcode`

说明当前开发目录仍指向 Command Line Tools：

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
xcodebuild -version
```

### `flutter: command not found`

把你实际安装的 Flutter `bin` 目录加入 shell 的 `PATH`。例如通过 Homebrew 安装时，
重新打开终端后通常会自动生效。用下面命令确认：

```bash
command -v flutter
flutter --version
```

### CocoaPods 或 Pod 安装失败

```bash
cd apps/mobile/ios
pod install --repo-update
cd ..
flutter clean
flutter pub get
flutter run
```

### App 显示网络错误

不传 `API_BASE_URL` 可回到离线 Mock。连接 API 时确认健康检查可访问：

```bash
curl http://127.0.0.1:3000/v1/health
```
