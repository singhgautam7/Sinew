// Yoga flow figure widget for timer flow mode.
//
// Renders active yoga pose synced to interval duration,
// pauses when timer pauses, and smoothly morphs/cross-fades between poses.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/theme/app_theme.dart' hide Motion;
import 'package:sinew/core/theme/figure_colors.dart';

import '../data/motion_model.dart';
import '../render/figure_painter.dart';
import 'media_providers.dart';

class YogaFlowFigure extends ConsumerWidget {
  const YogaFlowFigure({
    super.key,
    required this.exerciseId,
    required this.progress,
    required this.paused,
    this.height = 140.0,
  });

  final String exerciseId;
  final double progress;
  final bool paused;
  final double height;

  bool _isFemale(AppSettings settings, Profile? profile) {
    return switch (settings.figureBody) {
      FigureBodySetting.male => false,
      FigureBodySetting.female => true,
      FigureBodySetting.followProfile => profile?.sex == Sex.female,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Motion?> motionAsync = ref.watch(motionProvider(exerciseId));
    final AppSettings settings = ref.watch(settingsProvider);
    final Profile? profile = ref.watch(currentProfileProvider).value;
    final bool female = _isFemale(settings, profile);
    final FigureColors figColors = context.figureColors;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      child: motionAsync.when(
        loading: () => SizedBox(key: ValueKey<String>('loading_$exerciseId'), height: height),
        error: (Object _, StackTrace? _) => SizedBox(key: ValueKey<String>('error_$exerciseId'), height: height),
        data: (Motion? motion) {
          if (motion == null) {
            return SizedBox(key: ValueKey<String>('none_$exerciseId'), height: height);
          }

          return Container(
            key: ValueKey<String>('figure_${exerciseId}_$female'),
            height: height,
            alignment: Alignment.center,
            child: CustomPaint(
              size: Size(height * 1.2, height),
              painter: FigurePainter(
                motion: motion,
                colors: figColors,
                female: female,
                // In yoga flow, hold the textbook keyframe (e.g. index 0 or first step frame)
                staticKeyframeIndex: motion.stepIndices.isNotEmpty
                    ? motion.keyframeForStep(motion.stepIndices.first)
                    : 0,
              ),
            ),
          );
        },
      ),
    );
  }
}
