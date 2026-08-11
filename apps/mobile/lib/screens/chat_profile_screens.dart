import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/badge_theme.dart';
import '../models/app_models.dart';
import '../state/app_controller.dart';
import '../widgets/badge_components.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _input.clear();
    });
    await ref.read(appControllerProvider.notifier).sendMessage(text);
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AiBadgeTheme.dark,
    child: Builder(
      builder: (context) {
        final state = ref.watch(appControllerProvider);
        final assistantMessages = state.messages
            .where((message) => !message.fromUser)
            .toList();
        final latestEmotion = assistantMessages.isEmpty
            ? BadgeEmotion.calm
            : assistantMessages.last.emotion;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.character?.name ?? '你的搭子',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const Text(
                  '人格记忆已开启',
                  style: TextStyle(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                tooltip: '对话设置',
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: CharacterStage(
                  character: state.character,
                  emotion: latestEmotion,
                  compact: true,
                ),
              ),
              Expanded(
                child: state.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '今天想聊点什么？',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: ['给我打个气', '今天有点累', '说句小彩蛋']
                                  .map(
                                    (text) => ActionChip(
                                      label: Text(text),
                                      onPressed: () {
                                        _input.text = text;
                                        _send();
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          return Align(
                            alignment: message.fromUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.sizeOf(context).width * .76,
                              ),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: message.fromUser
                                    ? context.tokens.sky
                                    : const Color(0xFF303030),
                                borderRadius: BorderRadius.circular(20)
                                    .copyWith(
                                      bottomRight: message.fromUser
                                          ? const Radius.circular(6)
                                          : null,
                                      bottomLeft: !message.fromUser
                                          ? const Radius.circular(6)
                                          : null,
                                    ),
                              ),
                              child: Text(
                                message.text,
                                style: TextStyle(
                                  color: message.fromUser
                                      ? context.tokens.ink
                                      : Colors.white,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          onSubmitted: (_) => _send(),
                          textInputAction: TextInputAction.send,
                          decoration: const InputDecoration(
                            hintText: '和 TA 说点什么…',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: _sending ? null : _send,
                        style: IconButton.styleFrom(
                          backgroundColor: context.tokens.mint,
                          foregroundColor: context.tokens.ink,
                          minimumSize: const Size(52, 52),
                        ),
                        icon: _sending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.arrow_upward_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          ContentCard(
            color: context.tokens.sky.withValues(alpha: .55),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: CharacterStage(
                    character: state.character,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.character?.name ?? '还没有角色',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(state.character?.persona ?? '创建角色后会显示在这里'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ContentCard(
            child: Column(
              children: [
                _SettingRow(
                  icon: Icons.bluetooth_rounded,
                  title: '设备管理',
                  trailing: DeviceStatusPill(snapshot: state.device),
                  onTap: () => context.go('/device'),
                ),
                const Divider(height: 28),
                _SettingRow(
                  icon: Icons.collections_bookmark_outlined,
                  title: '角色与素材',
                  onTap: () => context.go('/create'),
                ),
                const Divider(height: 28),
                _SettingRow(
                  icon: Icons.system_update_alt_rounded,
                  title: '固件更新',
                  value: '已是最新',
                  onTap: () {},
                ),
                const Divider(height: 28),
                _SettingRow(
                  icon: Icons.health_and_safety_outlined,
                  title: '帮助与诊断',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ContentCard(
            child: Column(
              children: [
                _SettingRow(
                  icon: Icons.shield_outlined,
                  title: '隐私与记忆',
                  onTap: () {},
                ),
                const Divider(height: 28),
                _SettingRow(
                  icon: Icons.motion_photos_off_outlined,
                  title: '减少动态效果',
                  value: MediaQuery.disableAnimationsOf(context)
                      ? '已开启'
                      : '跟随系统',
                  onTap: () {},
                ),
                const Divider(height: 28),
                _SettingRow(
                  icon: Icons.info_outline_rounded,
                  title: '关于 AI 吧唧',
                  value: '0.1.0',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 3,
        indicatorColor: context.tokens.sky,
        onDestinationSelected: (index) =>
            context.go(['/home', '/create', '/chat', '/profile'][index]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '首页'),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            label: '创作',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: '互动',
          ),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: '我的'),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (trailing != null)
            trailing!
          else ...[
            if (value != null)
              Text(value!, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded),
          ],
        ],
      ),
    ),
  );
}
