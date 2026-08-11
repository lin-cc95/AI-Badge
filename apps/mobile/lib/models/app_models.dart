enum DeviceStatus {
  unbound,
  scanning,
  pairing,
  connected,
  transferring,
  reconnecting,
  offline,
  upgrading,
  recovery,
}

enum GenerationStatus {
  idle,
  queued,
  generating,
  moderating,
  succeeded,
  failedRetryable,
  failedFinal,
  cancelled,
}

enum BadgeEmotion { calm, happy, thinking, surprised, sad, angry }

class BadgeCharacter {
  const BadgeCharacter({
    required this.id,
    required this.name,
    required this.color,
    required this.persona,
  });

  final String id;
  final String name;
  final int color;
  final String persona;
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.fromUser,
    this.emotion = BadgeEmotion.calm,
  });

  final String text;
  final bool fromUser;
  final BadgeEmotion emotion;
}
