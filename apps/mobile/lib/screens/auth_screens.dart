import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/badge_theme.dart';
import '../state/app_controller.dart';
import '../widgets/badge_components.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _username = TextEditingController(text: 'demo');
  final _password = TextEditingController(text: 'Badge123!');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final success = await ref
        .read(appControllerProvider.notifier)
        .login(_username.text, _password.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (success) {
      context.go('/onboarding');
    } else {
      setState(() => _error = '账号或密码不正确，请使用页面中的内测账号');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: context.tokens.ink,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: context.tokens.mint,
              ),
            ),
            const SizedBox(height: 42),
            Text(
              '把你的 AI 搭子\n戴在身上',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            const Text('创建角色、同步到电子吧唧，再用触摸和摇晃唤醒它。'),
            const SizedBox(height: 36),
            TextField(
              controller: _username,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '内测账号',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _password,
              obscureText: true,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: '密码',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(
                  color: context.tokens.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 22),
            PrimaryPillButton(label: '进入内测', onPressed: _submit, busy: _busy),
            const SizedBox(height: 18),
            Center(
              child: Text(
                '演示账号：demo  ·  密码：Badge123!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _items = [
    (
      '创造角色',
      '从模板、标签和参考图开始，轻松得到统一画风的 AI 搭子。',
      Icons.face_retouching_natural_rounded,
    ),
    ('连接设备', '扫码寻找指定电子吧唧，不必在系统蓝牙列表里猜设备。', Icons.bluetooth_searching_rounded),
    ('同步内容', '可靠传输角色、表情和动作，中断后能够继续。', Icons.sync_rounded),
    ('触发互动', '点击、长按或摇一摇，让角色在屏幕上回应你。', Icons.touch_app_rounded),
  ];

  void _finish() {
    ref.read(appControllerProvider.notifier).completeOnboarding();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AiBadgeTheme.dark,
    child: Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(
                        _items.length,
                        (index) => Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 4,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: index <= _page
                                  ? context.tokens.mint
                                  : Colors.white24,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(onPressed: _finish, child: const Text('跳过')),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final accents = [
                      context.tokens.pink,
                      context.tokens.sky,
                      context.tokens.mint,
                      context.tokens.warning,
                    ];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: accents[index],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.$3,
                            size: 92,
                            color: context.tokens.ink,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          item.$1,
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              PrimaryPillButton(
                light: true,
                label: _page == _items.length - 1 ? '开始体验' : '下一步',
                onPressed: () {
                  if (_page == _items.length - 1) return _finish();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
