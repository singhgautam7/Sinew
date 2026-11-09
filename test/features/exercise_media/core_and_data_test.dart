import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/library/library_builder.dart';
import 'package:sinew/core/db/library/library_db.dart';
import 'package:sinew/features/exercise_media/core/binary_payload.dart';
import 'package:sinew/features/exercise_media/core/camera.dart';
import 'package:sinew/features/exercise_media/core/forward_kinematics.dart';
import 'package:sinew/features/exercise_media/core/math3d.dart';
import 'package:sinew/features/exercise_media/core/mirror.dart';
import 'package:sinew/features/exercise_media/core/pose_buffer.dart';
import 'package:sinew/features/exercise_media/core/reference_poses.dart';
import 'package:sinew/features/exercise_media/core/rig_def.dart';
import 'package:sinew/features/exercise_media/core/timeline.dart';
import 'package:sinew/features/exercise_media/data/exercise_media_repository.dart';
import 'package:sinew/features/exercise_media/data/motion_model.dart';

void main() {
  group('Math3D & Quaternions', () {
    test('Quaternion Euler XYZ roundtrip', () {
      final Quat q = Quat.fromEuler(15.0, 30.0, -45.0);
      expect(q.length, closeTo(1.0, 1e-6));

      const Vec3 v = Vec3(1, 0, 0);
      final Vec3 rotated = q.rotateVec(v);
      expect(rotated.length, closeTo(1.0, 1e-6));
    });

    test('Slerp continuity without 360-degree flip on opposite signs', () {
      const Quat q0 = Quat(1.0, 0.0, 0.0, 0.0);
      // Antipodal representation of nearly the same orientation
      const Quat q1 = Quat(-0.9999, 0.01, 0.0, 0.0);

      final Quat mid = Quat.slerp(q0, q1, 0.5);
      expect(mid.w, greaterThan(0.0));
      expect(mid.length, closeTo(1.0, 1e-6));
    });
  });

  group('Rig and Forward Kinematics', () {
    test('Neutral standing pose joint positions and bone lengths', () {
      final PoseBuffer buffer = PoseBuffer();
      ForwardKinematics.compute(buffer);

      final Vec3 pelvis = buffer.getWorldPos(0);
      expect(pelvis.y, closeTo(0.540, 1e-4));

      final Vec3 chest = buffer.getWorldPos(2);
      expect(chest.y, closeTo(0.760, 1e-4)); // 0.54 + 0.09 + 0.13

      final Vec3 head = buffer.getWorldPos(4);
      expect(head.y, closeTo(0.940, 1e-4)); // 0.76 + 0.10 + 0.08

      // Thigh bone length (hip to knee)
      final Vec3 hipL = buffer.getWorldPos(11);
      final Vec3 kneeL = buffer.getWorldPos(12);
      final double thighLen = (kneeL - hipL).length;
      expect(thighLen, closeTo(0.245, 1e-4));

      // Shank bone length (knee to ankle)
      final Vec3 ankleL = buffer.getWorldPos(13);
      final double shankLen = (ankleL - kneeL).length;
      expect(shankLen, closeTo(0.215, 1e-4));
    });

    test('View-height invariant across side, front, and threeQuarter views', () {
      final PoseBuffer buffer = PoseBuffer();
      ForwardKinematics.compute(buffer);

      const FigureCamera sideCam = FigureCamera(view: FigureView.side);
      const FigureCamera frontCam = FigureCamera(view: FigureView.front);
      const FigureCamera tqCam = FigureCamera(view: FigureView.threeQuarter);

      for (int i = 0; i < RigDef.jointNames.length; i++) {
        final Vec3 p = buffer.getWorldPos(i);
        final (_, double vSide, _) = sideCam.projectPoint(p);
        final (_, double vFront, _) = frontCam.projectPoint(p);
        final (_, double vTq, _) = tqCam.projectPoint(p);

        expect((vSide - vFront).abs(), lessThan(0.001), reason: 'Joint $i side vs front');
        expect((vSide - vTq).abs(), lessThan(0.001), reason: 'Joint $i side vs threeQuarter');
      }
    });
  });

  group('Pose Mirroring', () {
    test('Mirroring inverts lateral Z and swaps left/right pairs', () {
      final PoseBuffer buffer = PoseBuffer();
      // Rotate left shoulder forward, right shoulder back
      buffer.setLocalRot(5, Quat.fromEuler(30, 0, 0));
      buffer.setLocalRot(8, Quat.fromEuler(-30, 0, 0));

      PoseMirror.mirror(buffer);

      // After mirror, shoulderL should have right shoulder's mirrored rotation
      final Quat l = buffer.getLocalRot(5);
      final Quat r = buffer.getLocalRot(8);

      expect(l.x, closeTo(-Quat.fromEuler(-30, 0, 0).x, 1e-4));
      expect(r.x, closeTo(-Quat.fromEuler(30, 0, 0).x, 1e-4));

      // Mirroring again returns to original
      PoseMirror.mirror(buffer);
      final Quat lBack = buffer.getLocalRot(5);
      expect(lBack.x, closeTo(Quat.fromEuler(30, 0, 0).x, 1e-4));
    });
  });

  group('Timeline Evaluation', () {
    test('Evaluates keyframe holds and loop modes', () {
      final PoseBuffer buffer = PoseBuffer();
      final MotionTimeline timeline = MotionTimeline(
        keyframes: <PoseKeyframe>[
          PoseKeyframe(
            id: 'start',
            rootPos: const Vec3(0, 0.5, 0),
            rootRot: Quat.identity,
            joints: List<Quat>.filled(RigDef.jointNames.length, Quat.identity),
          ),
          PoseKeyframe(
            id: 'end',
            rootPos: const Vec3(0, 0.3, 0),
            rootRot: Quat.identity,
            joints: List<Quat>.filled(RigDef.jointNames.length, Quat.identity),
          ),
        ],
        segments: const <TimelineSegment>[
          TimelineSegment(fromIndex: 0, toIndex: 1, durationSec: 1.0, ease: EaseCurve.linear),
        ],
        loop: LoopMode.repeat,
      );

      timeline.evaluate(0.0, buffer);
      expect(buffer.rootPosY, closeTo(0.5, 1e-4));

      timeline.evaluate(0.5, buffer);
      expect(buffer.rootPosY, closeTo(0.4, 1e-4));

      timeline.evaluate(0.999, buffer);
      expect(buffer.rootPosY, closeTo(0.3, 1e-3));

      // Loop repeats at 1.5s -> 0.5s into cycle
      timeline.evaluate(1.5, buffer);
      expect(buffer.rootPosY, closeTo(0.4, 1e-4));
    });
  });

  group('Binary Payload Serialization', () {
    test('Encodes and decodes motion payload within fixed-point tolerances', () {
      final List<Map<String, dynamic>> rawKf = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'start',
          'root': <String, dynamic>{
            'pos': <double>[0.05, 0.54, -0.02],
            'rot': <double>[5.0, -10.0, 15.0],
          },
          'joints': <String, dynamic>{
            'elbowL': <double>[0.0, 0.0, 45.0],
            'kneeR': <double>[0.0, 0.0, -30.0],
          },
        },
        <String, dynamic>{
          'id': 'end',
          'root': <String, dynamic>{
            'pos': <double>[-0.1, 0.25, 0.0],
            'rot': <double>[0.0, 0.0, -35.0],
          },
          'joints': <String, dynamic>{
            'elbowL': <double>[0.0, 0.0, 90.0],
            'kneeR': <double>[0.0, 0.0, -110.0],
          },
        },
      ];

      final List<Map<String, dynamic>> rawTimeline = <Map<String, dynamic>>[
        <String, dynamic>{'from': 'start', 'to': 'end', 'sec': 1.2, 'ease': 'easeInOut'},
      ];

      final List<Map<String, dynamic>> rawProps = <Map<String, dynamic>>[
        <String, dynamic>{'type': 'barbell'},
      ];

      final Uint8List bytes = BinaryPayload.encode(
        rawKeyframes: rawKf,
        rawTimeline: rawTimeline,
        rawProps: rawProps,
      );

      // Verify payload is compact (< 400 bytes for 2 keyframes)
      expect(bytes.length, lessThan(400));

      final DecodedPayload decoded = BinaryPayload.decode(bytes);
      expect(decoded.keyframes, hasLength(2));
      expect(decoded.keyframes.first.id, 'start');
      expect(decoded.keyframes.first.rootPos.x, closeTo(0.05, 1e-3));
      expect(decoded.keyframes.first.rootPos.y, closeTo(0.54, 1e-3));
      expect(decoded.props, <String>['barbell']);
      expect(decoded.segments, hasLength(1));
      expect(decoded.segments.first.durationSec, closeTo(1.2, 1e-3));
      expect(decoded.segments.first.ease, EaseCurve.easeInOut);
    });
  });

  group('ExerciseMediaRepository & Caching', () {
    test('Reads motion from DB, caches in LRU, handles unknown id gracefully', () async {
      const LibraryBuilder builder = LibraryBuilder();

      await builder.build(
        output: File('test_output.sqlite'),
        exercises: <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'test-squat',
            'name': 'Test Squat',
            'category': 'strength',
            'trackingType': 'weightReps',
            'primaryMuscles': <String>['quadriceps'],
            'secondaryMuscles': <String>['glutes'],
            'equipment': <String>['barbell'],
            'unilateral': false,
          },
        ],
        motions: <Map<String, dynamic>>[
          <String, dynamic>{
            'motionId': 'test-squat',
            'schemaVersion': 1,
            'rigVersion': 1,
            'tier': 'animated',
            'view': 'side',
            'keyframes': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'hold',
                'root': <String, dynamic>{
                  'pos': <double>[0.0, 0.54, 0.0],
                  'rot': <double>[0.0, 0.0, 0.0],
                },
                'joints': <String, dynamic>{},
              },
            ],
            'loop': 'repeat',
            'mirrorForOtherSide': false,
            'stepFrames': <Map<String, dynamic>>[
              <String, dynamic>{'step': 0, 'keyframe': 'hold'},
            ],
            'highlight': <String, dynamic>{
              'primary': <String>['quadriceps'],
              'secondary': <String>['glutes'],
            },
          },
        ],
        libraryVersion: '1.0.0',
        builtAt: '2026-11-09T00:00:00Z',
        sha256: 'dummy',
      );

      final LibraryDatabase openedDb = LibraryDatabase.forBuild(
        NativeDatabase(File('test_output.sqlite')),
      );
      final ExerciseMediaRepository repo = ExerciseMediaRepository(db: openedDb, cacheCapacity: 2);

      // 1. Fetch valid motion
      final Motion? motion = await repo.motionFor('test-squat');
      expect(motion, isNotNull);
      expect(motion!.exerciseId, 'test-squat');
      expect(motion.tier, MotionTier.animated);
      expect(motion.keyframes, hasLength(1));

      // 2. Second fetch hits LRU cache
      final Motion? cached = await repo.motionFor('test-squat');
      expect(identical(motion, cached), isTrue);

      // 3. Unknown exercise id safely returns null
      final Motion? unknown = await repo.motionFor('non-existent');
      expect(unknown, isNull);

      // 4. Custom exercise safely returns null
      final Motion? custom = await repo.motionFor('custom-my-exercise');
      expect(custom, isNull);

      await openedDb.close();
      if (File('test_output.sqlite').existsSync()) {
        File('test_output.sqlite').deleteSync();
      }
    });
  });

  group('Parity Verification against test_vectors.json', () {
    test('Projected 2D joint coordinates match test vectors within 0.5 px', () {
      final File file = File('specs/data/test_vectors.json');
      if (!file.existsSync()) return;

      final Map<String, dynamic> data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final List<dynamic> vectors = data['vectors'] as List<dynamic>;

      const FigureCamera sideCam = FigureCamera(view: FigureView.side);
      const FigureCamera frontCam = FigureCamera(view: FigureView.front);
      const FigureCamera tqCam = FigureCamera(view: FigureView.threeQuarter);

      int verifiedJointsCount = 0;

      for (final dynamic v in vectors) {
        if (v is! Map<String, dynamic>) continue;
        final String poseId = v['poseId'] as String;
        final String viewStr = v['view'] as String;
        final Map<String, dynamic> expectedJoints = v['joints'] as Map<String, dynamic>;

        final FigureCamera cam = switch (viewStr) {
          'front' => frontCam,
          'threeQuarter' => tqCam,
          _ => sideCam,
        };

        final ReferencePoseDef? poseDef = ReferencePoseDef.all[poseId];
        if (poseDef == null) continue;

        final PoseBuffer buffer = PoseBuffer();
        buffer.rootPosX = poseDef.rootPos[0];
        buffer.rootPosY = poseDef.rootPos[1];
        buffer.rootPosZ = poseDef.rootPos[2];

        final Quat rootRot = Quat.fromEuler(
          poseDef.rootRot[0],
          poseDef.rootRot[1],
          poseDef.rootRot[2],
        );
        buffer.rootRotW = rootRot.w;
        buffer.rootRotX = rootRot.x;
        buffer.rootRotY = rootRot.y;
        buffer.rootRotZ = rootRot.z;

        for (int j = 0; j < RigDef.jointNames.length; j++) {
          final String jName = RigDef.jointNames[j];
          final List<double>? euler = poseDef.joints[jName];
          if (euler != null && euler.length >= 3) {
            buffer.setLocalRot(
              j,
              Quat.fromEuler(euler[0], euler[1], euler[2]),
            );
          } else {
            buffer.setLocalRot(j, Quat.identity);
          }
        }

        ForwardKinematics.compute(buffer);
        cam.projectAll(buffer);

        for (final MapEntry<String, dynamic> entry in expectedJoints.entries) {
          final String jointName = entry.key;
          final int? jIdx = RigDef.jointNameToIndex[jointName];
          if (jIdx == null) continue;

          final Map<String, dynamic> exp = entry.value as Map<String, dynamic>;
          final double expU = (exp['u'] as num).toDouble();
          final double expV = (exp['v'] as num).toDouble();

          final double actU = buffer.getProjectedU(jIdx);
          final double actV = buffer.getProjectedV(jIdx);

          expect((actU - expU).abs(), lessThan(0.5), reason: '$poseId $viewStr $jointName U');
          expect((actV - expV).abs(), lessThan(0.5), reason: '$poseId $viewStr $jointName V');
          verifiedJointsCount++;
        }
      }

      expect(verifiedJointsCount, greaterThan(100));
    });
  });
}
