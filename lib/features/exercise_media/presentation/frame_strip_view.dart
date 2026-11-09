// Frame strip viewer for exercises with 'frames' media tier or when reduced motion is active.
//
// Shows a pageable strip of keyframe poses corresponding to the exercise steps,
// with enlarged active card and indicator dots.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/theme/app_theme.dart' hide Motion;

import '../data/motion_model.dart';
import '../render/figure_painter.dart';

class FrameStripView extends ConsumerStatefulWidget {
  const FrameStripView({
    super.key,
    required this.motion,
    this.activeStepIndex = 0,
    this.onStepChanged,
    this.height = 260.0,
  });

  final Motion motion;
  final int activeStepIndex;
  final ValueChanged<int>? onStepChanged;
  final double height;

  @override
  ConsumerState<FrameStripView> createState() => _FrameStripViewState();
}

class _FrameStripViewState extends ConsumerState<FrameStripView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.activeStepIndex.clamp(0, _stepCount - 1),
      viewportFraction: 0.88,
    );
  }

  int get _stepCount => widget.motion.stepIndices.isEmpty
      ? 1
      : widget.motion.stepIndices.length;

  @override
  void didUpdateWidget(covariant FrameStripView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeStepIndex != widget.activeStepIndex &&
        _pageController.hasClients) {
      final int target = widget.activeStepIndex.clamp(0, _stepCount - 1);
      if (_pageController.page?.round() != target) {
        _pageController.animateToPage(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

    final List<int> stepIndices = widget.motion.stepIndices.isEmpty
        ? const <int>[0]
        : widget.motion.stepIndices;

    return Semantics(
      container: true,
      label: 'Exercise step frames for ${widget.motion.exerciseId}',
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: Radii.cardR,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            // PageView of step frames
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: stepIndices.length,
                onPageChanged: (int index) {
                  HapticFeedback.selectionClick();
                  widget.onStepChanged?.call(index);
                },
                itemBuilder: (BuildContext context, int index) {
                  final int kfIdx = widget.motion.keyframeForStep(stepIndices[index]);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.xs,
                      vertical: Space.xs,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: Radii.mediumR,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          CustomPaint(
                            painter: FigurePainter(
                              motion: widget.motion,
                              colors: figColors,
                              female: female,
                              staticKeyframeIndex: kfIdx,
                            ),
                          ),
                          // Step badge
                          Positioned(
                            top: Space.sm,
                            left: Space.sm,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Space.sm,
                                vertical: Space.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHigh.withValues(
                                  alpha: 0.85,
                                ),
                                borderRadius: Radii.fullR,
                              ),
                              child: Text(
                                'Step ${index + 1}',
                                style: context.text.labelSmall!.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Indicator dots
            if (stepIndices.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(stepIndices.length, (int i) {
                    final bool active = i == widget.activeStepIndex;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                        );
                        widget.onStepChanged?.call(i);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Space.xxs,
                        ),
                        width: active ? 16.0 : 6.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          color: active ? cs.primary : cs.outlineVariant,
                          borderRadius: Radii.fullR,
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
