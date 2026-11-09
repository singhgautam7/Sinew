// PURE DART: No Flutter imports. Forward kinematics solver.
//
// Computes world-space joint positions and rotations from root pose and local joint rotations.
// Directly updates PoseBuffer with zero allocations.

import 'math3d.dart';
import 'pose_buffer.dart';
import 'rig_def.dart';

abstract final class ForwardKinematics {
  /// Evaluates Forward Kinematics for the rig.
  ///
  /// [buffer] must contain the root position, root rotation, and local rotations for all 19 joints.
  /// Results are written directly into [buffer.worldPositions] and [buffer.worldRotations].
  static void compute(PoseBuffer buffer) {
    // 1. Pelvis (root)
    final Quat rootRot = Quat(
      buffer.rootRotW,
      buffer.rootRotX,
      buffer.rootRotY,
      buffer.rootRotZ,
    ).normalized();

    buffer.setWorldPos(0, buffer.rootPosX, buffer.rootPosY, buffer.rootPosZ);
    buffer.setWorldRot(0, rootRot.w, rootRot.x, rootRot.y, rootRot.z);

    // 2. Child joints in topological order (index 1 to 18)
    for (int i = 1; i < RigDef.jointNames.length; i++) {
      final int parent = RigDef.parentIndices[i];
      final Vec3 parentPos = buffer.getWorldPos(parent);
      final Quat parentRot = buffer.getWorldRot(parent);

      final Quat localRot = buffer.getLocalRot(i);
      final Quat globalRot = (parentRot * localRot).normalized();

      final Vec3 offset = RigDef.restOffsets[i];
      final Vec3 rotatedOffset = parentRot.rotateVec(offset);
      final Vec3 worldPos = parentPos + rotatedOffset;

      buffer.setWorldPos(i, worldPos.x, worldPos.y, worldPos.z);
      buffer.setWorldRot(i, globalRot.w, globalRot.x, globalRot.y, globalRot.z);
    }
  }
}
