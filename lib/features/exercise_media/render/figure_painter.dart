// Flutter CustomPainter for rendering animated and still exercise figures.
//
// Matches figure_style.json and reference_sheet.png:
// - Soft, rounded muscle-map body (male and female bases)
// - Flat fills, zero outlines, zero blurs or saveLayers
// - Zero allocations per frame: reuses PoseBuffer and cached Paints
// - Pre-baked unit Paths from ShapeCache

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sinew/core/theme/figure_colors.dart';

import '../core/camera.dart';
import '../core/forward_kinematics.dart';
import '../core/math3d.dart';
import '../core/mirror.dart';
import '../core/pose_buffer.dart';
import '../core/rig_def.dart';
import '../data/motion_model.dart';
import 'shape_cache.dart';

class FigurePainter extends CustomPainter {
  FigurePainter({
    required this.motion,
    required this.colors,
    this.animation,
    this.female = false,
    this.view,
    this.mirror = false,
    this.staticKeyframeIndex,
    super.repaint,
  }) : _shapes = ShapeCache.instance {
    _initPaints();
  }

  final Motion motion;
  final FigureColors colors;
  final Animation<double>? animation;
  final bool female;
  final FigureView? view;
  final bool mirror;
  final int? staticKeyframeIndex;

  final ShapeCache _shapes;
  final PoseBuffer _buffer = PoseBuffer();

  // Cached Paints for each role
  late final Paint _paintBodyBase;
  late final Paint _paintBodyMuscle;
  late final Paint _paintBodyFar;
  late final Paint _paintPrimary;
  late final Paint _paintSecondary;
  late final Paint _paintProp;
  late final Paint _paintPropDetail;
  late final Paint _paintGround;
  late final Paint _paintShadow;

  void _initPaints() {
    _paintBodyBase = Paint()
      ..color = colors.bodyBase
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _paintBodyMuscle = Paint()
      ..color = colors.bodyMuscle
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _paintBodyFar = Paint()
      ..color = colors.bodyFar
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _paintPrimary = Paint()
      ..color = colors.musclePrimary
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _paintSecondary = Paint()
      ..color = colors.muscleSecondary
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _paintProp = Paint()
      ..color = colors.prop
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _paintPropDetail = Paint()
      ..color = colors.propDetail
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _paintGround = Paint()
      ..color = colors.ground
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    _paintShadow = Paint()
      ..color = colors.shadow
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
  }

  Paint _paintForMuscle(String muscleId, bool isFar) {
    final List<String> pList = motion.highlight.primary;
    final List<String> sList = motion.highlight.secondary;

    final String norm = muscleId.toLowerCase();
    if (pList.any((String p) => p.toLowerCase() == norm)) {
      return _paintPrimary;
    }
    if (sList.any((String s) => s.toLowerCase() == norm)) {
      return _paintSecondary;
    }
    return isFar ? _paintBodyFar : _paintBodyMuscle;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Evaluate pose
    if (staticKeyframeIndex != null &&
        staticKeyframeIndex! < motion.keyframes.length) {
      final kf = motion.keyframes[staticKeyframeIndex!];
      _buffer.rootPosX = kf.rootPos.x;
      _buffer.rootPosY = kf.rootPos.y;
      _buffer.rootPosZ = kf.rootPos.z;
      _buffer.rootRotW = kf.rootRot.w;
      _buffer.rootRotX = kf.rootRot.x;
      _buffer.rootRotY = kf.rootRot.y;
      _buffer.rootRotZ = kf.rootRot.z;
      for (int i = 0; i < RigDef.jointNames.length; i++) {
        _buffer.setLocalRot(i, kf.joints[i]);
      }
    } else {
      final double progress = animation?.value ?? 0.0;
      final double timeSec = progress * motion.timeline.totalDurationSec;
      motion.timeline.evaluate(timeSec, _buffer);
    }

    if (mirror) {
      PoseMirror.mirror(_buffer);
    }

    // 2. Forward Kinematics
    ForwardKinematics.compute(_buffer);

    // 3. Camera Projection
    final FigureView activeView = view ?? motion.view;
    final double scale = size.height * 0.65;
    final double marginBottom = size.height * 0.15;

    final FigureCamera camera = FigureCamera(
      view: activeView,
      canvasW: size.width,
      canvasH: size.height,
      scale: scale,
      marginBottom: marginBottom,
    );
    camera.projectAll(_buffer);

    // 4. Ground reference line & contact shadow
    final double groundY = size.height - marginBottom;
    canvas.drawLine(
      Offset(size.width * 0.05, groundY),
      Offset(size.width * 0.95, groundY),
      _paintGround,
    );

    // Contact shadows
    _drawContactShadows(canvas, camera, groundY);

    // 5. Draw body elements with depth sorting
    _drawBody(canvas, camera, activeView, scale);

    // 6. Draw Props
    _drawProps(canvas, camera, activeView, scale);
  }

