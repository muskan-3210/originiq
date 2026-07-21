/// Small, dependency-free formatting helpers shared across screens/widgets.
///
/// Kept intl-free on purpose — the app has no localization requirement yet
/// and pulling in `intl` for a handful of English strings isn't worth the
/// extra dependency.
abstract final class OracleFormatters {
  static const List<String> _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// "March 2020" — used by [DangerCard] ("Born on WhatsApp — India, March
  /// 2020.") and [MutationVersionCard].
  static String monthYear(DateTime date) {
    return '${_months[date.month - 1]} ${date.year}';
  }

  /// "Mar 14, 2020" — a compact absolute date for detail rows.
  static String shortDate(DateTime date) {
    final String month = _months[date.month - 1].substring(0, 3);
    return '$month ${date.day}, ${date.year}';
  }

  /// "3h ago", "2d ago", "just now" — used by [RecentCheckRow].
  static String relativeTime(DateTime dateTime, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    final Duration diff = reference.difference(dateTime);

    if (diff.isNegative || diff.inSeconds < 60) {
      return 'just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    if (diff.inDays < 30) {
      final int weeks = (diff.inDays / 7).floor();
      return '${weeks}w ago';
    }
    if (diff.inDays < 365) {
      final int months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    }
    final int years = (diff.inDays / 365).floor();
    return '${years}y ago';
  }

  /// "47,000" — thousands-separated integer for [StatCounterCard] and
  /// similar. Also handles the animated in-between values, since the
  /// counter animation passes intermediate doubles through `.round()`.
  static String thousands(num value) {
    final String digits = value.round().abs().toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final int fromEnd = digits.length - i;
      buffer.write(digits[i]);
      final bool needsComma = fromEnd > 1 && fromEnd % 3 == 1;
      if (needsComma) buffer.write(',');
    }
    final String sign = value < 0 ? '-' : '';
    return '$sign$buffer';
  }

  /// "47K", "1.2M" — compact form for tight stat cards.
  static String compactNumber(num value) {
    final double absValue = value.abs().toDouble();
    if (absValue >= 1000000) {
      return '${_trimDecimal(absValue / 1000000)}M';
    }
    if (absValue >= 1000) {
      return '${_trimDecimal(absValue / 1000)}K';
    }
    return value.round().toString();
  }

  static String _trimDecimal(double value) {
    final String fixed = value.toStringAsFixed(1);
    return fixed.endsWith('.0')
        ? fixed.substring(0, fixed.length - 2)
        : fixed;
  }

  /// Truncates [text] to [maxLength] characters, breaking on a word
  /// boundary where possible and appending an ellipsis. Used by
  /// [TruthCardPreview] and [RecentCheckRow] for claim snippets.
  static String truncate(String text, {int maxLength = 120}) {
    final String trimmed = text.trim();
    if (trimmed.length <= maxLength) return trimmed;

    final String hardCut = trimmed.substring(0, maxLength);
    final int lastSpace = hardCut.lastIndexOf(' ');
    final String cut = lastSpace > maxLength * 0.6
        ? hardCut.substring(0, lastSpace)
        : hardCut;
    return '$cut…';
  }

  /// ISO 3166-1 alpha-2 country code -> a readable country name for the
  /// handful of countries the mock data / demo backend is likely to
  /// return. Falls back to the raw code for anything not in the map so an
  /// unfamiliar code never crashes the UI — it just renders as-is.
  static String countryName(String isoCode) {
    return _countryNames[isoCode.toUpperCase()] ?? isoCode.toUpperCase();
  }

  static const Map<String, String> _countryNames = <String, String>{
    'IN': 'India',
    'BR': 'Brazil',
    'US': 'United States',
    'GB': 'United Kingdom',
    'NG': 'Nigeria',
    'ID': 'Indonesia',
    'PH': 'Philippines',
    'MX': 'Mexico',
    'ZA': 'South Africa',
    'PK': 'Pakistan',
    'BD': 'Bangladesh',
    'FR': 'France',
    'DE': 'Germany',
    'KE': 'Kenya',
    'EG': 'Egypt',
  };

  /// "WhatsApp", "Facebook", ... — presentable platform name from a lowercase
  /// slug like "whatsapp".
  static String platformName(String slug) {
    return _platformNames[slug.toLowerCase()] ?? _capitalize(slug);
  }

  static const Map<String, String> _platformNames = <String, String>{
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'twitter': 'Twitter',
    'x': 'X',
    'instagram': 'Instagram',
    'telegram': 'Telegram',
    'tiktok': 'TikTok',
    'youtube': 'YouTube',
    'sms': 'SMS',
    'email': 'Email',
    'blog': 'a blog',
    'forum': 'a forum',
  };

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
