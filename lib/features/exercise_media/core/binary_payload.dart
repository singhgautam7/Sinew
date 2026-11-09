// PURE DART: No Flutter imports.
//
// Binary serializer & deserializer for motion keyframes, timeline, and props.
// Converts Euler angles to unit quaternions at compile time.
// Compact fixed-point int16 storage targeting < 1 KB per motion record.

import 'dart:convert';
import 'dart:typed_data';

import 'math3d.dart';
import 'rig_def.dart';
import 'timeline.dart';

abstract final class BinaryPayload {
  static const int currentVersion = 1;

  /// Positional fixed-point scale: 10,000 units per meter (0.1 mm precision).
  static const double posScale = 10000.0;

  /// Quaternion fixed-point scale: 32,767 for unit magnitude 1.0.
  static const double quatScale = 32767.0;

  /// Serializes motion data from raw JSON components into a compact binary Uint8List.
  static Uint8List encode({
    required List<Map<String, dynamic>> rawKeyframes,
    required List<Map<String, dynamic>>? rawTimeline,
    required List<Map<String, dynamic>>? rawProps,
  }) {
    final BytesBuilder bb = BytesBuilder(copy: false);

    // Header: version (1B), keyframe count (1B), segment count (1B), props count (1B)
    final int kCount = rawKeyframes.length;
    final int sCount = rawTimeline?.length ?? 0;
    final int pCount = rawProps?.length ?? 0;

    bb.addByte(currentVersion);
    bb.addByte(kCount);
    bb.addByte(sCount);
    bb.addByte(pCount);

    // Props
    if (rawProps != null) {
      for (final Map<String, dynamic> prop in rawProps) {
        final String pType = (prop['type'] as String?) ?? 'unknown';
        final List<int> pBytes = utf8.encode(pType);
        bb.addByte(pBytes.length);
        bb.add(pBytes);
      }
    }

    // Keyframes
    final Map<String, int> kfNameToIndex = <String, int>{};
    for (int k = 0; k < kCount; k++) {
      final Map<String, dynamic> kf = rawKeyframes[k];
      final String id = (kf['id'] as String?) ?? 'kf$k';
      kfNameToIndex[id] = k;

      final List<int> idBytes = utf8.encode(id);
      bb.addByte(idBytes.length);
      bb.add(idBytes);

      final Map<String, dynamic> root = (kf['root'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final List<dynamic> posList = (root['pos'] as List<dynamic>?) ?? <dynamic>[0.0, 0.54, 0.0];
      final List<dynamic> rotList = (root['rot'] as List<dynamic>?) ?? <dynamic>[0.0, 0.0, 0.0];

      // Root position: 3 x int16
      final ByteData bdPos = ByteData(6);
      bdPos.setInt16(0, (_toDouble(posList[0]) * posScale).round().clamp(-32768, 32767));
      bdPos.setInt16(2, (_toDouble(posList[1]) * posScale).round().clamp(-32768, 32767));
      bdPos.setInt16(4, (_toDouble(posList[2]) * posScale).round().clamp(-32768, 32767));
      bb.add(bdPos.buffer.asUint8List());

      // Root rotation: Euler deg -> Quat -> 4 x int16
      final Quat rootQuat = Quat.fromEuler(
        _toDouble(rotList[0]),
        _toDouble(rotList[1]),
        _toDouble(rotList[2]),
      );
      bb.add(_packQuat(rootQuat));

      // 19 joints local rotations
      final Map<String, dynamic> joints = (kf['joints'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final ByteData bdJoints = ByteData(RigDef.jointNames.length * 8);

      for (int j = 0; j < RigDef.jointNames.length; j++) {
        final String jName = RigDef.jointNames[j];
        final List<dynamic>? euler = joints[jName] as List<dynamic>?;
        final Quat q;
        if (euler != null && euler.length >= 3) {
          q = Quat.fromEuler(
            _toDouble(euler[0]),
            _toDouble(euler[1]),
            _toDouble(euler[2]),
          );
        } else {
          q = Quat.identity;
        }

        final int off = j * 8;
        bdJoints.setInt16(off, (q.w * quatScale).round().clamp(-32768, 32767));
        bdJoints.setInt16(off + 2, (q.x * quatScale).round().clamp(-32768, 32767));
        bdJoints.setInt16(off + 4, (q.y * quatScale).round().clamp(-32768, 32767));
        bdJoints.setInt16(off + 6, (q.z * quatScale).round().clamp(-32768, 32767));
      }
      bb.add(bdJoints.buffer.asUint8List());
    }

    // Timeline segments
    if (rawTimeline != null) {
      final ByteData bdSeg = ByteData(5);
      for (final Map<String, dynamic> seg in rawTimeline) {
        final String fromName = (seg['from'] as String?) ?? '';
        final String toName = (seg['to'] as String?) ?? '';
        final double sec = _toDouble(seg['sec'] ?? 1.0);
        final String easeName = (seg['ease'] as String?) ?? 'linear';

        final int fromIdx = kfNameToIndex[fromName] ?? 0;
        final int toIdx = kfNameToIndex[toName] ?? 0;
        final int durationMs = (sec * 1000.0).round().clamp(10, 65535);
        final int easeCode = EaseCurve.parse(easeName).index;

        bdSeg.setUint8(0, fromIdx);
        bdSeg.setUint8(1, toIdx);
        bdSeg.setUint16(2, durationMs);
        bdSeg.setUint8(4, easeCode);

        bb.add(bdSeg.buffer.asUint8List());
      }
    }

    return bb.takeBytes();
  }

  /// Decodes binary payload into decoded keyframes, timeline, and props list.
  static DecodedPayload decode(Uint8List bytes) {
    if (bytes.length < 4) {
      throw const FormatException('Payload too short');
    }
    final ByteData bd = ByteData.sublistView(bytes);
    int offset = 0;

    final int version = bd.getUint8(offset++);
    if (version != currentVersion) {
      throw FormatException('Unsupported payload version $version');
    }

    final int kCount = bd.getUint8(offset++);
    final int sCount = bd.getUint8(offset++);
    final int pCount = bd.getUint8(offset++);

    // Props
    final List<String> props = <String>[];
    for (int p = 0; p < pCount; p++) {
      final int len = bd.getUint8(offset++);
      final String propType = utf8.decode(bytes.sublist(offset, offset + len));
      offset += len;
      props.add(propType);
    }

    // Keyframes
    final List<PoseKeyframe> keyframes = <PoseKeyframe>[];
    for (int k = 0; k < kCount; k++) {
      final int idLen = bd.getUint8(offset++);
      final String id = utf8.decode(bytes.sublist(offset, offset + idLen));
      offset += idLen;

      final double px = bd.getInt16(offset) / posScale;
      final double py = bd.getInt16(offset + 2) / posScale;
      final double pz = bd.getInt16(offset + 4) / posScale;
      offset += 6;

      final Quat rootRot = _unpackQuat(bd, offset);
      offset += 8;

      final List<Quat> joints = <Quat>[];
      for (int j = 0; j < RigDef.jointNames.length; j++) {
        joints.add(_unpackQuat(bd, offset));
        offset += 8;
      }

      keyframes.add(
        PoseKeyframe(
          id: id,
          rootPos: Vec3(px, py, pz),
          rootRot: rootRot,
          joints: joints,
        ),
      );
    }

    // Timeline segments
    final List<TimelineSegment> segments = <TimelineSegment>[];
    for (int s = 0; s < sCount; s++) {
      final int fromIdx = bd.getUint8(offset++);
      final int toIdx = bd.getUint8(offset++);
      final int durationMs = bd.getUint16(offset);
      offset += 2;
      final int easeCode = bd.getUint8(offset++);

      final EaseCurve ease = easeCode < EaseCurve.values.length
          ? EaseCurve.values[easeCode]
          : EaseCurve.linear;

      segments.add(
        TimelineSegment(
          fromIndex: fromIdx,
          toIndex: toIdx,
          durationSec: durationMs / 1000.0,
          ease: ease,
        ),
      );
    }

    return DecodedPayload(
      props: props,
      keyframes: keyframes,
      segments: segments,
    );
  }

  static Uint8List _packQuat(Quat q) {
    final ByteData bd = ByteData(8);
    bd.setInt16(0, (q.w * quatScale).round().clamp(-32768, 32767));
    bd.setInt16(2, (q.x * quatScale).round().clamp(-32768, 32767));
    bd.setInt16(4, (q.y * quatScale).round().clamp(-32768, 32767));
    bd.setInt16(6, (q.z * quatScale).round().clamp(-32768, 32767));
    return bd.buffer.asUint8List();
  }

  static Quat _unpackQuat(ByteData bd, int offset) {
    final double w = bd.getInt16(offset) / quatScale;
    final double x = bd.getInt16(offset + 2) / quatScale;
    final double y = bd.getInt16(offset + 4) / quatScale;
    final double z = bd.getInt16(offset + 6) / quatScale;
    return Quat(w, x, y, z).normalized();
  }

  static double _toDouble(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}

class DecodedPayload {
  const DecodedPayload({
    required this.props,
    required this.keyframes,
    required this.segments,
  });

  final List<String> props;
  final List<PoseKeyframe> keyframes;
  final List<TimelineSegment> segments;
}
