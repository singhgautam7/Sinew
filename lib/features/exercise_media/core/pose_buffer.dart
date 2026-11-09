// PURE DART: No Flutter imports.
//
// Zero-allocation pre-allocated buffer for forward kinematics and projection.
import 'dart:typed_data';

import 'math3d.dart';
import 'rig_def.dart';

/// Pre-allocated buffer holding pose inputs, evaluated rotations, global joint positions,
/// and projected screen coordinates. Reused every frame without allocation.
class PoseBuffer {
  PoseBuffer()
      : localRotations = Float64List(RigDef.jointNames.length * 4),
        worldPositions = Float64List(RigDef.jointNames.length * 3),
        worldRotations = Float64List(RigDef.jointNames.length * 4),
        projected = Float64List(RigDef.jointNames.length * 3) {
    resetToIdentity();
  }

  /// Root position in world space: [x, y, z].
  double rootPosX = 0.0;
  double rootPosY = 0.540;
  double rootPosZ = 0.0;

  /// Root rotation quaternion: [w, x, y, z].
  double rootRotW = 1.0;
  double rootRotX = 0.0;
  double rootRotY = 0.0;
  double rootRotZ = 0.0;

  /// 19 local rotations: 4 floats each (w, x, y, z).
  final Float64List localRotations;

  /// 19 world positions: 3 floats each (x, y, z).
  final Float64List worldPositions;

  /// 19 world rotations: 4 floats each (w, x, y, z).
  final Float64List worldRotations;

  /// 19 projected coordinates: 3 floats each (screen_u, screen_v, depth_z).
  final Float64List projected;

  void resetToIdentity() {
    rootPosX = 0.0;
    rootPosY = 0.540;
    rootPosZ = 0.0;
    rootRotW = 1.0;
    rootRotX = 0.0;
    rootRotY = 0.0;
    rootRotZ = 0.0;

    for (int i = 0; i < RigDef.jointNames.length; i++) {
      final int off4 = i * 4;
      localRotations[off4] = 1.0; // w
      localRotations[off4 + 1] = 0.0; // x
      localRotations[off4 + 2] = 0.0; // y
      localRotations[off4 + 3] = 0.0; // z

      worldRotations[off4] = 1.0;
      worldRotations[off4 + 1] = 0.0;
      worldRotations[off4 + 2] = 0.0;
      worldRotations[off4 + 3] = 0.0;

      final int off3 = i * 3;
      worldPositions[off3] = 0.0;
      worldPositions[off3 + 1] = 0.0;
      worldPositions[off3 + 2] = 0.0;

      projected[off3] = 0.0;
      projected[off3 + 1] = 0.0;
      projected[off3 + 2] = 0.0;
    }
  }

  Vec3 getWorldPos(int jointIndex) {
    final int off = jointIndex * 3;
    return Vec3(worldPositions[off], worldPositions[off + 1], worldPositions[off + 2]);
  }

  void setWorldPos(int jointIndex, double x, double y, double z) {
    final int off = jointIndex * 3;
    worldPositions[off] = x;
    worldPositions[off + 1] = y;
    worldPositions[off + 2] = z;
  }

  Quat getWorldRot(int jointIndex) {
    final int off = jointIndex * 4;
    return Quat(worldRotations[off], worldRotations[off + 1], worldRotations[off + 2], worldRotations[off + 3]);
  }

  void setWorldRot(int jointIndex, double w, double x, double y, double z) {
    final int off = jointIndex * 4;
    worldRotations[off] = w;
    worldRotations[off + 1] = x;
    worldRotations[off + 2] = y;
    worldRotations[off + 3] = z;
  }

  Quat getLocalRot(int jointIndex) {
    final int off = jointIndex * 4;
    return Quat(localRotations[off], localRotations[off + 1], localRotations[off + 2], localRotations[off + 3]);
  }

  void setLocalRot(int jointIndex, Quat q) {
    final int off = jointIndex * 4;
    localRotations[off] = q.w;
    localRotations[off + 1] = q.x;
    localRotations[off + 2] = q.y;
    localRotations[off + 3] = q.z;
  }

  double getProjectedU(int jointIndex) => projected[jointIndex * 3];
  double getProjectedV(int jointIndex) => projected[jointIndex * 3 + 1];
  double getProjectedDepth(int jointIndex) => projected[jointIndex * 3 + 2];

  void setProjected(int jointIndex, double u, double v, double depth) {
    final int off = jointIndex * 3;
    projected[off] = u;
    projected[off + 1] = v;
    projected[off + 2] = depth;
  }
}
