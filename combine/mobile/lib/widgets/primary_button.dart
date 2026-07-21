import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

/// The single primary (filled accent.gold) action per screen — e.g. "Scan
/// for truth", "Save & share".
///
/// Per the ORACLE design system (§8): never render a hard-disabled button.
/// If the action isn't ready (e.g. empty paste input), pass `onPressed:
/// null` and supply [onDisabledTap] to show an inline hint instead — the
/// button stays fully visually "on" either way, since this widget never
/// passes `null` down to the underlying [ElevatedButton].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.onDisabledTap,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;

  /// Called when the action is ready to run.
  final VoidCallback? onPressed;

  /// Called instead of [onPressed] when the action isn't ready yet.
  final VoidCallback? onDisabledTap;

  final PhosphorIconData? icon;

  /// Swaps the label for a small spinner while a request is in flight.
  final bool isLoading;

  /// Whether the button fills the available width (the common case — most
  /// primary actions are full-width per screen).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final VoidCallback effectiveOnPressed = isLoading
        ? () {}
        : (onPressed ?? onDisabledTap ?? () {});

    final Widget child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(OracleColors.bgBase),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                PhosphorIcon(icon!, size: 20, color: OracleColors.bgBase),
                const SizedBox(width: OracleSpacing.sm),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return ElevatedButton(
      onPressed: effectiveOnPressed,
      style: expand
          ? null
          : ElevatedButton.styleFrom(minimumSize: const Size(44, 44)),
      child: child,
    );
  }
}
