// PURE DART: No Flutter imports. Mirroring across the sagittal (Z=0) plane.
//
// Inverts Z and swaps lateral joint pairs (L <-> R) so near and far tones and depth
// remain physically and visually correct without an artificial 2D canvas flip.

import 'math3d.dart';
import 'pose_buffer.dart';
import 'rig_def.dart';

abstract final class PoseMirror {
  static const Map<int, int> lateralSwaps = <int, int>{
    5: 8, // shoulderL <-> shoulderR
    6: 9, // elbowL <-> elbowR
    7: 10, // wristL <-> wristR
    11: 15, // hipL <-> hipR
    12: 16, // kneeL <-> kneeR
    13: 17, // ankleL <-> ankleR
    14: 18, // toeL <-> toeR
    8: 5,
    9: 6,
    10: 7,
    15: 11,
    16: 12,
    17: 13,
    18: 14,
  };

  /// Mirrors a quaternion across the Z = 0 plane.
  /// (w, x, y, z) -> (w, -x, -y, z)
  static Quat mirrorQuat(Quat q) => Quat(q.w, -q.x, -q.y, q.z);

  /// Mirrors the current local pose in [buffer] across the Z plane.
  static void mirror(PoseBuffer buffer) {
    // 1. Root position
    buffer.rootPosZ = -buffer.rootPosZ;

    // 2. Root rotation
    final Quat rootRot = Quat(
      buffer.rootRotW,
      buffer.rootRotX,
      buffer.rootRotY,
      buffer.rootRotZ,
    );
    final Quat mirroredRoot = mirrorQuat(rootRot);
    buffer.rootRotW = mirroredRoot.w;
    buffer.rootRotX = mirroredRoot.x;
    buffer.rootRotY = mirroredRoot.y;
    buffer.rootRotZ = mirroredRoot.z;

    // 3. Temporary copy of local rotations
    final List<Quat> original = <Quat>[
      for (int i = 0; i < RigDef.jointNames.length; i++) buffer.getLocalRot(i),
    ];

    // 4. Swap and reflect
    for (int i = 0; i < RigDef.jointNames.length; i++) {
      final int partner = lateralSwaps[i] ?? i;
      final Quat q = mirrorQuat(original[partner]);
      buffer.setLocalRot(i, q);
    }
  }
}
