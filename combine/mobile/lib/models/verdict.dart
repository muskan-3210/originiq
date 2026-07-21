import 'package:flutter/widgets.dart';

import '../theme/colors.dart';

/// The four verdicts the backend can return for an [Analysis].
///
/// Matches the `verdict` field of `POST /api/analyze` exactly:
/// `false | misleading | true | unverified`.
enum VerdictType {
  falseVerdict('false'),
  misleading('misleading'),
  trueVerdict('true'),
  unverified('unverified');

  const VerdictType(this.wireValue);

  /// The exact string used on the wire (JSON) for this verdict.
  final String wireValue;

  /// Parses the backend's `verdict` string into a [VerdictType].
  ///
  /// Falls back to [VerdictType.unverified] for any unrecognized value so
  /// the app never crashes on an unexpected/future verdict string — it just
  /// treats it as "no match yet".
  static VerdictType fromWire(String value) {
    return VerdictType.values.firstWhere(
      (VerdictType type) => type.wireValue == value,
      orElse: () => VerdictType.unverified,
    );
  }

  /// Sentence-case label shown on [VerdictBadge] and throughout the UI.
  String get label {
    switch (this) {
      case VerdictType.falseVerdict:
        return 'False';
      case VerdictType.misleading:
        return 'Misleading';
      case VerdictType.trueVerdict:
        return 'True';
      case VerdictType.unverified:
        return 'Unverified';
    }
  }

  /// Badge/accent color per the ORACLE design system (§8):
  /// danger.red for False, warning.amber for Misleading, success.teal for
  /// True, and text.muted for Unverified (no strong color — nothing was
  /// confirmed either way).
  Color get color {
    switch (this) {
      case VerdictType.falseVerdict:
        return OracleColors.dangerRed;
      case VerdictType.misleading:
        return OracleColors.warningAmber;
      case VerdictType.trueVerdict:
        return OracleColors.successTeal;
      case VerdictType.unverified:
        return OracleColors.textMuted;
    }
  }

  /// Whether this verdict means the claim caused harm worth tracing — i.e.
  /// it belongs on the Legacy Wall. Per §5 screen 7: False/Misleading route
  /// to the Legacy Wall on "Done"; True routes Home instead.
  bool get belongsOnLegacyWall {
    return this == VerdictType.falseVerdict || this == VerdictType.misleading;
  }
}
