import 'package:flutter/widgets.dart';

/// ORACLE design system (§8) color tokens.
///
/// Single "mystical-dark" theme — dark-first, no light mode. Every widget in
/// this app should reference these tokens rather than hardcoding hex values.
abstract final class OracleColors {
  // Backgrounds
  static const Color bgBase = Color(0xFF0D0B1A);
  static const Color bgSurface = Color(0xFF17142B);
  static const Color bgSurfaceRaised = Color(0xFF201C3B);

  // Accent
  static const Color accentGold = Color(0xFFFFC857);

  // Verdict / status
  static const Color dangerRed = Color(0xFFE24B4A);
  static const Color successTeal = Color(0xFF1D9E75);
  static const Color warningAmber = Color(0xFFEF9F27);

  // Text
  static const Color textPrimary = Color(0xFFF5F3FF);
  static const Color textSecondary = Color(0xFFA9A3C9);
  static const Color textMuted = Color(0xFF6E698F);

  // Borders
  static const Color borderDefault = Color(0xFF2A2650);
  static const Color borderStrong = Color(0xFF3D386B);

  /// Subtle gold glow used behind focused inputs — a soft outer glow, never
  /// a hard drop shadow (the design system forbids drop shadows).
  static const Color focusGlow = Color(0x33FFC857); // accentGold @ 20%
}
