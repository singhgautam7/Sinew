// PURE DART: No Flutter imports. Timeline and keyframe interpolation.

import 'math3d.dart';
import 'pose_buffer.dart';
import 'rig_def.dart';

enum EaseCurve {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  spring;

  static EaseCurve parse(String s) => switch (s.toLowerCase()) {
    'easein' => EaseCurve.easeIn,
    'easeout' => EaseCurve.easeOut,
    'easeinout' => EaseCurve.easeInOut,
    'spring' => EaseCurve.spring,
    _ => EaseCurve.linear,
  };

  double apply(double t) {
    final double clamped = t.clamp(0.0, 1.0);
    return switch (this) {
      EaseCurve.linear => clamped,
      EaseCurve.easeIn => clamped * clamped,
      EaseCurve.easeOut => 1.0 - (1.0 - clamped) * (1.0 - clamped),
      EaseCurve.easeInOut => clamped < 0.5
          ? 2.0 * clamped * clamped
          : 1.0 - 2.0 * (1.0 - clamped) * (1.0 - clamped),
      EaseCurve.spring => _easeOutBack(clamped),
    };
  }

  static double _easeOutBack(double t) {
    const double c1 = 1.70158;
    const double c3 = c1 + 1.0;
    final double tm1 = t - 1.0;
    return 1.0 + c3 * tm1 * tm1 * tm1 + c1 * tm1 * tm1;
  }
}

enum LoopMode {
  repeat,
  pingPong,
  none;

  static LoopMode parse(String s) => switch (s.toLowerCase()) {
    'pingpong' || 'ping_pong' => LoopMode.pingPong,
    'none' => LoopMode.none,
    _ => LoopMode.repeat,
  };
}

class PoseKeyframe {
  const PoseKeyframe({
    required this.id,
    required this.rootPos,
    required this.rootRot,
    required this.joints,
  });

  final String id;
  final Vec3 rootPos;
  final Quat rootRot;
  final List<Quat> joints; // 19 local rotations
}

class TimelineSegment {
  const TimelineSegment({
    required this.fromIndex,
    required this.toIndex,
    required this.durationSec,
    this.ease = EaseCurve.linear,
  });

  final int fromIndex;
  final int toIndex;
  final double durationSec;
  final EaseCurve ease;
}

class MotionTimeline {
  MotionTimeline({
    required this.keyframes,
    required this.segments,
    this.loop = LoopMode.repeat,
  }) : totalDurationSec = segments.fold<double>(
         0.0,
         (double sum, TimelineSegment s) => sum + s.durationSec,
       );

  final List<PoseKeyframe> keyframes;
  final List<TimelineSegment> segments;
  final LoopMode loop;
  final double totalDurationSec;

  /// Returns the time in seconds for keyframe [index].
  double timeForKeyframeIndex(int index) {
    if (segments.isEmpty || index <= 0) return 0.0;
    double accum = 0.0;
    for (final TimelineSegment seg in segments) {
      if (seg.toIndex == index) return accum + seg.durationSec;
      accum += seg.durationSec;
    }
    return 0.0;
  }

  /// Evaluates timeline at [timeSec] and writes interpolated pose directly into [out].
  void evaluate(double timeSec, PoseBuffer out) {
    if (keyframes.isEmpty) return;

    if (keyframes.length == 1 || segments.isEmpty || totalDurationSec <= 1e-6) {
      _writeKeyframe(keyframes.first, out);
      return;
    }

    double t = timeSec;
    switch (loop) {
      case LoopMode.repeat:
        t = t % totalDurationSec;
        if (t < 0.0) t += totalDurationSec;
      case LoopMode.pingPong:
        final double cycle = totalDurationSec * 2.0;
        double rem = t % cycle;
        if (rem < 0.0) rem += cycle;
        if (rem > totalDurationSec) {
          t = cycle - rem;
        } else {
          t = rem;
        }
      case LoopMode.none:
        t = t.clamp(0.0, totalDurationSec);
    }

    // Find active segment
    double accum = 0.0;
    TimelineSegment activeSeg = segments.first;
    double segLocalTime = 0.0;

    for (final TimelineSegment seg in segments) {
      if (t <= accum + seg.durationSec || identical(seg, segments.last)) {
        activeSeg = seg;
        segLocalTime = (t - accum).clamp(0.0, seg.durationSec);
        break;
      }
      accum += seg.durationSec;
    }

    final double rawFraction = activeSeg.durationSec > 1e-6
        ? (segLocalTime / activeSeg.durationSec)
        : 1.0;
    final double easedFraction = activeSeg.ease.apply(rawFraction);

    final PoseKeyframe kfFrom = keyframes[activeSeg.fromIndex];
    final PoseKeyframe kfTo = keyframes[activeSeg.toIndex];

    _interpolate(kfFrom, kfTo, easedFraction, out);
  }

  void _writeKeyframe(PoseKeyframe kf, PoseBuffer out) {
    out.rootPosX = kf.rootPos.x;
    out.rootPosY = kf.rootPos.y;
    out.rootPosZ = kf.rootPos.z;

    out.rootRotW = kf.rootRot.w;
    out.rootRotX = kf.rootRot.x;
    out.rootRotY = kf.rootRot.y;
    out.rootRotZ = kf.rootRot.z;

    for (int i = 0; i < RigDef.jointNames.length; i++) {
      out.setLocalRot(i, kf.joints[i]);
    }
  }

  void _interpolate(
    PoseKeyframe from,
    PoseKeyframe to,
    double fraction,
    PoseBuffer out,
  ) {
    // 1. Root translation: linear lerp
    out.rootPosX = from.rootPos.x + fraction * (to.rootPos.x - from.rootPos.x);
    out.rootPosY = from.rootPos.y + fraction * (to.rootPos.y - from.rootPos.y);
    out.rootPosZ = from.rootPos.z + fraction * (to.rootPos.z - from.rootPos.z);

    // 2. Root rotation: slerp
    final Quat r = Quat.slerp(from.rootRot, to.rootRot, fraction);
    out.rootRotW = r.w;
    out.rootRotX = r.x;
    out.rootRotY = r.y;
    out.rootRotZ = r.z;

    // 3. 19 joint local rotations: slerp
    for (int i = 0; i < RigDef.jointNames.length; i++) {
      final Quat q = Quat.slerp(from.joints[i], to.joints[i], fraction);
      out.setLocalRot(i, q);
    }
  }
}
