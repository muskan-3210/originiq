import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../animations/loop_controller.dart';
import '../models/analysis.dart';
import '../services/providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../utils/constants.dart';
import '../utils/mock_data.dart';
import '../widgets/error_banner.dart';
import '../widgets/offline_banner.dart';
import '../widgets/scan_progress_bar.dart';
import '../widgets/scanning_checklist.dart';
import '../widgets/secondary_button.dart';

/// What kind of content is being analyzed — set by whichever Home screen
/// affordance the user used (typed/pasted text, a pasted link, or an
/// uploaded photo).
enum ScanInputKind { text, url, image }

/// The content to analyze, handed from Home to [ScanningScreen] via route
/// arguments (`Navigator.pushNamed('/scanning', arguments: ...)`).
class ScanRequest {
  const ScanRequest({required this.kind, required this.value});

  final ScanInputKind kind;

  /// The pasted text, the URL string, or (for now, since reading real
  /// image bytes needs an image-picking package not yet in
  /// `pubspec.yaml`) a caption describing the image.
  final String value;
}

/// §5 screen 3 — full-bleed, centered scanning state. Reveals a checklist
/// one line at a time with a progress bar beneath it, then hands off to
/// Origin (whose own logic branches to the unverified "New territory"
/// content when there's no match) once the analysis completes.
class ScanningScreen extends ConsumerStatefulWidget {
  const ScanningScreen({super.key});

  @override
  ConsumerState<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends ConsumerState<ScanningScreen> {
  late final List<String> _stages;
  late final ScanRequest _request;

  int _completedCount = 0;
  bool _hasTimedOut = false;
  bool _isNavigating = false;
  bool _initialized = false;

  Timer? _stageTimer;
  Timer? _timeoutTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    _request = arguments is ScanRequest
        ? arguments
        : const ScanRequest(kind: ScanInputKind.text, value: '');
    _stages = <String>[
      if (_request.kind == ScanInputKind.image) 'Reading image text',
      'Checking language',
      'Matching similar claims',
      'Cross-referencing sources',
    ];
    _startTimers();
  }

  void _startTimers() {
    final Duration scanTimeout = ref.read(appConfigProvider).scanTimeout;
    _timeoutTimer = Timer(scanTimeout, () {
      if (!mounted || _isNavigating) return;
      setState(() => _hasTimedOut = true);
    });
    _scheduleNextStage();
  }

  void _scheduleNextStage() {
    _stageTimer = Timer(OracleConstants.scanStageDuration, () {
      if (!mounted || _hasTimedOut) return;
      setState(() => _completedCount++);
      if (_completedCount >= _stages.length) {
        unawaited(_finishScan());
      } else {
        _scheduleNextStage();
      }
    });
  }

  Future<void> _finishScan() async {
    // NOTE(mock data): swap this block for a real call once the backend is
    // reachable, e.g.:
    //   final api = ref.read(apiServiceProvider);
    //   final result = switch (_request.kind) {
    //     ScanInputKind.text => await api.analyzeText(_request.value),
    //     ScanInputKind.url => await api.analyzeUrl(_request.value),
    //     ScanInputKind.image => await api.analyzeImage(bytes, filename: ...),
    //   };
    // wrapped in a try/catch that sets `_hasTimedOut = true` on failure.
    // For now every scan resolves to the same rich example so the full
    // golden path is reviewable end to end.
    final Analysis result = MockData.falseAnalysis;
    if (!mounted) return;
    _isNavigating = true;
    ref.read(currentAnalysisProvider.notifier).state = result;
    unawaited(Navigator.of(context).pushReplacementNamed('/origin'));
  }

  void _retry() {
    setState(() {
      _hasTimedOut = false;
      _completedCount = 0;
    });
    _startTimers();
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OracleSpacing.screenMargin,
                ),
                child: Center(
                  child: _hasTimedOut
                      ? _buildErrorState()
                      : _buildScanningState(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningState() {
    final double progress = _stages.isEmpty
        ? 0
        : _completedCount / _stages.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const _ScanningClockIcon(),
        const SizedBox(height: OracleSpacing.xxl),
        ScanningChecklist(stages: _stages, completedCount: _completedCount),
        const SizedBox(height: OracleSpacing.xl),
        ScanProgressBar(progress: progress),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const ErrorBanner(message: OracleConstants.scanTakingLong),
        const SizedBox(height: OracleSpacing.lg),
        SecondaryButton(
          label: 'Retry',
          icon: PhosphorIcons.arrowClockwise(),
          expand: false,
          onPressed: _retry,
        ),
      ],
    );
  }
}

class _ScanningClockIcon extends StatelessWidget {
  const _ScanningClockIcon();

  static const double _maxTiltRadians = 8 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Scanning',
      child: GatedLoop(
        duration: const Duration(milliseconds: 2200),
        curve: OracleCurves.rotateLoop,
        reverse: true,
        builder: (BuildContext context, Animation<double> animation) {
          final double angle = (animation.value * 2 - 1) * _maxTiltRadians;
          final double bob = -6 * animation.value;
          return Transform.translate(
            offset: Offset(0, bob),
            child: Transform.rotate(
              angle: angle,
              child: PhosphorIcon(
                PhosphorIcons.clockClockwise(),
                size: 56,
                color: OracleColors.accentGold,
              ),
            ),
          );
        },
      ),
    );
  }
}
