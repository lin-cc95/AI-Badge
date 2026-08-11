import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/badge_theme.dart';
import '../device/device_port.dart';
import '../models/app_models.dart';

class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
    this.light = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final background = light ? Colors.white : context.tokens.ink;
    final foreground = light ? context.tokens.ink : Colors.white;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withValues(alpha: 0.6),
          shape: const StadiumBorder(),
        ),
        icon: busy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              )
            : Icon(icon ?? Icons.arrow_forward_rounded),
        label: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class DeviceStatusPill extends StatelessWidget {
  const DeviceStatusPill({super.key, required this.snapshot, this.onTap});

  final DeviceSnapshot snapshot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (snapshot.status) {
      DeviceStatus.unbound => (
        '未绑定',
        context.tokens.warning,
        Icons.add_link_rounded,
      ),
      DeviceStatus.scanning => ('搜索中', context.tokens.sky, Icons.radar_rounded),
      DeviceStatus.pairing => (
        '配对中',
        context.tokens.sky,
        Icons.bluetooth_searching_rounded,
      ),
      DeviceStatus.connected => (
        '在线 ${snapshot.battery}%',
        context.tokens.mint,
        Icons.bluetooth_connected_rounded,
      ),
      DeviceStatus.transferring => (
        '同步 ${(snapshot.progress * 100).round()}%',
        context.tokens.sky,
        Icons.sync_rounded,
      ),
      DeviceStatus.reconnecting => (
        '重连中',
        context.tokens.warning,
        Icons.sync_rounded,
      ),
      DeviceStatus.offline => (
        '设备离线',
        context.tokens.warning,
        Icons.bluetooth_disabled_rounded,
      ),
      DeviceStatus.upgrading => (
        '升级中',
        context.tokens.sky,
        Icons.system_update_alt_rounded,
      ),
      DeviceStatus.recovery => (
        '恢复模式',
        context.tokens.danger,
        Icons.healing_rounded,
      ),
    };
    return Semantics(
      button: true,
      label: '设备状态：$label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: context.tokens.ink),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmotionChip extends StatelessWidget {
  const EmotionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    showCheckmark: selected,
    selectedColor: color ?? context.tokens.mint,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF303030)
        : Colors.white,
    side: BorderSide(
      color: selected ? Colors.transparent : context.tokens.divider,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    shape: const StadiumBorder(),
    labelStyle: TextStyle(
      fontWeight: FontWeight.w700,
      color: selected ? context.tokens.ink : null,
    ),
  );
}

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: color ?? Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: context.tokens.divider),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class CharacterStage extends StatefulWidget {
  const CharacterStage({
    super.key,
    required this.character,
    this.emotion = BadgeEmotion.calm,
    this.compact = false,
  });

  final BadgeCharacter? character;
  final BadgeEmotion emotion;
  final bool compact;

  @override
  State<CharacterStage> createState() => _CharacterStageState();
}

class _CharacterStageState extends State<CharacterStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.character?.color ?? 0xFF89DDF0);
    final size = widget.compact ? 150.0 : 250.0;
    return Semantics(
      label: widget.character == null
          ? '等待创建的角色'
          : '${widget.character!.name}角色预览',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = MediaQuery.disableAnimationsOf(context)
              ? 1.0
              : 1 + _controller.value * 0.018;
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: widget.compact ? 190 : 310),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(32),
          ),
          alignment: Alignment.center,
          child: CustomPaint(
            size: Size.square(size),
            painter: _CharacterPainter(color: color, emotion: widget.emotion),
          ),
        ),
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  const _CharacterPainter({required this.color, required this.emotion});

  final Color color;
  final BadgeEmotion emotion;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final facePaint = Paint()..color = color;
    final line = Paint()
      ..color = const Color(0xFF17171B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(4, size.width * 0.022)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, size.width * 0.39, facePaint);
    final eyeY = size.height * 0.45;
    if (emotion == BadgeEmotion.happy) {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width * 0.38, eyeY),
          radius: size.width * 0.045,
        ),
        0,
        math.pi,
        false,
        line,
      );
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width * 0.62, eyeY),
          radius: size.width * 0.045,
        ),
        0,
        math.pi,
        false,
        line,
      );
    } else {
      canvas.drawCircle(
        Offset(size.width * 0.38, eyeY),
        size.width * 0.018,
        Paint()..color = line.color,
      );
      canvas.drawCircle(
        Offset(size.width * 0.62, eyeY),
        size.width * 0.018,
        Paint()..color = line.color,
      );
    }
    final nose = Path()
      ..moveTo(size.width * 0.5, size.height * 0.48)
      ..quadraticBezierTo(
        size.width * 0.46,
        size.height * 0.6,
        size.width * 0.53,
        size.height * 0.6,
      );
    canvas.drawPath(nose, line);
    final mouth = Path()..moveTo(size.width * 0.36, size.height * 0.67);
    if (emotion == BadgeEmotion.sad) {
      mouth.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.58,
        size.width * 0.64,
        size.height * 0.67,
      );
    } else {
      mouth.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.78,
        size.width * 0.66,
        size.height * 0.65,
      );
    }
    canvas.drawPath(mouth, line);
    final curl = Path()
      ..moveTo(size.width * 0.34, size.height * 0.16)
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.02,
        size.width * 0.59,
        size.height * 0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.31,
        size.width * 0.72,
        size.height * 0.22,
      );
    canvas.drawPath(curl, line);
  }

  @override
  bool shouldRepaint(covariant _CharacterPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.emotion != emotion;
}

class ProgressRail extends StatelessWidget {
  const ProgressRail({super.key, required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(value: value, minHeight: 12),
      ),
    ],
  );
}

class ActionMappingCard extends StatelessWidget {
  const ActionMappingCard({
    super.key,
    required this.icon,
    required this.eventName,
    required this.feedback,
    required this.onTest,
  });

  final IconData icon;
  final String eventName;
  final String feedback;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) => ContentCard(
    color: const Color(0xFF282828),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.tokens.mint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: context.tokens.ink),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(feedback, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        IconButton(
          onPressed: onTest,
          tooltip: '实机测试',
          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        ),
      ],
    ),
  );
}
