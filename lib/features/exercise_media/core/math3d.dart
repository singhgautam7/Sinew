// PURE DART: No Flutter imports. Mathematical primitives for 3D figure kinematics.
//
// Conventions:
// - Coordinate system: Right-handed
//   +x = forward (figure's facing direction in neutral pose)
//   +y = up (head towards ceiling)
//   +z = left (figure's left arm)
//   -z = right (figure's right arm)
// - Euler rotations: R = Rx * Ry * Rz in degrees
// - Quaternions: Unit quaternions Q = [w, x, y, z]

import 'dart:math' as math;

/// 3D Vector.
class Vec3 {
  const Vec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const Vec3 zero = Vec3(0, 0, 0);
  static const Vec3 unitX = Vec3(1, 0, 0);
  static const Vec3 unitY = Vec3(0, 1, 0);
  static const Vec3 unitZ = Vec3(0, 0, 1);

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 operator -() => Vec3(-x, -y, -z);
  Vec3 operator *(double s) => Vec3(x * s, y * s, z * s);
  Vec3 operator /(double s) => Vec3(x / s, y / s, z / s);

  double dot(Vec3 o) => x * o.x + y * o.y + z * o.z;

  Vec3 cross(Vec3 o) => Vec3(
    y * o.z - z * o.y,
    z * o.x - x * o.z,
    x * o.y - y * o.x,
  );

  double get lengthSq => x * x + y * y + z * z;
  double get length => math.sqrt(lengthSq);

  Vec3 normalized() {
    final double l = length;
    if (l < 1e-9) return zero;
    return this / l;
  }

  @override
  String toString() => 'Vec3(${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)}, ${z.toStringAsFixed(3)})';
}

/// Unit Quaternion for 3D rotations.
class Quat {
  const Quat(this.w, this.x, this.y, this.z);

  final double w;
  final double x;
  final double y;
  final double z;

  static const Quat identity = Quat(1, 0, 0, 0);

  Quat operator *(Quat o) => Quat(
    w * o.w - x * o.x - y * o.y - z * o.z,
    w * o.x + x * o.w + y * o.z - z * o.y,
    w * o.y - x * o.z + y * o.w + z * o.x,
    w * o.z + x * o.y - y * o.x + z * o.w,
  );

  Quat conjugate() => Quat(w, -x, -y, -z);

  double get lengthSq => w * w + x * x + y * y + z * z;
  double get length => math.sqrt(lengthSq);

  Quat normalized() {
    final double l = length;
    if (l < 1e-9) return identity;
    return Quat(w / l, x / l, y / l, z / l);
  }

  /// Rotates 3D vector [v] by this quaternion: v' = q * (0, v) * q*
  Vec3 rotateVec(Vec3 v) {
    // Optimized Rodrigues-like quaternion rotation
    final double tx = 2.0 * (y * v.z - z * v.y);
    final double ty = 2.0 * (z * v.x - x * v.z);
    final double tz = 2.0 * (x * v.y - y * v.x);

    return Vec3(
      v.x + w * tx + (y * tz - z * ty),
      v.y + w * ty + (z * tx - x * tz),
      v.z + w * tz + (x * ty - y * tx),
    );
  }

  /// Creates a rotation quaternion from an axis and angle in degrees.
  static Quat fromAxisAngle(Vec3 axis, double angleDeg) {
    final double rad = angleDeg * (math.pi / 180.0) * 0.5;
    final Vec3 n = axis.normalized();
    final double s = math.sin(rad);
    return Quat(math.cos(rad), n.x * s, n.y * s, n.z * s);
  }

  /// Euler XYZ in degrees: R = Rx * Ry * Rz matching tool/pipeline/rig.py.
  static Quat fromEuler(double rxDeg, double ryDeg, double rzDeg) {
    final Quat qx = fromAxisAngle(Vec3.unitX, rxDeg);
    final Quat qy = fromAxisAngle(Vec3.unitY, ryDeg);
    final Quat qz = fromAxisAngle(Vec3.unitZ, rzDeg);
    return (qx * qy * qz).normalized();
  }

  /// Spherical linear interpolation between [q0] and [q1] with fraction [t].
  /// Guarantees shortest path (no 360-degree flips).
  static Quat slerp(Quat q0, Quat q1, double t) {
    double cosHalfTheta = q0.w * q1.w + q0.x * q1.x + q0.y * q1.y + q0.z * q1.z;
    Quat target = q1;
    if (cosHalfTheta < 0.0) {
      target = Quat(-q1.w, -q1.x, -q1.y, -q1.z);
      cosHalfTheta = -cosHalfTheta;
    }

    if (cosHalfTheta >= 1.0 - 1e-6) {
      return Quat(
        q0.w + t * (target.w - q0.w),
        q0.x + t * (target.x - q0.x),
        q0.y + t * (target.y - q0.y),
        q0.z + t * (target.z - q0.z),
      ).normalized();
    }

    final double halfTheta = math.acos(cosHalfTheta);
    final double sinHalfTheta = math.sqrt(1.0 - cosHalfTheta * cosHalfTheta);
    final double ratioA = math.sin((1.0 - t) * halfTheta) / sinHalfTheta;
    final double ratioB = math.sin(t * halfTheta) / sinHalfTheta;

    return Quat(
      q0.w * ratioA + target.w * ratioB,
      q0.x * ratioA + target.x * ratioB,
      q0.y * ratioA + target.y * ratioB,
      q0.z * ratioA + target.z * ratioB,
    ).normalized();
  }

  @override
  String toString() => 'Quat(${w.toStringAsFixed(3)}, ${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)}, ${z.toStringAsFixed(3)})';
}
