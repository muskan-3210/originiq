import 'package:flutter/material.dart';

import 'colors.dart';
import 'shapes.dart';
import 'spacing.dart';
import 'typography.dart';

/// Builds the single dark "mystical-dark" [ThemeData] for ORACLE.
///
/// There is no light theme — the app is dark-first and stays dark-first.
abstract final class OracleAppTheme {
  static ThemeData get dark {
    final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
      brightness: Brightness.dark,
      surface: OracleColors.bgSurface,
      primary: OracleColors.accentGold,
      onPrimary: OracleColors.bgBase,
      secondary: OracleColors.accentGold,
      error: OracleColors.dangerRed,
      onError: OracleColors.textPrimary,
      onSurface: OracleColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: OracleColors.bgBase,
      colorScheme: colorScheme,
      fontFamily: OracleTypography.bodyFontFamily,
      splashFactory: InkRipple.splashFactory,
      textTheme: const TextTheme(
        displayMedium: OracleTypography.display,
        headlineLarge: OracleTypography.h1,
        headlineMedium: OracleTypography.h2,
        headlineSmall: OracleTypography.h3,
        bodyLarge: OracleTypography.body,
        bodyMedium: OracleTypography.body,
        bodySmall: OracleTypography.caption,
        labelLarge: OracleTypography.button,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: OracleColors.bgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: OracleTypography.h2,
        iconTheme: IconThemeData(color: OracleColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: OracleColors.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: OracleShapes.cardRadius,
          side: const BorderSide(
            color: OracleColors.borderDefault,
            width: OracleShapes.borderWidth,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: OracleColors.borderDefault,
        thickness: OracleShapes.borderWidth,
        space: OracleSpacing.lg,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OracleColors.bgSurfaceRaised,
        hintStyle: OracleTypography.body.copyWith(
          color: OracleColors.textMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: OracleSpacing.lg,
          vertical: OracleSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: OracleShapes.buttonRadius,
          borderSide: const BorderSide(
            color: OracleColors.borderDefault,
            width: OracleShapes.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: OracleShapes.buttonRadius,
          borderSide: const BorderSide(
            color: OracleColors.borderDefault,
            width: OracleShapes.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: OracleShapes.buttonRadius,
          borderSide: const BorderSide(
            color: OracleColors.borderStrong,
            width: OracleShapes.borderWidthFocused,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OracleColors.accentGold,
          textStyle: OracleTypography.button,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OracleColors.accentGold,
          foregroundColor: OracleColors.bgBase,
          disabledBackgroundColor: OracleColors.accentGold,
          disabledForegroundColor: OracleColors.bgBase,
          minimumSize: const Size.fromHeight(44),
          textStyle: OracleTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: OracleShapes.buttonRadius,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OracleColors.textPrimary,
          minimumSize: const Size.fromHeight(44),
          textStyle: OracleTypography.button,
          side: const BorderSide(
            color: OracleColors.borderDefault,
            width: OracleShapes.borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: OracleShapes.buttonRadius,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: OracleColors.textPrimary,
        size: 24,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: OracleColors.bgSurfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: OracleShapes.cardRadius,
          side: const BorderSide(
            color: OracleColors.borderDefault,
            width: OracleShapes.borderWidth,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: OracleColors.bgSurfaceRaised,
        contentTextStyle: OracleTypography.body,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: OracleShapes.cardRadius,
          side: const BorderSide(
            color: OracleColors.borderDefault,
            width: OracleShapes.borderWidth,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: OracleColors.accentGold,
        linearTrackColor: OracleColors.borderDefault,
      ),
    );
  }
}
