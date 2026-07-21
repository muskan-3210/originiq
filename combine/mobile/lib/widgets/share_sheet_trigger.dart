import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:share_plus/share_plus.dart';

import 'primary_button.dart';

/// Wraps the Truth Card's "Save & share" action (§5 screen 7): captures a
/// PNG of whatever [repaintBoundaryKey] is attached to (the
/// `RepaintBoundary` wrapping a `TruthCardPreview`) and opens the OS share
/// sheet with it via `share_plus`.
///
/// Renders as a [PrimaryButton] so it drops straight into the screen's
/// primary-action slot. Capture/share failures are reported via [onError]
/// rather than thrown, so the screen can show its own error state with a
/// retry (per §5 screen 7: "if PNG fails, allow retry" and always keep a
/// "Skip sharing" link — that link is the screen's responsibility, not
/// this widget's).
class ShareSheetTrigger extends StatefulWidget {
  const ShareSheetTrigger({
    super.key,
    required this.repaintBoundaryKey,
    required this.shareText,
    this.fileName = 'oracle-truth-card.png',
    this.onShared,
    this.onError,
  });

  /// The key attached to the `RepaintBoundary` wrapping the Truth Card
  /// preview to be captured.
  final GlobalKey repaintBoundaryKey;

  /// The text caption that accompanies the shared image (e.g. the truth
  /// card tagline plus a link back to the app).
  final String shareText;

  final String fileName;

  final VoidCallback? onShared;
  final void Function(Object error)? onError;

  @override
  State<ShareSheetTrigger> createState() => _ShareSheetTriggerState();
}

class _ShareSheetTriggerState extends State<ShareSheetTrigger> {
  bool _isSharing = false;

  Future<void> _handleTap() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final Uint8List bytes = await _captureBoundary();
      await Share.shareXFiles(
        <XFile>[XFile.fromData(bytes, name: widget.fileName, mimeType: 'image/png')],
        text: widget.shareText,
      );
      widget.onShared?.call();
    } catch (error) {
      widget.onError?.call(error);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<Uint8List> _captureBoundary() async {
    final RenderObject? renderObject =
        widget.repaintBoundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError('The truth card is not ready to capture yet.');
    }
    final ui.Image image = await renderObject.toImage(pixelRatio: 3);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) {
      throw StateError('Could not encode the truth card image.');
    }
    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Save & share',
      icon: PhosphorIcons.shareNetwork(),
      isLoading: _isSharing,
      onPressed: _handleTap,
    );
  }
}
