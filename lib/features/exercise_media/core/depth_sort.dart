// PURE DART: No Flutter imports. Depth sorting for the painter's algorithm.

enum DrawableType {
  shadow,
  ground,
  bench,
  torsoBase,
  chestPatch,
  absPatch,
  obliquesPatch,
  trapsPatch,
  latsPatch,
  glutesPatch,
  deltoidPatch,
  bicepsPatch,
  tricepsPatch,
  forearmsPatch,
  quadsPatch,
  hamstringsPatch,
  calvesPatch,
  segmentCapsule,
  jointDot,
  head,
  neck,
  foot,
  prop,
}

class DrawableItem implements Comparable<DrawableItem> {
  const DrawableItem({
    required this.type,
    required this.depth,
    this.jointIndex = -1,
    this.tag = '',
    this.isFarLimb = false,
  });

  final DrawableType type;
  final double depth;
  final int jointIndex;
  final String tag;
  final bool isFarLimb;

  @override
  int compareTo(DrawableItem other) => depth.compareTo(other.depth);
}
