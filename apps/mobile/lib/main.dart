import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/badge_theme.dart';
import 'screens/auth_screens.dart';
import 'screens/chat_profile_screens.dart';
import 'screens/create_screens.dart';
import 'screens/device_screens.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AiBadgeApp()));
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/create', builder: (_, __) => const CreateScreen()),
    GoRoute(path: '/generation', builder: (_, __) => const GenerationScreen()),
    GoRoute(path: '/device', builder: (_, __) => const DevicePairScreen()),
    GoRoute(path: '/sync', builder: (_, __) => const SyncScreen()),
    GoRoute(path: '/actions', builder: (_, __) => const ActionConfigScreen()),
    GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
);

class AiBadgeApp extends StatelessWidget {
  const AiBadgeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'AI 吧唧',
    debugShowCheckedModeBanner: false,
    theme: AiBadgeTheme.light,
    routerConfig: _router,
  );
}
