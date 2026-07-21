import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../models/analysis.dart';
import '../services/providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/constants.dart';
import '../widgets/error_banner.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/offline_banner.dart';
import '../widgets/paste_input_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/recent_check_row.dart';
import 'scanning_screen.dart';

/// §5 screen 2 — Home. A short instruction, the paste/upload/link input
/// card, the single primary "Scan for truth" action, and up to
/// [OracleConstants.recentChecksLimit] recent results below.
///
/// This screen hosts the first of the golden path's exactly two required
/// taps (pasting/typing content, then tapping "Scan for truth").
///
/// NOTE: per §5 screen 2, "if opened via OS share, this screen is
/// skipped" — that needs a share-intent package (e.g.
/// `receive_sharing_intent`) which isn't in this scaffold's dependency
/// list. See the note on `SplashScreen` for where that would hook in.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  ScanInputKind _inputKind = ScanInputKind.text;
  bool _showEmptyHint = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The single primary action. Never hard-disabled — an empty input
  /// shows an inline hint instead of the button doing nothing or looking
  /// grayed out, per the ORACLE design system (§8).
  void _handleScanTap() {
    final String value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _showEmptyHint = true);
      return;
    }
    setState(() => _showEmptyHint = false);
    Navigator.of(context).pushNamed(
      '/scanning',
      arguments: ScanRequest(kind: _inputKind, value: value),
    );
  }

  void _handlePickPhoto() {
    // NOTE(dependency gap): reading real image bytes needs an
    // image-picking package (e.g. `image_picker`) not yet in
    // pubspec.yaml — see that file's "image picking" note. Surfacing this
    // plainly is better than an icon that silently does nothing.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(OracleConstants.photoUploadUnavailable)),
    );
  }

  Future<void> _handlePickUrl() async {
    final String? url = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OracleColors.bgSurfaceRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) => const _UrlEntrySheet(),
    );
    if (url == null || url.isEmpty || !mounted) return;
    setState(() {
      _inputKind = ScanInputKind.url;
      _controller.text = url;
      _controller.selection = TextSelection.collapsed(offset: url.length);
      _showEmptyHint = false;
    });
  }

  void _handleRecentCheckTap(Analysis analysis) {
    ref.read(currentAnalysisProvider.notifier).state = analysis;
    Navigator.of(context).pushNamed('/origin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OracleColors.bgBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const OfflineBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: OracleSpacing.screenMargin,
                  vertical: OracleSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Paste something suspicious — a message, a headline, '
                      'a claim — and we’ll trace where it came from.',
                      style: OracleTypography.body.copyWith(
                        color: OracleColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: OracleSpacing.xl),
                    PasteInputCard(
                      controller: _controller,
                      onPickPhoto: _handlePickPhoto,
                      onPickUrl: _handlePickUrl,
                    ),
                    const SizedBox(height: OracleSpacing.md),
                    PrimaryButton(
                      label: 'Scan for truth',
                      icon: PhosphorIcons.magnifyingGlass(),
                      onPressed: _handleScanTap,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _showEmptyHint
                          ? Padding(
                              key: const ValueKey<bool>(true),
                              padding: const EdgeInsets.only(
                                top: OracleSpacing.sm,
                              ),
                              child: Text(
                                OracleConstants.pasteHintEmpty,
                                style: OracleTypography.caption.copyWith(
                                  color: OracleColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey<bool>(false)),
                    ),
                    const SizedBox(height: OracleSpacing.xxl),
                    _RecentChecksSection(onTap: _handleRecentCheckTap),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The bottom sheet behind the paste card's link icon — typing/pasting a
/// URL doesn't need an extra package the way photo picking does, so this
/// path is fully wired up.
class _UrlEntrySheet extends StatefulWidget {
  const _UrlEntrySheet();

  @override
  State<_UrlEntrySheet> createState() => _UrlEntrySheetState();
}

class _UrlEntrySheetState extends State<_UrlEntrySheet> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _confirm() {
    final String value = _urlController.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: OracleSpacing.screenMargin,
        right: OracleSpacing.screenMargin,
        top: OracleSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + OracleSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('Paste a link', style: OracleTypography.h2),
          const SizedBox(height: OracleSpacing.md),
          TextField(
            controller: _urlController,
            autofocus: true,
            keyboardType: TextInputType.url,
            style: OracleTypography.body,
            cursorColor: OracleColors.accentGold,
            decoration: const InputDecoration(hintText: 'https://…'),
            onSubmitted: (String _) => _confirm(),
          ),
          const SizedBox(height: OracleSpacing.lg),
          PrimaryButton(label: 'Use this link', onPressed: _confirm),
        ],
      ),
    );
  }
}

/// Up to [OracleConstants.recentChecksLimit] recent results, or nothing at
/// all when there are none — §5 screen 2: "omit the row area entirely, no
/// placeholder graphic."
class _RecentChecksSection extends ConsumerWidget {
  const _RecentChecksSection({required this.onTap});

  final void Function(Analysis analysis) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Analysis>> recentChecks = ref.watch(
      recentChecksProvider,
    );

    return recentChecks.when(
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LoadingSkeleton.line(),
          SizedBox(height: OracleSpacing.sm),
          LoadingSkeleton.line(width: 180),
        ],
      ),
      error: (Object error, StackTrace stackTrace) => ErrorBanner(
        message: 'Recent checks couldn’t be loaded',
        onRetry: () => ref.invalidate(recentChecksProvider),
      ),
      data: (List<Analysis> checks) {
        if (checks.isEmpty) return const SizedBox.shrink();
        final List<Analysis> visible = checks
            .take(OracleConstants.recentChecksLimit)
            .toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Recent checks', style: OracleTypography.h3),
            const SizedBox(height: OracleSpacing.sm),
            for (final Analysis analysis in visible)
              RecentCheckRow(
                analysis: analysis,
                onTap: () => onTap(analysis),
              ),
          ],
        );
      },
    );
  }
}
