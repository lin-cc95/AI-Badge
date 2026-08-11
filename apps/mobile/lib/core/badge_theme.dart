import 'package:flutter/material.dart';

@immutable
class BadgeTokens extends ThemeExtension<BadgeTokens> {
  const BadgeTokens({
    required this.canvas,
    required this.ink,
    required this.mint,
    required this.sky,
    required this.pink,
    required this.warning,
    required this.danger,
    required this.divider,
  });

  final Color canvas;
  final Color ink;
  final Color mint;
  final Color sky;
  final Color pink;
  final Color warning;
  final Color danger;
  final Color divider;

  static const light = BadgeTokens(
    canvas: Color(0xFFF7F8F6),
    ink: Color(0xFF17171B),
    mint: Color(0xFF78E7C7),
    sky: Color(0xFF89DDF0),
    pink: Color(0xFFF5A6D9),
    warning: Color(0xFFF4C563),
    danger: Color(0xFFE65A5A),
    divider: Color(0xFFE8E9E6),
  );

  @override
  BadgeTokens copyWith({
    Color? canvas,
    Color? ink,
    Color? mint,
    Color? sky,
    Color? pink,
    Color? warning,
    Color? danger,
    Color? divider,
  }) => BadgeTokens(
    canvas: canvas ?? this.canvas,
    ink: ink ?? this.ink,
    mint: mint ?? this.mint,
    sky: sky ?? this.sky,
    pink: pink ?? this.pink,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    divider: divider ?? this.divider,
  );

  @override
  BadgeTokens lerp(ThemeExtension<BadgeTokens>? other, double t) {
    if (other is! BadgeTokens) return this;
    return BadgeTokens(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      sky: Color.lerp(sky, other.sky, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

class AiBadgeTheme {
  const AiBadgeTheme._();

  static TextTheme _textTheme(Color color) => TextTheme(
    displaySmall: TextStyle(
      fontSize: 32,
      height: 1.05,
      fontWeight: FontWeight.w800,
      color: color,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      height: 1.12,
      fontWeight: FontWeight.w800,
      color: color,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w700,
      color: color,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: color,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      height: 1.45,
      fontWeight: FontWeight.w500,
      color: color,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w500,
      color: color,
    ),
  );

  static ThemeData get light {
    const t = BadgeTokens.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: t.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: t.sky,
        surface: t.canvas,
        brightness: Brightness.light,
      ),
      textTheme: _textTheme(t.ink),
      extensions: const [t],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: t.divider),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }

  static ThemeData get dark {
    const t = BadgeTokens.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: t.ink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: t.mint,
        surface: t.ink,
        brightness: Brightness.dark,
      ),
      textTheme: _textTheme(Colors.white),
      extensions: const [t],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF272727),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }
}

extension BadgeThemeX on BuildContext {
  BadgeTokens get tokens => Theme.of(this).extension<BadgeTokens>()!;
}
