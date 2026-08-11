import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/badge_theme.dart';
import '../models/app_models.dart';
import '../state/app_controller.dart';
import '../widgets/badge_components.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final device = state.device;
    String primaryLabel;
    VoidCallback primaryAction;
    if (state.character == null) {
      primaryLabel = '创建第一个角色';
      primaryAction = () => context.go('/create');
    } else if (device.status == DeviceStatus.unbound) {
      primaryLabel = '添加电子吧唧';
      primaryAction = () => context.go('/device');
    } else if (device.status == DeviceStatus.offline) {
      primaryLabel = '重新连接';
      primaryAction = controller.reconnectDevice;
    } else if (device.status == DeviceStatus.transferring) {
      primaryLabel = '查看同步进度';
      primaryAction = () => context.go('/sync');
    } else {
      primaryLabel = '同步到吧唧';
      primaryAction = () => context.go('/sync');
    }
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '嗨，今天想让\nTA 是什么心情？',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                DeviceStatusPill(
                  snapshot: device,
                  onTap: () => context.go('/device'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            CharacterStage(
              character: state.character,
              emotion: BadgeEmotion.happy,
            ),
            const SizedBox(height: 18),
            if (state.character != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EmotionChip(
                    label: '平静',
                    selected: false,
                    onTap: () {},
                    color: context.tokens.mint,
                  ),
                  const SizedBox(width: 8),
                  EmotionChip(
                    label: '开心',
                    selected: true,
                    onTap: () {},
                    color: context.tokens.pink,
                  ),
                  const SizedBox(width: 8),
                  EmotionChip(
                    label: '思考',
                    selected: false,
                    onTap: () {},
                    color: context.tokens.sky,
                  ),
                ],
              ),
            const SizedBox(height: 20),
            PrimaryPillButton(
              label: primaryLabel,
              onPressed: primaryAction,
              icon: Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => context.go('/chat'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
                side: BorderSide(color: context.tokens.divider),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text(
                '和 TA 聊聊',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 28),
            Text('今天可以做', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ContentCard(
                    color: context.tokens.sky,
                    onTap: () => context.go('/create'),
                    child: const _QuickAction(
                      icon: Icons.auto_awesome_rounded,
                      title: '换个造型',
                      subtitle: '继续创作',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ContentCard(
                    color: Colors.white,
                    onTap: () => context.go('/actions'),
                    child: const _QuickAction(
                      icon: Icons.touch_app_rounded,
                      title: '设置动作',
                      subtitle: '点击与摇晃',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BadgeBottomNavigation(currentIndex: 0),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 30),
      const SizedBox(height: 22),
      Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 3),
      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}

class _BadgeBottomNavigation extends StatelessWidget {
  const _BadgeBottomNavigation({required this.currentIndex});
  final int currentIndex;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    indicatorColor: context.tokens.sky,
    onDestinationSelected: (index) {
      const routes = ['/home', '/create', '/chat', '/profile'];
      context.go(routes[index]);
    },
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: '首页',
      ),
      NavigationDestination(
        icon: Icon(Icons.auto_awesome_outlined),
        selectedIcon: Icon(Icons.auto_awesome_rounded),
        label: '创作',
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble_rounded),
        label: '互动',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person_rounded),
        label: '我的',
      ),
    ],
  );
}

class PlaceholderTabScreen extends StatelessWidget {
  const PlaceholderTabScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.index,
  });
  final String title;
  final IconData icon;
  final int index;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64),
          const SizedBox(height: 16),
          Text('$title功能将在核心链路后继续展开'),
        ],
      ),
    ),
    bottomNavigationBar: _BadgeBottomNavigation(currentIndex: index),
  );
}
