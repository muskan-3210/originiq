import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../services/providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// A persistent top banner shown whenever [isOfflineProvider] is true.
///
/// Renders nothing when online, so any screen can unconditionally place
/// `const OfflineBanner()` at the top of its layout without extra
/// plumbing.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isOffline = ref.watch(isOfflineProvider);
    if (!isOffline) return const SizedBox.shrink();

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: OracleSpacing.lg,
          vertical: OracleSpacing.sm,
        ),
        color: OracleColors.bgSurfaceRaised,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PhosphorIcon(
              PhosphorIcons.wifiSlash(),
              size: 16,
              color: OracleColors.textSecondary,
            ),
            const SizedBox(width: OracleSpacing.sm),
            const Flexible(
              child: Text(
                "You're offline — showing what's already saved",
                style: OracleTypography.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