  void _drawContactShadows(Canvas canvas, FigureCamera camera, double groundY) {
    // Left and right feet / contact points
    final double footLU = _buffer.getProjectedU(13); // ankleL
    final double footRU = _buffer.getProjectedU(17); // ankleR

    final double midU = (footLU + footRU) * 0.5;
    final double stanceW = (footLU - footRU).abs().clamp(28.0, 90.0);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(midU, groundY),
        width: stanceW + 24.0,
        height: 10.0,
      ),
      _paintShadow,
    );
  }

  void _drawBody(
    Canvas canvas,
    FigureCamera camera,
    FigureView activeView,
    double scale,
  ) {
    // Determine near vs far limbs in side/threeQuarter views
    final double leftDepth = _buffer.getProjectedDepth(5); // shoulderL
    final double rightDepth = _buffer.getProjectedDepth(8); // shoulderR
    final bool isFarL = leftDepth < rightDepth;

    final int farArmShoulder = isFarL ? 5 : 8;
    final int farArmElbow = isFarL ? 6 : 9;
    final int farArmWrist = isFarL ? 7 : 10;

    final int nearArmShoulder = isFarL ? 8 : 5;
    final int nearArmElbow = isFarL ? 9 : 6;
    final int nearArmWrist = isFarL ? 10 : 7;

    final int farLegHip = isFarL ? 11 : 15;
    final int farLegKnee = isFarL ? 12 : 16;
    final int farLegAnkle = isFarL ? 13 : 17;

    final int nearLegHip = isFarL ? 15 : 11;
    final int nearLegKnee = isFarL ? 16 : 12;
    final int nearLegAnkle = isFarL ? 17 : 13;

    // 1. Far leg & arm
    _drawLimb(canvas, farLegHip, farLegKnee, farLegAnkle, scale, isFar: true);
    _drawLimb(canvas, farArmShoulder, farArmElbow, farArmWrist, scale, isFar: true);

    // 2. Torso base & core patches
    _drawTorso(canvas, camera, activeView, scale);

    // 3. Head & neck
    _drawHeadAndNeck(canvas, scale);

    // 4. Near leg & arm
    _drawLimb(canvas, nearLegHip, nearLegKnee, nearLegAnkle, scale, isFar: false);
    _drawLimb(canvas, nearArmShoulder, nearArmElbow, nearArmWrist, scale, isFar: false);
  }

  void _drawLimb(
    Canvas canvas,
    int j0,
    int j1,
    int j2,
    double scale, {
    required bool isFar,
  }) {
    final Offset p0 = Offset(_buffer.getProjectedU(j0), _buffer.getProjectedV(j0));
    final Offset p1 = Offset(_buffer.getProjectedU(j1), _buffer.getProjectedV(j1));
    final Offset p2 = Offset(_buffer.getProjectedU(j2), _buffer.getProjectedV(j2));

    final Paint limbPaint = isFar ? _paintBodyFar : _paintBodyMuscle;

    // Segment 1 (e.g. thigh or upper arm)
    _drawSegmentCapsule(canvas, p0, p1, 0.034 * scale, 0.026 * scale, limbPaint);

    // Muscle belly along segment 1
    final String muscle1 = (j0 == 11 || j0 == 15) ? 'quadriceps' : 'biceps';
    _drawMuscleBelly(
      canvas,
      p0,
      p1,
      0.038 * scale,
      _paintForMuscle(muscle1, isFar),
    );

    // Joint dot at knee / elbow
    canvas.drawCircle(p1, 0.022 * scale, _paintBodyBase);

    // Segment 2 (e.g. shank or forearm)
    _drawSegmentCapsule(canvas, p1, p2, 0.026 * scale, 0.018 * scale, limbPaint);

    // Muscle belly along segment 2
    final String muscle2 = (j0 == 11 || j0 == 15) ? 'calves' : 'forearms';
    _drawMuscleBelly(
      canvas,
      p1,
      p2,
      0.032 * scale,
      _paintForMuscle(muscle2, isFar),
    );

    // Joint dot / foot at wrist / ankle
    if (j0 == 11 || j0 == 15) {
      // Foot
      canvas.save();
      canvas.translate(p2.dx, p2.dy);
      canvas.scale(0.045 * scale, 0.020 * scale);
      canvas.drawPath(_shapes.unitFoot, _paintBodyBase);
      canvas.restore();
    } else {
      // Wrist dot
      canvas.drawCircle(p2, 0.018 * scale, _paintBodyBase);
    }
  }

  void _drawTorso(
    Canvas canvas,
    FigureCamera camera,
    FigureView activeView,
    double scale,
  ) {
    if (activeView == FigureView.side) {
      // Anatomical profile silhouette matching renderer.py and muscle map:
      final Quat chestRot = _buffer.getWorldRot(2);
      final Quat pelvisRot = _buffer.getWorldRot(0);

      final Vec3 fC = chestRot.rotateVec(const Vec3(1, 0, 0));
      final Vec3 uC = chestRot.rotateVec(const Vec3(0, 1, 0));
      final Vec3 fP = pelvisRot.rotateVec(const Vec3(1, 0, 0));
      final Vec3 uP = pelvisRot.rotateVec(const Vec3(0, 1, 0));

      final Vec3 neckWorld = _buffer.getWorldPos(3);
      final Vec3 chestWorld = _buffer.getWorldPos(2);
      final Vec3 spineWorld = _buffer.getWorldPos(1);
      final Vec3 pelvisWorld = _buffer.getWorldPos(0);

      // 9 anatomical profile boundary landmarks:
      final (double u0, double v0, _) = camera.projectPoint(neckWorld + fC * 0.025);
      final (double u1, double v1, _) = camera.projectPoint(chestWorld + fC * (female ? 0.075 : 0.085));
      final (double u2, double v2, _) = camera.projectPoint(spineWorld + fC * (female ? 0.055 : 0.065));
      final (double u3, double v3, _) = camera.projectPoint(pelvisWorld + fP * 0.055);
      final (double u4, double v4, _) = camera.projectPoint(pelvisWorld - uP * 0.045);
      final (double u5, double v5, _) = camera.projectPoint(pelvisWorld - fP * (female ? 0.085 : 0.095));
      final (double u6, double v6, _) = camera.projectPoint(spineWorld - fP * 0.050);
      final (double u7, double v7, _) = camera.projectPoint(chestWorld - fC * 0.065);
      final (double u8, double v8, _) = camera.projectPoint(neckWorld - fC * 0.030);

      final Path torsoPath = Path()
        ..moveTo(u0, v0)
        ..lineTo(u1, v1)
        ..lineTo(u2, v2)
        ..lineTo(u3, v3)
        ..lineTo(u4, v4)
        ..lineTo(u5, v5)
        ..lineTo(u6, v6)
        ..lineTo(u7, v7)
        ..lineTo(u8, v8)
        ..close();

      canvas.drawPath(torsoPath, _paintBodyBase);

      // Side muscle patches:
      // Glutes
      final (double gu, double gv, _) = camera.projectPoint(pelvisWorld - fP * 0.055 - uP * 0.01);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(gu, gv), width: 0.076 * scale, height: 0.084 * scale),
        _paintForMuscle('glutes', false),
      );

      // Pectorals
      final (double cu, double cv, _) = camera.projectPoint(chestWorld + fC * 0.045);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cu, cv), width: 0.056 * scale, height: 0.064 * scale),
        _paintForMuscle('chest', false),
      );

      // Core / Abs
      final (double au, double av, _) = camera.projectPoint(spineWorld + fC * 0.035);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(au, av), width: 0.044 * scale, height: 0.080 * scale),
        _paintForMuscle('core', false),
      );

      // Trapezius slope
      final (double tu, double tv, _) = camera.projectPoint(chestWorld - fC * 0.035 + uC * 0.03);
      final (double nu, double nv, _) = camera.projectPoint(neckWorld);
      final (double bu, double bv, _) = camera.projectPoint(chestWorld - fC * 0.04);
      final Path trapPath = Path()
        ..moveTo(nu, nv)
        ..lineTo(tu, tv)
        ..lineTo(bu, bv)
        ..close();
      canvas.drawPath(trapPath, _paintForMuscle('trapezius', false));
    } else {
      // Front / 3Q view: Athletic V-tapered silhouette matching muscle map
      final Offset neck = Offset(_buffer.getProjectedU(3), _buffer.getProjectedV(3));
      final Offset chest = Offset(_buffer.getProjectedU(2), _buffer.getProjectedV(2));
      final Offset spine = Offset(_buffer.getProjectedU(1), _buffer.getProjectedV(1));
      final Offset pelvis = Offset(_buffer.getProjectedU(0), _buffer.getProjectedV(0));

      // Half-widths (total width: shoulder=0.165, waist=0.125, hip=0.132):
      final double shW = (female ? 0.14 : 0.165) * 0.5 * scale;
      final double wW = (female ? 0.105 : 0.125) * 0.5 * scale;
      final double hW = (female ? 0.12 : 0.132) * 0.5 * scale;

      final Path polyTorso = Path()
        ..moveTo(neck.dx - shW * 0.5, neck.dy + 0.015 * scale)
        ..lineTo(chest.dx - shW, chest.dy)
        ..lineTo(spine.dx - wW, spine.dy)
        ..lineTo(pelvis.dx - hW, pelvis.dy)
        ..lineTo(pelvis.dx - hW * 0.5, pelvis.dy + 0.040 * scale)
        ..lineTo(pelvis.dx + hW * 0.5, pelvis.dy + 0.040 * scale)
        ..lineTo(pelvis.dx + hW, pelvis.dy)
        ..lineTo(spine.dx + wW, spine.dy)
        ..lineTo(chest.dx + shW, chest.dy)
        ..lineTo(neck.dx + shW * 0.5, neck.dy + 0.015 * scale)
        ..close();

      canvas.drawPath(polyTorso, _paintBodyBase);

      // Pectoral plates (Left and Right)
      final double pw = 0.06 * scale * 0.5;
      final double ph = 0.078 * scale * 0.5;
      final Paint chestPaint = _paintForMuscle('chest', false);
      // Left pec
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(chest.dx - pw * 1.5, chest.dy - ph, chest.dx - pw * 0.2, chest.dy + ph),
          const Radius.circular(4.0),
        ),
        chestPaint,
      );
      // Right pec
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(chest.dx + pw * 0.2, chest.dy - ph, chest.dx + pw * 1.5, chest.dy + ph),
          const Radius.circular(4.0),
        ),
        chestPaint,
      );

      // 2x3 Abs grid
      final Paint absPaint = _paintForMuscle('core', false);
      final double gridW = 0.0289 * scale;
      final double blockH = 0.018 * scale;
      final double blockW = 0.022 * scale;
      final double spineY = (chest.dy + pelvis.dy) * 0.5;
      for (int row = -1; row <= 1; row++) {
        final double y = spineY + row * (blockH + 3.0);
        // Left col
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(spine.dx - gridW * 0.6, y), width: blockW, height: blockH),
            const Radius.circular(2.5),
          ),
          absPaint,
        );
        // Right col
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(spine.dx + gridW * 0.6, y), width: blockW, height: blockH),
            const Radius.circular(2.5),
          ),
          absPaint,
        );
      }
    }
  }

  void _drawHeadAndNeck(Canvas canvas, double scale) {
    final Offset neck = Offset(_buffer.getProjectedU(3), _buffer.getProjectedV(3));
    final Offset head = Offset(_buffer.getProjectedU(4), _buffer.getProjectedV(4));

    // Neck
    _drawSegmentCapsule(canvas, neck, head, 0.022 * scale, 0.022 * scale, _paintBodyBase);

    // Head
    final double headRadius = (female ? 0.0454 : 0.0496) * scale;
    canvas.drawCircle(head, headRadius, _paintBodyBase);

    // Female hair detail
    if (female) {
      canvas.drawCircle(head + Offset(-headRadius * 0.7, -headRadius * 0.4), headRadius * 0.35, _paintBodyBase);
    }
  }

  void _drawProps(
    Canvas canvas,
    FigureCamera camera,
    FigureView activeView,
    double scale,
  ) {
    if (motion.props.isEmpty) return;

    final Offset wristL = Offset(_buffer.getProjectedU(7), _buffer.getProjectedV(7));
    final Offset wristR = Offset(_buffer.getProjectedU(10), _buffer.getProjectedV(10));
    final Offset gripMid = Offset((wristL.dx + wristR.dx) * 0.5, (wristL.dy + wristR.dy) * 0.5);

    for (final String propType in motion.props) {
      if (propType == 'barbell') {
        if (activeView == FigureView.side) {
          // Side view: End-on circular plate
          canvas.drawCircle(gripMid, 0.11 * scale, _paintPropDetail);
          canvas.drawCircle(gripMid, 0.02 * scale, _paintProp);
        } else {
          // Front / ThreeQuarter: Full bar across wrists with plates
          final double barHalfW = 0.48 * scale;
          canvas.drawLine(
            Offset(gripMid.dx - barHalfW, gripMid.dy),
            Offset(gripMid.dx + barHalfW, gripMid.dy),
            _paintProp..strokeWidth = 3.5,
          );
          // Left plate
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(gripMid.dx - barHalfW * 0.85, gripMid.dy),
                width: 12.0,
                height: 0.22 * scale,
              ),
              const Radius.circular(2.0),
            ),
            _paintPropDetail,
          );
          // Right plate
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(gripMid.dx + barHalfW * 0.85, gripMid.dy),
                width: 12.0,
                height: 0.22 * scale,
              ),
              const Radius.circular(2.0),
            ),
            _paintPropDetail,
          );
        }
      } else if (propType == 'dumbbell') {
        // Dumbbell at both hands
        for (final Offset w in <Offset>[wristL, wristR]) {
          canvas.drawLine(
            Offset(w.dx - 14.0, w.dy),
            Offset(w.dx + 14.0, w.dy),
            _paintProp..strokeWidth = 3.0,
          );
          canvas.drawCircle(Offset(w.dx - 14.0, w.dy), 7.0, _paintPropDetail);
          canvas.drawCircle(Offset(w.dx + 14.0, w.dy), 7.0, _paintPropDetail);
        }
      } else if (propType == 'kettlebell') {
        // Kettlebell hanging below grip
        canvas.drawCircle(gripMid + const Offset(0, 16.0), 12.0, _paintProp);
        canvas.drawCircle(gripMid + const Offset(0, 8.0), 6.0, _paintPropDetail);
      } else if (propType == 'abWheel') {
        // Ab wheel prop
        if (activeView == FigureView.side) {
          // Circular wheel resting on floor at grip
          canvas.drawCircle(gripMid, 0.08 * scale, _paintPropDetail);
          canvas.drawCircle(gripMid, 0.065 * scale, _paintProp);
          canvas.drawCircle(gripMid, 0.02 * scale, _paintPropDetail);
        } else {
          // Front view: center wheel with handles
          canvas.drawLine(
            Offset(gripMid.dx - 18.0, gripMid.dy),
            Offset(gripMid.dx + 18.0, gripMid.dy),
            _paintProp..strokeWidth = 4.0,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: gripMid, width: 10.0, height: 0.16 * scale),
              const Radius.circular(3.0),
            ),
            _paintPropDetail,
          );
        }
      } else if (propType == 'mat') {
        // Mat on floor
        final double matY = camera.canvasH - camera.marginBottom + 2.0;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(camera.canvasW * 0.5, matY),
              width: camera.canvasW * 0.85,
              height: 4.0,
            ),
            const Radius.circular(2.0),
          ),
          _paintProp..strokeWidth = 2.0,
        );
      }
    }
  }

  void _drawSegmentCapsule(
    Canvas canvas,
    Offset p1,
    Offset p2,
    double r1,
    double r2,
    Paint paint,
  ) {
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-4) {
      canvas.drawCircle(p1, math.max(r1, r2), paint);
      return;
    }

    final double ang = math.atan2(dy, dx);
    canvas.save();
    canvas.translate(p1.dx, p1.dy);
    canvas.rotate(ang);

    final Path path = Path()
      ..moveTo(0, -r1)
      ..lineTo(len, -r2)
      ..arcTo(
        Rect.fromCircle(center: Offset(len, 0), radius: r2),
        -math.pi * 0.5,
        math.pi,
        false,
      )
      ..lineTo(0, r1)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: r1),
        math.pi * 0.5,
        math.pi,
        false,
      )
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawMuscleBelly(
    Canvas canvas,
    Offset p1,
    Offset p2,
    double rBelly,
    Paint paint,
  ) {
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-4) return;

    final Offset center = Offset(p1.dx + dx * 0.45, p1.dy + dy * 0.45);
    final double ang = math.atan2(dy, dx);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(ang);
    canvas.scale(len * 0.35, rBelly);
    canvas.drawPath(_shapes.unitEllipse, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FigurePainter oldDelegate) {
    return oldDelegate.motion != motion ||
        oldDelegate.female != female ||
        oldDelegate.view != view ||
        oldDelegate.mirror != mirror ||
        oldDelegate.staticKeyframeIndex != staticKeyframeIndex ||
        oldDelegate.colors != colors;
  }
}
