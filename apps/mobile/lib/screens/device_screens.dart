import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/badge_theme.dart';
import '../models/app_models.dart';
import '../state/app_controller.dart';
import '../widgets/badge_components.dart';

class DevicePairScreen extends ConsumerWidget {
  const DevicePairScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final connected = state.device.status == DeviceStatus.connected;
    final busy = {
      DeviceStatus.scanning,
      DeviceStatus.pairing,
    }.contains(state.device.status);
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加电子吧唧'),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
        child: Column(
          children: [
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                color: connected
                    ? context.tokens.mint
                    : context.tokens.sky.withValues(alpha: .38),
                shape: BoxShape.circle,
              ),
              child: Icon(
                connected
                    ? Icons.bluetooth_connected_rounded
                    : Icons.qr_code_scanner_rounded,
                size: 94,
              ),
            ),
            const SizedBox(height: 36),
            Text(
              connected
                  ? '连接成功！'
                  : busy
                  ? '正在寻找你的吧唧'
                  : '扫描设备二维码',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              connected
                  ? 'AI Badge Sim · 电量 ${state.device.battery}%'
                  : '模拟器会演示扫描、配对和设备确认。真实 BLE 将在协议冻结后接入。',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            DeviceStatusPill(snapshot: state.device),
            const SizedBox(height: 18),
            PrimaryPillButton(
              label: connected
                  ? '开始首次同步'
                  : busy
                  ? '正在连接…'
                  : '扫描并连接',
              busy: busy,
              onPressed: connected
                  ? () => context.go('/sync')
                  : controller.pairDevice,
              icon: connected
                  ? Icons.sync_rounded
                  : Icons.bluetooth_searching_rounded,
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () {}, child: const Text('手动输入设备编号')),
          ],
        ),
      ),
    );
  }
}

class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final transferring = state.device.status == DeviceStatus.transferring;
    final complete =
        state.device.progress >= 1 &&
        state.device.status == DeviceStatus.connected;
    return Scaffold(
      appBar: AppBar(
        title: const Text('同步到吧唧'),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
        children: [
          CharacterStage(character: state.character, compact: true),
          const SizedBox(height: 22),
          ProgressRail(
            value: state.device.progress,
            label: complete
                ? '设备已加载'
                : transferring
                ? '正在传输角色资源'
                : '等待开始',
          ),
          const SizedBox(height: 20),
          ContentCard(
            child: Column(
              children: [
                _TransferRow(
                  label: '角色主图',
                  value: complete
                      ? '已校验'
                      : transferring
                      ? '传输中'
                      : '等待',
                  color: context.tokens.pink,
                ),
                const Divider(height: 28),
                _TransferRow(
                  label: '基础情绪',
                  value: complete ? '已加载' : '4 个文件',
                  color: context.tokens.mint,
                ),
                const Divider(height: 28),
                _TransferRow(
                  label: '动作配置',
                  value: complete ? '已同步' : '5 个映射',
                  color: context.tokens.sky,
                ),
              ],
            ),
          ),
          if (state.syncError != null) ...[
            const SizedBox(height: 14),
            Text(
              state.syncError!,
              style: TextStyle(
                color: context.tokens.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 22),
          PrimaryPillButton(
            label: complete
                ? '配置触发动作'
                : transferring
                ? '正在同步…'
                : '开始同步',
            busy: transferring,
            onPressed: complete
                ? () => context.go('/actions')
                : controller.syncCharacter,
            icon: complete ? Icons.touch_app_rounded : Icons.sync_rounded,
          ),
        ],
      ),
    );
  }
}

class _TransferRow extends StatelessWidget {
  const _TransferRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      Text(value),
    ],
  );
}

class ActionConfigScreen extends ConsumerWidget {
  const ActionConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Theme(
    data: AiBadgeTheme.dark,
    child: Builder(
      builder: (context) {
        final controller = ref.read(appControllerProvider.notifier);
        Future<void> test(String event) async {
          final ok = await controller.testAction(event);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ok ? '$event 测试成功，设备已回执' : '设备离线，请重新连接')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('动作与实机测试'),
            leading: IconButton(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                '碰一下，\n让 TA 回应你',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              const Text(
                '点击右侧播放按钮发送实机测试；收到设备回执后才算成功。',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ActionMappingCard(
                icon: Icons.touch_app_rounded,
                eventName: '单击',
                feedback: '开心表情 · “嗨！”',
                onTest: () => test('单击'),
              ),
              const SizedBox(height: 12),
              ActionMappingCard(
                icon: Icons.ads_click_rounded,
                eventName: '双击',
                feedback: '惊喜动画 · 星星闪烁',
                onTest: () => test('双击'),
              ),
              const SizedBox(height: 12),
              ActionMappingCard(
                icon: Icons.pan_tool_alt_rounded,
                eventName: '长按',
                feedback: '切换角色',
                onTest: () => test('长按'),
              ),
              const SizedBox(height: 12),
              ActionMappingCard(
                icon: Icons.vibration_rounded,
                eventName: '摇晃',
                feedback: '随机一句小彩蛋',
                onTest: () => test('摇晃'),
              ),
              const SizedBox(height: 24),
              PrimaryPillButton(
                light: true,
                label: '保存并去聊天',
                onPressed: () => context.go('/chat'),
              ),
            ],
          ),
        );
      },
    ),
  );
}
