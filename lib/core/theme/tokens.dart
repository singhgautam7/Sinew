import 'package:flutter/material.dart';

/// Design tokens: spacing, radii, icon sizes, motion and elevation.
///
/// PLACEHOLDER VALUES (Phase 1). They mirror Mull's scale so the scaffold
/// looks like the family; Phase 3 replaces every value with the one in
/// `specs/design/<folder>/HANDOFF.md`. Nothing in a feature names a raw size,
/// radius or duration: it comes from here. A magic number in a widget is a bug.

/// 4 · 8 · 12 · 16 · 24 · 32, plus the screen-level values.
abstract final class Space {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Screen margin.
  static const double screen = 20;

  /// Gap between rows in a list.
  static const double row = 10;

  /// Gap between sections on a screen.
  static const double section = 28;

  /// Bottom padding on every scrollable so content clears the floating nav.
  static const double bottomSafe = 108;
}

abstract final class Radii {
  static const double chip = 8;
  static const double thumb = 14;
  static const double card = 20;
  static const double sheet = 28;
  static const double full = 999;

  static const BorderRadius chipR = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius thumbR = BorderRadius.all(Radius.circular(thumb));
  static const BorderRadius cardR = BorderRadius.all(Radius.circular(card));
  static const BorderRadius sheetR = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static const BorderRadius fullR = BorderRadius.all(Radius.circular(full));
}

/// One rounded outline set, 24dp, 48dp tap target.
abstract final class IconSpec {
  static const double size = 24;
  static const double small = 18;
  static const double large = 32;
  static const double stroke = 1.75;

  /// Minimum touch target everywhere (accessibility rule).
  static const double tapTarget = 48;
}

/// Stroke widths for hairlines, rings and outlines.
abstract final class Strokes {
  static const double hairline = 1;
  static const double focus = 2;
  static const double ring = 6;
}

/// Spring for anything the finger caused, decelerate for anything the system
/// caused (Mull's rule). Honour reduced motion through [Motion.of] and
/// [Motion.curveOf].
abstract final class Motion {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration navIndicator = Duration(milliseconds: 220);
  static const Duration containerTransform = Duration(milliseconds: 240);
  static const Duration sheet = Duration(milliseconds: 260);
  static const Duration navHide = Duration(milliseconds: 160);
  static const Duration snackEnter = Duration(milliseconds: 180);
  static const Duration snackExit = Duration(milliseconds: 140);

  /// Anything the finger caused.
  static const Curve spring = Curves.easeOutBack;

  /// Anything the system caused.
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve standard = Curves.easeInOut;

  /// Under OS reduced motion: transforms become cross-fades, springs go linear.
  static const Duration reducedFade = Duration(milliseconds: 90);

  static bool reduced(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    return mq.disableAnimations || mq.accessibleNavigation;
  }

  /// Duration to actually use, honouring reduced motion.
  static Duration of(BuildContext context, Duration full) =>
      reduced(context) ? reducedFade : full;

  static Curve curveOf(BuildContext context, Curve full) =>
      reduced(context) ? Curves.linear : full;
}

/// Depth lives in 1px outlines; a shadow exists on exactly one object, the
/// nav pill (Mull's rule).
abstract final class Elevations {
  static const double navPill = 6;
  static const double navPillBlur = 18;
}

/// Opacity steps used for states and disabled content.
abstract final class Opacities {
  static const double disabled = 0.38;
  static const double muted = 0.6;
  static const double pressed = 0.12;
  static const double scrim = 0.32;
}
