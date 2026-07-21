import 'package:flutter/widgets.dart';

import 'colors.dart';

/// ORACLE design system (§8) shape tokens.
///
/// Radius: 12 for cards, 8 for buttons/inputs, 999 (pill) for tags/badges.
/// No drop shadows anywhere — elevation is communicated purely through a
/// lighter surface tone plus a 0.5px [OracleColors.borderDefault] outline.
abstract final class OracleShapes {
  static const double radiusCard = 12;
  static const double radiusButton = 8;
  static const double radiusPill = 999;

  static const double borderWidth = 0.5;
  static const double borderWidthFocused = 1;

  static final BorderRadius cardRadius = BorderRadius.circular(radiusCard);
  static final BorderRadius buttonRadius = BorderRadius.circular(radiusButton);
  static final BorderRadius pillRadius = BorderRadius.circular(radiusPill);

  /// Standard 0.5px outline used in place of elevation/shadows.
  static Border outline({Color color = OracleColors.borderDefault}) {
    return Border.all(color: color, width: borderWidth);
  }

  /// Focus outline: border.strong at full width, no shadow blur — paired
  /// with [OracleColors.focusGlow] as a background wash where a glow effect
  /// is desired.
  static Border focusOutline() {
    return Border.all(
      color: OracleColors.borderStrong,
      width: borderWidthFocused,
    );
  }

  /// A card decoration using the surface tone + outline elevation model.
  static BoxDecoration cardDecoration({
    Color background = OracleColors.bgSurface,
    Color borderColor = OracleColors.borderDefault,
    BorderRadius? radius,
  }) {
    return BoxDecoration(
      color: background,
      borderRadius: radius ?? cardRadius,
      border: Border.all(color: borderColor, width: borderWidth),
    );
  }
}
