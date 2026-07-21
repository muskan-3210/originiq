import 'package:flutter/widgets.dart';

import 'colors.dart';

/// ORACLE design system (§8) typography tokens.
///
/// Only weights 400 (regular) and 500 (medium) are used anywhere in this
/// app — never 700/bold. Space Grotesk is used for display/wordmark and
/// headings; Inter is used for body copy, captions, and UI chrome.
abstract final class OracleTypography {
  static const String displayFontFamily = 'Space Grotesk';
  static const String bodyFontFamily = 'Inter';

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;

  /// Wordmark, e.g. "ORACLE" on the splash screen. Space Grotesk 500 28px.
  static const TextStyle display = TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: medium,
    fontSize: 28,
    height: 1.2,
    color: OracleColors.textPrimary,
  );

  /// H1. Space Grotesk 500 22px.
  static const TextStyle h1 = TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: medium,
    fontSize: 22,
    height: 1.2,
    color: OracleColors.textPrimary,
  );

  /// H2. Space Grotesk 500 18px.
  static const TextStyle h2 = TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: medium,
    fontSize: 18,
    height: 1.2,
    color: OracleColors.textPrimary,
  );

  /// H3. Space Grotesk 500 16px.
  static const TextStyle h3 = TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: medium,
    fontSize: 16,
    height: 1.2,
    color: OracleColors.textPrimary,
  );

  /// Body. Inter 400 15px.
  static const TextStyle body = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: regular,
    fontSize: 15,
    height: 1.5,
    color: OracleColors.textPrimary,
  );

  /// Body, medium weight — for emphasis without bold.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: medium,
    fontSize: 15,
    height: 1.5,
    color: OracleColors.textPrimary,
  );

  /// Body-secondary / captions. Inter 400 13px.
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: regular,
    fontSize: 13,
    height: 1.5,
    color: OracleColors.textSecondary,
  );

  /// Caption, medium weight — for tag pills / badge labels.
  static const TextStyle captionMedium = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: medium,
    fontSize: 13,
    height: 1.5,
    color: OracleColors.textSecondary,
  );

  /// Stat numbers, e.g. StatCounterCard values. Space Grotesk 500 24px.
  static const TextStyle statNumber = TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: medium,
    fontSize: 24,
    height: 1.2,
    color: OracleColors.textPrimary,
  );

  /// Button label. Inter 500 15px.
  static const TextStyle button = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: medium,
    fontSize: 15,
    height: 1.2,
    color: OracleColors.textPrimary,
  );
}
