# AI 吧唧 iPhone 模拟器启动与关闭指南

本文档用于在当前 Mac 上通过 iPhone 模拟器运行 AI 吧唧 Flutter App。

当前已经配置并验证：

- Flutter SDK：`/Users/chen/flutter`
- Xcode：`/Applications/Xcode.app`
- 模拟器：`iPhone 17 Pro`，iOS 26.5
- App Bundle ID：`com.aibadge.aiBadge`
- 项目目录：`/Users/chen/work/AI-Badge/apps/mobile`
- CocoaPods：已安装

## 一、每天启动 App

### 方法一：完整启动，适合日常开发

打开 macOS“终端”，或者在 VS Code 中选择 `Terminal → New Terminal`，依次执行：

```bash
open -a Simulator

cd /Users/chen/work/AI-Badge/apps/mobile
flutter run -d "iPhone 17 Pro"
```

等待终端出现以下内容后，App 就已经启动：

```text
Flutter run key commands.
r Hot reload.
R Hot restart.
q Quit.
```

如果 Simulator 没有自动显示在最前面，可以：

1. 点击 Dock 中的 Simulator 图标。
2. 按 `Command + Tab` 切换到 Simulator。
3. 在 Xcode 中选择 `Xcode → Open Developer Tool → Simulator`。

### 方法二：只打开已经安装的 App

没有修改代码，只想再次查看界面时执行：

```bash
open -a Simulator
xcrun simctl launch --terminate-running-process booted com.aibadge.aiBadge
```

这个方法不会重新编译，启动速度更快。

如果提示没有已启动的设备，先执行：

```bash
xcrun simctl boot "iPhone 17 Pro"
open -a Simulator
xcrun simctl launch booted com.aibadge.aiBadge
```

## 二、登录与体验

App 默认以 Mock 模式运行，不需要启动后端或 Docker。

```text
账号：demo
密码：Badge123!
```

Mock 模式可以体验：

- 内测账号登录与新手引导
- AI 角色风格和人格选择
- 模拟 AI 生成进度
- 虚拟设备绑定与同步
- 动作配置和设备测试
- AI 对话与情绪反馈界面

## 三、开发时的快捷操作

保持 `flutter run` 所在终端处于运行状态，然后在该终端按键：

| 按键 | 作用 | 什么时候使用 |
|---|---|---|
| `r` | 热重载 | 修改文字、颜色、间距和多数页面代码后使用 |
| `R` | 完整重启 App | 修改初始化逻辑或热重载未生效时使用 |
| `d` | 断开调试 | 关闭终端连接，但让 App 继续在模拟器运行 |
| `q` | 停止 App | 结束本次 Flutter 调试运行 |
| `h` | 显示帮助 | 忘记快捷键时使用 |

注意：这里直接输入单个字母，不需要按 `Command`，通常也不需要按回车。

## 四、关闭 App

### 只关闭 AI 吧唧，保留虚拟 iPhone

如果 `flutter run` 的终端还在运行，在该终端按：

```text
q
```

如果终端已经关闭，执行：

```bash
xcrun simctl terminate booted com.aibadge.aiBadge
```

这种方式只停止 App，Simulator 仍然可以使用。

### 只关闭 Simulator 窗口

在 Simulator 中按：

```text
Command + Q
```

也可以在终端执行：

```bash
killall Simulator
```

关闭窗口不一定会关闭虚拟 iPhone 的后台状态。

### 完全关闭虚拟 iPhone 和 Simulator

执行：

```bash
xcrun simctl shutdown booted
killall Simulator
```

如果 `killall Simulator` 提示没有找到进程，表示窗口本来就已经关闭，可以忽略。

## 五、重启

### 代码修改后的重启

如果 `flutter run` 仍在运行，直接按大写：

```text
R
```

如果已经退出，重新执行：

```bash
open -a Simulator

cd /Users/chen/work/AI-Badge/apps/mobile
flutter run -d "iPhone 17 Pro"
```

### App 卡住时强制重启

```bash
xcrun simctl launch --terminate-running-process booted com.aibadge.aiBadge
```

### 模拟器卡住时重启

```bash
xcrun simctl shutdown booted
xcrun simctl boot "iPhone 17 Pro"
open -a Simulator
```

然后重新运行项目：

```bash
cd /Users/chen/work/AI-Badge/apps/mobile
flutter run -d "iPhone 17 Pro"
```

## 六、连接真实后端（可选）

日常查看界面不需要后端。只有需要验证真实 API 时才使用本节。

在第一个终端启动后端：

```bash
cd /Users/chen/work/AI-Badge
pnpm --filter @ai-badge/api start:dev
```

在第二个终端启动 iOS App：

```bash
cd /Users/chen/work/AI-Badge/apps/mobile
flutter run -d "iPhone 17 Pro" \
  --dart-define=API_BASE_URL=http://127.0.0.1:3000/v1
```

后端接口文档：

```text
http://127.0.0.1:3000/v1/docs
```

退出后端时，在后端终端按：

```text
Control + C
```

## 七、常见问题

### 1. `open -a Simulator` 没有输出

这是正常现象。`open` 成功时通常不会在终端打印文字。检查 Dock、使用 `Command + Tab`，或者执行：

```bash
xcrun simctl list devices booted
```

### 2. 提示找不到 iPhone 17 Pro

检查设备：

```bash
flutter devices
xcrun simctl list devices available
```

启动设备：

```bash
xcrun simctl boot "iPhone 17 Pro"
open -a Simulator
```

### 3. `flutter: command not found`

当前 Flutter 位于 `/Users/chen/flutter/bin`。临时恢复：

```bash
export PATH="/Users/chen/flutter/bin:$PATH"
flutter --version
```

需要永久生效时，在 `~/.zprofile` 中加入：

```bash
export PATH="$HOME/flutter/bin:$PATH"
```

然后重新打开终端。

### 4. App 已安装但没有显示

```bash
open -a Simulator
xcrun simctl launch --terminate-running-process booted com.aibadge.aiBadge
```

### 5. 构建依赖异常

先执行：

```bash
cd /Users/chen/work/AI-Badge/apps/mobile
flutter pub get
flutter run -d "iPhone 17 Pro"
```

只有仍然失败时，再执行完整重建：

```bash
cd /Users/chen/work/AI-Badge/apps/mobile
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run -d "iPhone 17 Pro"
```

### 6. 检查环境是否正常

```bash
flutter doctor -v
flutter devices
```

正常情况下，设备列表中应包含：

```text
iPhone 17 Pro • ios • simulator
```

## 八、最常用命令速查

启动并编译：

```bash
open -a Simulator
cd /Users/chen/work/AI-Badge/apps/mobile
flutter run -d "iPhone 17 Pro"
```

只重启已安装的 App：

```bash
xcrun simctl launch --terminate-running-process booted com.aibadge.aiBadge
```

完全关闭：

```bash
xcrun simctl shutdown booted
killall Simulator
```

