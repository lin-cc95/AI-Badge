import 'package:ai_badge/core/badge_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brand tokens remain stable', () {
    expect(BadgeTokens.light.canvas.toARGB32(), 0xFFF7F8F6);
    expect(BadgeTokens.light.mint.toARGB32(), 0xFF78E7C7);
    expect(BadgeTokens.light.sky.toARGB32(), 0xFF89DDF0);
    expect(BadgeTokens.light.pink.toARGB32(), 0xFFF5A6D9);
  });
}
