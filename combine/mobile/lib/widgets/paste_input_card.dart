import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:phosphor_icons/phosphor_icons.dart';

import '../theme/colors.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// The card users paste, type, or attach suspicious content into on Home
/// (§5 screen 2) — the first of the app's exactly two required taps in the
/// golden path.
///
/// Supports three ways to get content in: typing directly, tapping the
/// clipboard icon to paste, or tapping the photo/link icons to attach an
/// image or a URL instead of typed text.
class PasteInputCard extends StatefulWidget {
  const PasteInputCard({
    super.key,
    required this.controller,
    required this.onPickPhoto,
    required this.onPickUrl,
  });

  final TextEditingController controller;

  /// Invoked when the photo-upload icon is tapped.
  final VoidCallback onPickPhoto;

  /// Invoked when the link/URL icon is tapped.
  final VoidCallback onPickUrl;

  @override
  State<PasteInputCard> createState() => _PasteInputCardState();
}

class _PasteInputCardState extends State<PasteInputCard> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  Future<void> _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? text = data?.text;
    if (text == null || text.isEmpty) return;
    widget.controller.text = text;
    widget.controller.selection = TextSelection.collapsed(
      offset: text.length,
    );
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration = OracleShapes.cardDecoration(
      background: OracleColors.bgSurface,
      borderColor: _isFocused
          ? OracleColors.borderStrong
          : OracleColors.borderDefault,
    ).copyWith(
      // A focus halo, not an elevation shadow — offset stays zero so it
      // reads as a glow around the card rather than a shadow implying the
      // card floats above the page (the design system bans the latter).
      boxShadow: _isFocused
          ? const <BoxShadow>[
              BoxShadow(
                color: OracleColors.focusGlow,
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ]
          : null,
    );

    return Container(
      padding: const EdgeInsets.all(OracleSpacing.cardPadding),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              maxLines: 6,
              minLines: 3,
              style: OracleTypography.body,
              cursorColor: OracleColors.accentGold,
              decoration: InputDecoration(
                hintText: 'Paste a message, headline, or claim…',
                hintStyle: OracleTypography.body.copyWith(
                  color: OracleColors.textMuted,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: OracleSpacing.md),
          Row(
            children: <Widget>[
              _InlineIconAction(
                icon: PhosphorIcons.clipboardText(),
                label: 'Paste from clipboard',
                onTap: _pasteFromClipboard,
              ),
              const SizedBox(width: OracleSpacing.sm),
              _InlineIconAction(
                icon: PhosphorIcons.imageSquare(),
                label: 'Upload a photo',
                onTap: widget.onPickPhoto,
              ),
              const SizedBox(width: OracleSpacing.sm),
              _InlineIconAction(
                icon: PhosphorIcons.link(),
                label: 'Paste a link',
                onTap: widget.onPickUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A 44x44 icon-only tap target with a semantic label, per the ORACLE
/// accessibility rules (§8: icon-only buttons need a semantic label).
class _InlineIconAction extends StatelessWidget {
  const _InlineIconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final PhosphorIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: OracleColors.bgSurfaceRaised,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: PhosphorIcon(
                icon,
                size: 20,
                color: OracleColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
