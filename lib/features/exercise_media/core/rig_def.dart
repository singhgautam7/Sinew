// PURE DART: No Flutter imports. Rig constants and skeletal hierarchy.
//
// Matches rig.json and Drillis & Contini (1966) proportions for H = 1.0.

import 'math3d.dart';

enum JointIndex {
  pelvis,
  spineLower,
  chest,
  neck,
  head,
  shoulderL,
  elbowL,
  wristL,
  shoulderR,
  elbowR,
  wristR,
  hipL,
  kneeL,
  ankleL,
  toeL,
  hipR,
  kneeR,
  ankleR,
  toeR;

  static const int count = 19;
}

abstract final class RigDef {
  static const List<String> jointNames = <String>[
    'pelvis',
    'spineLower',
    'chest',
    'neck',
    'head',
    'shoulderL',
    'elbowL',
    'wristL',
    'shoulderR',
    'elbowR',
    'wristR',
    'hipL',
    'kneeL',
    'ankleL',
    'toeL',
    'hipR',
    'kneeR',
    'ankleR',
    'toeR',
  ];

  static final Map<String, int> jointNameToIndex = <String, int>{
    for (int i = 0; i < jointNames.length; i++) jointNames[i]: i,
  };

  /// Parent index for each joint. Pelvis has no parent (-1).
  static const List<int> parentIndices = <int>[
    -1, // pelvis
    0, // spineLower -> pelvis
    1, // chest -> spineLower
    2, // neck -> chest
    3, // head -> neck
    2, // shoulderL -> chest
    5, // elbowL -> shoulderL
    6, // wristL -> elbowL
    2, // shoulderR -> chest
    8, // elbowR -> shoulderR
    9, // wristR -> elbowR
    0, // hipL -> pelvis
    11, // kneeL -> hipL
    12, // ankleL -> kneeL
    13, // toeL -> ankleL
    0, // hipR -> pelvis
    15, // kneeR -> hipR
    16, // ankleR -> kneeR
    17, // toeR -> ankleR
  ];

  /// Rest offset relative to parent in neutral standing pose (H = 1.0).
  static const List<Vec3> restOffsets = <Vec3>[
    Vec3(0.0, 0.540, 0.0), // pelvis (root)
    Vec3(0.0, 0.090, 0.0), // spineLower
    Vec3(0.0, 0.130, 0.0), // chest
    Vec3(0.0, 0.100, 0.0), // neck
    Vec3(0.0, 0.080, 0.0), // head
    Vec3(0.0, 0.030, 0.170), // shoulderL
    Vec3(0.0, -0.175, 0.0), // elbowL
    Vec3(0.0, -0.145, 0.0), // wristL
    Vec3(0.0, 0.030, -0.170), // shoulderR
    Vec3(0.0, -0.175, 0.0), // elbowR
    Vec3(0.0, -0.145, 0.0), // wristR
    Vec3(0.0, -0.035, 0.095), // hipL
    Vec3(0.0, -0.245, 0.0), // kneeL
    Vec3(0.0, -0.215, 0.0), // ankleL
    Vec3(0.120, -0.023, 0.0), // toeL
    Vec3(0.0, -0.035, -0.095), // hipR
    Vec3(0.0, -0.245, 0.0), // kneeR
    Vec3(0.0, -0.215, 0.0), // ankleR
    Vec3(0.120, -0.023, 0.0), // toeR
  ];

  /// Neutral radii for joints/capsules.
  static const List<double> jointRadii = <double>[
    0.048, // pelvis
    0.046, // spineLower
    0.050, // chest
    0.026, // neck
    0.060, // head
    0.028, // shoulderL
    0.024, // elbowL
    0.020, // wristL
    0.028, // shoulderR
    0.024, // elbowR
    0.020, // wristR
    0.036, // hipL
    0.032, // kneeL
    0.026, // ankleL
    0.022, // toeL
    0.036, // hipR
    0.032, // kneeR
    0.026, // ankleR
    0.022, // toeR
  ];
}
