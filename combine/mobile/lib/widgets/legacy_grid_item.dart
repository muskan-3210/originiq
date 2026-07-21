import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../models/legacy_entry.dart';
import '../theme/colors.dart';
import '../theme/shapes.dart';

/// A single filled cell in the Legacy Wall's grid (§5 screen 8) — one past
/// catch. Tapping it reopens that Truth Card read-only.
///
/// Shows the generated Truth Card PNG thumbnail when [LegacyEntry.
/// truthCardImageUrl] is available, falling back to a verdict-colored
/// seal icon otherwise (and if the image fails to load).
class LegacyGridItem extends StatelessWidget {
  const LegacyGridItem({super.key, required this.entry, this.onTap});

  final LegacyEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = entry.verdict.color;
    final String? imageUrl = entry.truthCardImageUrl;

    return Semantics(
      button: true,
      label: '${entry.verdict.label} catch: ${entry.claimExcerpt}',
      child: Material(
        color: Colors.transparent,
        borderRadius: OracleShapes.cardRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: OracleColors.bgSurface,
                borderRadius: OracleShapes.cardRadius,
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: OracleShapes.borderWidth,
                ),
              ),
              child: imageUrl == null
                  ? Center(
                      child: PhosphorIcon(
                        PhosphorIcons.sealCheck(),
                        size: 28,
                        color: color,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (BuildContext context, String url) {
                        return const SizedBox.shrink();
                      },
                      errorWidget:
                          (BuildContext context, String url, dynamic error) {
                        return Center(
                          child: PhosphorIcon(
                            PhosphorIcons.sealCheck(),
                            size: 28,
                            color: color,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
