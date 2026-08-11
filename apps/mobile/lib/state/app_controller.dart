import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/badge_api_client.dart';
import '../device/device_port.dart';
import '../models/app_models.dart';

class AppState {
  const AppState({
    this.authenticated = false,
    this.onboardingComplete = false,
    this.selectedStyle = '软萌线条',
    this.selectedPersona = '元气搭子',
    this.generationStatus = GenerationStatus.idle,
    this.generationProgress = 0,
    this.device = const DeviceSnapshot(
      status: DeviceStatus.unbound,
      battery: 86,
      progress: 0,
    ),
    this.character,
    this.messages = const [],
    this.syncError,
  });

  final bool authenticated;
  final bool onboardingComplete;
  final String selectedStyle;
  final String selectedPersona;
  final GenerationStatus generationStatus;
  final double generationProgress;
  final DeviceSnapshot device;
  final BadgeCharacter? character;
  final List<ChatMessage> messages;
  final String? syncError;

  AppState copyWith({
    bool? authenticated,
    bool? onboardingComplete,
    String? selectedStyle,
    String? selectedPersona,
    GenerationStatus? generationStatus,
    double? generationProgress,
    DeviceSnapshot? device,
    BadgeCharacter? character,
    List<ChatMessage>? messages,
    String? syncError,
    bool clearSyncError = false,
  }) => AppState(
    authenticated: authenticated ?? this.authenticated,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    selectedStyle: selectedStyle ?? this.selectedStyle,
    selectedPersona: selectedPersona ?? this.selectedPersona,
    generationStatus: generationStatus ?? this.generationStatus,
    generationProgress: generationProgress ?? this.generationProgress,
    device: device ?? this.device,
    character: character ?? this.character,
    messages: messages ?? this.messages,
    syncError: clearSyncError ? null : syncError ?? this.syncError,
  );
}

class AppController extends StateNotifier<AppState> {
  AppController(this._device, [this._api]) : super(const AppState()) {
    _subscription = _device.snapshots.listen((snapshot) {
      state = state.copyWith(device: snapshot, clearSyncError: true);
    });
  }

  final DevicePort _device;
  final BadgeApiClient? _api;
  late final StreamSubscription<DeviceSnapshot> _subscription;

  Future<bool> login(String username, String password) async {
    if (_api?.enabled ?? false) {
      final valid = await _api!.login(username.trim(), password);
      if (valid) state = state.copyWith(authenticated: true);
      return valid;
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final valid = username.trim() == 'demo' && password == 'Badge123!';
    if (valid) state = state.copyWith(authenticated: true);
    return valid;
  }

  void completeOnboarding() => state = state.copyWith(onboardingComplete: true);

  void chooseStyle(String value) =>
      state = state.copyWith(selectedStyle: value);

  void choosePersona(String value) =>
      state = state.copyWith(selectedPersona: value);

  Future<void> generateCharacter() async {
    if (_api?.enabled ?? false) {
      state = state.copyWith(
        generationStatus: GenerationStatus.queued,
        generationProgress: 0.05,
      );
      final created = await _api!.createGenerationTask(
        styleId: state.selectedStyle,
        personaId: state.selectedPersona,
      );
      final id = created['id'] as String;
      for (var attempt = 0; attempt < 30; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        final task = await _api.generationTask(id);
        final status = task['status'] as String;
        state = state.copyWith(
          generationStatus: switch (status) {
            'QUEUED' => GenerationStatus.queued,
            'GENERATING' => GenerationStatus.generating,
            'MODERATING' => GenerationStatus.moderating,
            'SUCCEEDED' => GenerationStatus.succeeded,
            'FAILED_RETRYABLE' => GenerationStatus.failedRetryable,
            'FAILED_FINAL' => GenerationStatus.failedFinal,
            'CANCELLED' => GenerationStatus.cancelled,
            _ => GenerationStatus.failedRetryable,
          },
          generationProgress: (task['progress'] as num).toDouble(),
        );
        if (status == 'SUCCEEDED' ||
            status.startsWith('FAILED') ||
            status == 'CANCELLED')
          return;
      }
      state = state.copyWith(
        generationStatus: GenerationStatus.failedRetryable,
      );
      return;
    }
    state = state.copyWith(
      generationStatus: GenerationStatus.queued,
      generationProgress: 0.08,
    );
    await Future<void>.delayed(const Duration(milliseconds: 450));
    state = state.copyWith(
      generationStatus: GenerationStatus.generating,
      generationProgress: 0.36,
    );
    await Future<void>.delayed(const Duration(milliseconds: 650));
    state = state.copyWith(
      generationStatus: GenerationStatus.generating,
      generationProgress: 0.72,
    );
    await Future<void>.delayed(const Duration(milliseconds: 550));
    state = state.copyWith(
      generationStatus: GenerationStatus.moderating,
      generationProgress: 0.9,
    );
    await Future<void>.delayed(const Duration(milliseconds: 450));
    state = state.copyWith(
      generationStatus: GenerationStatus.succeeded,
      generationProgress: 1,
    );
  }

  void selectCharacter(int index) {
    const colors = [0xFFF5A6D9, 0xFF78E7C7, 0xFF89DDF0];
    const names = ['桃桃', '米露', '泡泡'];
    state = state.copyWith(
      character: BadgeCharacter(
        id: 'character-$index',
        name: names[index],
        color: colors[index],
        persona: state.selectedPersona,
      ),
    );
  }

  Future<void> pairDevice() async {
    await _device.scanAndPair();
    if (_api?.enabled ?? false) await _api!.bindVirtualDevice();
  }

  Future<void> reconnectDevice() => _device.reconnect();

  Future<void> syncCharacter() async {
    final character = state.character;
    if (character == null) {
      state = state.copyWith(syncError: '请先选择一个角色');
      return;
    }
    try {
      await _device.syncCharacter(character);
    } on StateError {
      state = state.copyWith(syncError: '设备未连接，请重新连接后继续');
    }
  }

  Future<bool> testAction(String eventType) async {
    try {
      await _device.testAction(eventType);
      if (_api?.enabled ?? false) {
        final apiEvent = switch (eventType) {
          '单击' => 'tap',
          '双击' => 'doubleTap',
          '长按' => 'longPress',
          '摇晃' => 'shake',
          _ => 'lift',
        };
        await _api!.saveAction(
          eventType: apiEvent,
          text: eventType == '摇晃' ? '随机一句小彩蛋' : '嗨！',
        );
      }
      return true;
    } on StateError {
      state = state.copyWith(syncError: '设备离线，无法进行实机测试');
      return false;
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final next = [
      ...state.messages,
      ChatMessage(text: text.trim(), fromUser: true),
    ];
    state = state.copyWith(messages: next);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      messages: [
        ...next,
        const ChatMessage(
          text: '我在呢！今天也一起把心情调成薄荷味吧。',
          fromUser: false,
          emotion: BadgeEmotion.happy,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _device.dispose();
    super.dispose();
  }
}

final devicePortProvider = Provider<DevicePort>(
  (ref) => VirtualDeviceAdapter(),
);
final badgeApiClientProvider = Provider<BadgeApiClient>(
  (ref) => BadgeApiClient(),
);

final appControllerProvider = StateNotifierProvider<AppController, AppState>((
  ref,
) {
  return AppController(
    ref.watch(devicePortProvider),
    ref.watch(badgeApiClientProvider),
  );
});
