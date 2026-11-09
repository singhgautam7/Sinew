// PURE DART: No Flutter imports. Camera and orthographic projection.
//
// Matches renderer.py and test_vectors.json. All rotation occurs strictly around
// the vertical +Y axis, ensuring zero vertical drift (<0.5 px) across views.

import 'dart:math' as math;

import 'math3d.dart';
import 'pose_buffer.dart';
import 'rig_def.dart';

enum FigureView {
  side,
  front,
  threeQuarter,
  top;

  static FigureView parse(String s) => switch (s.toLowerCase()) {
    'front' => FigureView.front,
    'threequarter' || 'three_quarter' => FigureView.threeQuarter,
    'top' => FigureView.top,
    _ => FigureView.side,
  };
}

class FigureCamera {
  const FigureCamera({
    this.view = FigureView.side,
    this.canvasW = 320.0,
    this.canvasH = 360.0,
    this.scale = 240.0,
    this.centerX = 0.0,
    this.marginBottom = 55.0,
  });

  final FigureView view;
  final double canvasW;
  final double canvasH;
  final double scale;
  final double centerX;
  final double marginBottom;

  static const double threeQuarterYawRad = 35.0 * (math.pi / 180.0);
  static final double _cosYaw = math.cos(threeQuarterYawRad);
  static final double _sinYaw = math.sin(threeQuarterYawRad);

  /// Projects a 3D point to (screen_u, screen_v, depth_z).
  (double u, double v, double depth) projectPoint(Vec3 p) {
    final double projX;
    final double projY;
    final double depth;

    switch (view) {
      case FigureView.side:
        // Looking from -Z towards +Z. Figure faces +X (screen right).
        projX = p.x;
        projY = p.y;
        depth = p.z;
      case FigureView.front:
        // Looking from +X towards -X. Figure's left (+Z) is on screen left.
        projX = p.z;
        projY = p.y;
        depth = -p.x;
      case FigureView.threeQuarter:
        // 35° yaw rotation around vertical axis Y
        projX = p.x * _cosYaw + p.z * _sinYaw;
        projY = p.y;
        depth = -p.x * _sinYaw + p.z * _cosYaw;
      case FigureView.top:
        projX = p.z;
        projY = -p.x;
        depth = p.y;
    }

    final double u = canvasW / 2.0 + (projX - centerX) * scale;
    final double v = canvasH - marginBottom - (projY * scale);
    return (u, v, depth);
  }

  /// Projects all 19 joints in [buffer] and writes them into [buffer.projected].
  void projectAll(PoseBuffer buffer) {
    for (int i = 0; i < RigDef.jointNames.length; i++) {
      final Vec3 worldPos = buffer.getWorldPos(i);
      final (double u, double v, double depth) = projectPoint(worldPos);
      buffer.setProjected(i, u, v, depth);
    }
  }
}
