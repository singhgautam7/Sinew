// Models for motion playback in the exercise media feature.

import '../core/camera.dart';
import '../core/timeline.dart';

enum MotionTier {
  animated,
  frames,
  mapOnly;

  static MotionTier parse(String s) => switch (s.toLowerCase()) {
    'animated' => MotionTier.animated,
    'frames' => MotionTier.frames,
    _ => MotionTier.mapOnly,
  };
}

class MotionHighlight {
  const MotionHighlight({
    this.primary = const <String>[],
    this.secondary = const <String>[],
  });

  final List<String> primary;
  final List<String> secondary;
}

class Motion {
  Motion({
    required this.exerciseId,
    required this.tier,
    required this.view,
    required this.loop,
    required this.mirror,
    required this.stepFrames,
    required this.highlight,
    required this.props,
    required this.timeline,
    this.motionRef,
  });

  final String exerciseId;
  final MotionTier tier;
  final FigureView view;
  final LoopMode loop;
  final bool mirror;

  /// Map of step index to keyframe ID (or null if no frame associated).
  final Map<int, String?> stepFrames;

  final MotionHighlight highlight;
  final List<String> props;
  final MotionTimeline timeline;

  /// Optional reference for custom exercises to adopt another exercise's figure.
  final String? motionRef;

  List<PoseKeyframe> get keyframes => timeline.keyframes;

  /// Sorted list of step indices present in this motion.
  List<int> get stepIndices => stepFrames.keys.toList()..sort();

  int? keyframeIndexForStep(int stepIndex) {
    final String? kfId = stepFrames[stepIndex];
    if (kfId == null) return null;
    final int idx = keyframes.indexWhere((PoseKeyframe kf) => kf.id == kfId);
    return idx >= 0 ? idx : null;
  }

  int keyframeForStep(int stepIndex) {
    return keyframeIndexForStep(stepIndex) ?? 0;
  }
}
