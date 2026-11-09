// Procedural motion player widget for animated exercise figures.
//
// Follows Sinew design tokens:
// - Animated play/pause icon morph
// - 0.5x / 1.0x speed pill
// - Scrub bar with step ticks and haptic feedback
// - Switch-side unilateral mirror pill
// - 2-second auto-fade controls overlay
// - RouteAware and AppLifecycleListener pausing
// - Reduced motion support (disables autoplay, frame jumps instead of loops)

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/theme/app_theme.dart' hide Motion;

import '../core/timeline.dart';
import '../data/motion_model.dart';
import '../render/figure_painter.dart';

/// Full-featured interactive motion player for an exercise figure.
class MotionPlayer extends ConsumerStatefulWidget {
  const MotionPlayer({
    super.key,
    required this.motion,
    this.activeStepIndex,
    this.onStepChanged,
    this.height = 260.0,
    this.showControls = true,
  });

  final Motion motion;
  final int? activeStepIndex;
  final ValueChanged<int>? onStepChanged;
  final double height;
  final bool showControls;

  @override
  ConsumerState<MotionPlayer> createState() => _MotionPlayerState();
}

class _MotionPlayerState extends ConsumerState<MotionPlayer>
    with SingleTickerProviderStateMixin, RouteAware {
  late final AnimationController _controller;
  late final AppLifecycleListener _lifecycleListener;

  bool _isPlaying = true;
  double _speed = 1.0;
  bool _mirrored = false;
  bool _controlsVisible = true;
  Timer? _hideTimer;
  int? _lastReportedStep;

  // Track if we crossed ticks during scrubbing for haptics
  int _lastScrubTick = -1;

  @override
  void initState() {
    super.initState();
    final double durSec = widget.motion.timeline.totalDurationSec;
    final int durMs = math.max(200, (durSec * 1000).round());

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durMs),
    )..addListener(_onTick);

    _lifecycleListener = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        if (state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) {
          _pause();
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bool disableAnimations = MediaQuery.of(context).disableAnimations;
      if (disableAnimations) {
        _isPlaying = false;
        _controller.value = 0.0;
      } else {
        _play();
      }
      _resetHideTimer();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<void>? route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didUpdateWidget(covariant MotionPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeStepIndex != widget.activeStepIndex &&
        widget.activeStepIndex != null) {
      _springToStep(widget.activeStepIndex!);
    }
  }

  @override
  void didPushNext() {
    // Navigated to a new screen above this one
    _pause();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _lifecycleListener.dispose();
    _hideTimer?.cancel();
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    // Step sync
    final List<int> stepIndices = widget.motion.stepIndices;
    if (stepIndices.isNotEmpty) {
      final double progress = _controller.value;
      final double timeSec = progress * widget.motion.timeline.totalDurationSec;
      final int stepIdx = _computeActiveStepIndex(timeSec);
      if (stepIdx != _lastReportedStep) {
        _lastReportedStep = stepIdx;
        widget.onStepChanged?.call(stepIdx);
      }
    }
  }

  int _computeActiveStepIndex(double timeSec) {
    final List<int> stepIndices = widget.motion.stepIndices;
    if (stepIndices.isEmpty) return 0;
    int bestIdx = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < stepIndices.length; i++) {
      final int kfIdx = widget.motion.keyframeForStep(stepIndices[i]);
      final double kfTime = widget.motion.timeline.timeForKeyframeIndex(kfIdx);
      final double diff = (kfTime - timeSec).abs();
      if (diff < minDiff) {
        minDiff = diff;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  void _play() {
    setState(() => _isPlaying = true);
    _controller.duration = Duration(
      milliseconds: math.max(
        200,
        ((widget.motion.timeline.totalDurationSec * 1000) / _speed).round(),
      ),
    );
    if (widget.motion.loop == LoopMode.pingPong) {
      _controller.repeat(reverse: true);
    } else if (widget.motion.loop == LoopMode.none) {
      _controller.forward();
    } else {
      _controller.repeat();
    }
    _resetHideTimer();
  }

  void _pause() {
    setState(() => _isPlaying = false);
    _controller.stop();
    _cancelHideTimer();
    setState(() => _controlsVisible = true);
  }

  void _togglePlayPause() {
    HapticFeedback.selectionClick();
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  void _toggleSpeed() {
    HapticFeedback.selectionClick();
    setState(() {
      _speed = _speed == 1.0 ? 0.5 : 1.0;
    });
    if (_isPlaying) {
      _play();
    }
  }

  void _toggleMirror() {
    HapticFeedback.selectionClick();
    setState(() {
      _mirrored = !_mirrored;
    });
  }

  void _springToStep(int stepIndex) {
    final List<int> stepIndices = widget.motion.stepIndices;
    if (stepIndices.isEmpty || stepIndex < 0 || stepIndex >= stepIndices.length) {
      return;
    }
    _pause();
    final int kfIdx = widget.motion.keyframeForStep(stepIndices[stepIndex]);
    final double targetSec = widget.motion.timeline.timeForKeyframeIndex(kfIdx);
    final double targetProgress =
        (targetSec / widget.motion.timeline.totalDurationSec).clamp(0.0, 1.0);

    // Smooth spring animation to the step pose
    _controller.animateTo(
      targetProgress,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onScrubStart(double value) {
    _pause();
  }

  void _onScrubUpdate(double value) {
    _controller.value = value;
    // Check if crossing a step tick for haptics
    final List<int> stepIndices = widget.motion.stepIndices;
    if (stepIndices.isNotEmpty) {
      final double timeSec = value * widget.motion.timeline.totalDurationSec;
      final int stepIdx = _computeActiveStepIndex(timeSec);
      if (stepIdx != _lastScrubTick) {
        _lastScrubTick = stepIdx;
        HapticFeedback.selectionClick();
      }
    }
  }

  void _onScrubEnd(double value) {
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    if (!_isPlaying) {
      setState(() => _controlsVisible = true);
      return;
    }
    setState(() => _controlsVisible = true);
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
  }

  void _onSurfaceTap() {
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
      _resetHideTimer();
    } else {
      _togglePlayPause();
    }
  }

  bool _isFemale(AppSettings settings, Profile? profile) {
    return switch (settings.figureBody) {
      FigureBodySetting.male => false,
      FigureBodySetting.female => true,
      FigureBodySetting.followProfile => profile?.sex == Sex.female,
    };
  }

  @override
  Widget build(BuildContext context) {
    final AppSettings settings = ref.watch(settingsProvider);
    final Profile? profile = ref.watch(currentProfileProvider).value;
    final bool female = _isFemale(settings, profile);
    final FigureColors figColors = context.figureColors;
    final ColorScheme cs = context.cs;

    final double totalSec = widget.motion.timeline.totalDurationSec;
    final double currentSec = _controller.value * totalSec;

    return Semantics(
      container: true,
      label: 'Exercise figure animation for ${widget.motion.exerciseId}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onSurfaceTap,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: Radii.cardR,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Figure canvas
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(double.infinity, widget.height),
                  painter: FigurePainter(
                    motion: widget.motion,
                    colors: figColors,
                    animation: _controller,
                    female: female,
                    mirror: _mirrored,
                    repaint: _controller,
                  ),
                ),
              ),

              // Controls Overlay (with fade transition)
              if (widget.showControls)
                AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Top bar pills (Speed + Switch Side)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.md,
                            vertical: Space.xs,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              // Mirror / Switch Side button
                              if (widget.motion.mirror)
                                _PillButton(
                                  label: _mirrored ? 'Side B' : 'Side A',
                                  icon: Icons.swap_horiz_rounded,
                                  onTap: _toggleMirror,
                                  semanticLabel: 'Switch side to ${_mirrored ? 'Side A' : 'Side B'}',
                                ),
                              const SizedBox(width: Space.xs),
                              // Speed toggle
                              _PillButton(
                                label: '${_speed}x',
                                onTap: _toggleSpeed,
                                semanticLabel: 'Toggle playback speed, currently ${_speed}x',
                              ),
                            ],
                          ),
                        ),

                        // Bottom scrub bar + Play/Pause
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.md,
                            vertical: Space.xxs,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.transparent,
                                cs.surface.withValues(alpha: 0.6),
                                cs.surface.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              // Play / Pause Icon Button
                              IconButton(
                                iconSize: 28,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                                icon: AnimatedIcon(
                                  icon: AnimatedIcons.play_pause,
                                  progress: _controller,
                                  color: cs.onSurface,
                                ),
                                tooltip: _isPlaying ? 'Pause' : 'Play',
                                onPressed: _togglePlayPause,
                              ),
                              const SizedBox(width: Space.xs),

                              // Scrub Slider with step ticks
                              Expanded(
                                child: _ScrubBarWithTicks(
                                  progress: _controller.value,
                                  stepFractions: _computeStepFractions(),
                                  onChanged: _onScrubUpdate,
                                  onChangeStart: _onScrubStart,
                                  onChangeEnd: _onScrubEnd,
                                ),
                              ),
                              const SizedBox(width: Space.sm),

                              // Time label
                              Text(
                                '${currentSec.toStringAsFixed(1)}s',
                                style: context.text.labelSmall!.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontFeatures: const <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<double> _computeStepFractions() {
    final List<int> stepIndices = widget.motion.stepIndices;
    if (stepIndices.isEmpty) return const <double>[];
    final double totalSec = widget.motion.timeline.totalDurationSec;
    if (totalSec <= 0) return const <double>[];

    return stepIndices.map((int stepIdx) {
      final int kfIdx = widget.motion.keyframeForStep(stepIdx);
      final double timeSec = widget.motion.timeline.timeForKeyframeIndex(kfIdx);
      return (timeSec / totalSec).clamp(0.0, 1.0);
    }).toList();
  }
}

/// Small stadium pill button for speed and mirror toggles.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    required this.semanticLabel,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final String semanticLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.85),
        borderRadius: Radii.fullR,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.sm,
              vertical: Space.xxs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 14, color: cs.onSurface),
                  const SizedBox(width: Space.xxs),
                ],
                Text(
                  label,
                  style: context.text.labelSmall!.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Slider with visual step tick markers drawn along the track.
class _ScrubBarWithTicks extends StatelessWidget {
  const _ScrubBarWithTicks({
    required this.progress,
    required this.stepFractions,
    required this.onChanged,
    required this.onChangeStart,
    required this.onChangeEnd,
  });

  final double progress;
  final List<double> stepFractions;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;

    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        // Custom Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.0,
            activeTrackColor: cs.primary,
            inactiveTrackColor: cs.surfaceContainerHighest,
            thumbColor: cs.primary,
            overlayColor: cs.primary.withValues(alpha: 0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: onChanged,
            onChangeStart: onChangeStart,
            onChangeEnd: onChangeEnd,
          ),
        ),

        // Tick marks under thumb
        if (stepFractions.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CustomPaint(
                  painter: _TickMarksPainter(
                    fractions: stepFractions,
                    tickColor: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TickMarksPainter extends CustomPainter {
  _TickMarksPainter({required this.fractions, required this.tickColor});

  final List<double> fractions;
  final Color tickColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = tickColor
      ..style = PaintingStyle.fill;

    final double centerY = size.height * 0.5;
    for (final double f in fractions) {
      final double x = f * size.width;
      canvas.drawCircle(Offset(x, centerY), 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TickMarksPainter oldDelegate) =>
      oldDelegate.fractions != fractions || oldDelegate.tickColor != tickColor;
}
