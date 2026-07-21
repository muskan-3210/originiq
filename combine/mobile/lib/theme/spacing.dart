/// ORACLE design system (§8) spacing scale.
///
/// Reference these tokens for every margin/padding/gap instead of magic
/// numbers so spacing stays consistent across the app.
abstract final class OracleSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  /// Card internal padding.
  static const double cardPadding = lg;

  /// Screen horizontal margin.
  static const double screenMargin = 20;
}
