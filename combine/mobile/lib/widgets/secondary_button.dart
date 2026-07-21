import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Any action that isn't the single primary one per screen — e.g. "Done",
/// "Retry". Outline style on border.default per the ORACLE design system
/// (§8: "everything else outline/ghost").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final PhosphorIconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final Widget child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                OracleColors.textPrimary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                PhosphorIcon(icon!, size: 20, color: OracleColors.textPrimary),
                const SizedBox(width: OracleSpacing.sm),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return OutlinedButton(
      onPressed: isLoading ? () {} : onPressed,
      style: expand
          ? null
          : OutlinedButton.styleFrom(minimumSize: const Size(44, 44)),
      child: child,
    );
  }
}
