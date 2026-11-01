import 'package:flutter/material.dart';

/// Design tokens: spacing, radii, icon sizes, motion and elevation.
///
/// Values are Kuber's (`KuberSpace`, `KuberShape`, `KuberMotion`) with the
/// Sinew additions from the design handoff at the bottom. Nothing in a feature
/// or a widget names a raw size, radius or duration: it comes from here. A
/// magic number in a widget is a bug.

/// 4 · 8 · 12 · 16 · 24 · 32 · 48, plus the layout metrics defined once.
abstract final class Space {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal edge of every screen.
  static const double screen = 20;

  /// Gap between rows in a list.
  static const double row = 10;

  /// Gap between sections on a screen.
  static const double section = 28;

  /// Section header to its content.
  static const double sectionHeaderGap = 8;

  /// Between stacked cards and tiles.
  static const double cardGap = 12;
  static const double cardPadding = 16;

  /// The one hero card per screen.
  static const double cardPaddingHero = 20;

  /// Minimum list row heights: title only, with a subtitle, with a body line.
  static const double listItem1 = 56;
  static const double listItem2 = 72;
  static const double listItem3 = 88;
  static const double listRowPadH = 16;
  static const double listRowPadV = 8;

  /// Bottom padding on every scrollable so content clears the floating nav
  /// (56 pill + 22 offset + 32 scrim, rounded to the handoff's 108).
  static const double bottomSafe = 108;
}

/// The shape scale. Rounded, never squircle.
abstract final class Radii {
  static const double extraSmall = 4;

  /// Chips, tooltips, heatmap cells, inline badges.
  static const double chip = 8;

  /// Category tiles, menu rows, inner tiles in cards.
  static const double medium = 12;

  /// List thumbnails (the exercise row, 48dp, radius 14 in the handoff).
  static const double thumb = 14;

  /// Text fields, snackbar, nested containers.
  static const double large = 16;

  /// Cards, grouped lists, menus.
  static const double card = 20;

  /// Sheets (top), dialogs.
  static const double sheet = 28;

  /// Buttons, icon buttons, nav pill, FAB, segmented, progress, badges.
  static const double full = 999;

  static const BorderRadius extraSmallR = BorderRadius.all(
    Radius.circular(extraSmall),
  );
  static const BorderRadius chipR = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius mediumR = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius thumbR = BorderRadius.all(Radius.circular(thumb));
  static const BorderRadius largeR = BorderRadius.all(Radius.circular(large));
  static const BorderRadius cardR = BorderRadius.all(Radius.circular(card));
  static const BorderRadius dialogR = BorderRadius.all(Radius.circular(sheet));
  static const BorderRadius sheetR = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static const BorderRadius fullR = BorderRadius.all(Radius.circular(full));
}

/// One rounded outline set, 24dp, 48dp tap target.
abstract final class IconSpec {
  static const double size = 24;
  static const double tiny = 16;
  static const double small = 18;
  static const double large = 32;

  /// The glyph inside buttons, menu rows and tiles.
  static const double glyph = 20;
  static const double stroke = 1.75;

  /// Minimum touch target everywhere (accessibility rule).
  static const double tapTarget = 48;
}

/// Stroke widths for hairlines, rings and outlines.
abstract final class Strokes {
  static const double hairline = 1;
  static const double focus = 2;
  static const double ring = 6;
  static const double spinnerSmall = 2;
  static const double spinnerMedium = 2.5;
  static const double spinnerLarge = 3;
}

/// Spring for anything the finger caused, decelerate for anything the system
/// caused. Honour reduced motion through [Motion.of] and [Motion.curveOf].
abstract final class Motion {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration navIndicator = Duration(milliseconds: 220);
  static const Duration containerTransform = Duration(milliseconds: 240);
  static const Duration sheet = Duration(milliseconds: 260);
  static const Duration navHide = Duration(milliseconds: 160);
  static const Duration snackEnter = Duration(milliseconds: 220);
  static const Duration snackExit = Duration(milliseconds: 140);
  static const Duration snackLife = Duration(seconds: 7);
  static const Duration fabSlide = Duration(milliseconds: 220);
  static const Duration fabFade = Duration(milliseconds: 180);
  static const Duration segment = Duration(milliseconds: 200);
  static const Duration headerSwap = Duration(milliseconds: 200);
  static const Duration skeletonPulse = Duration(milliseconds: 1200);

  /// A loader stays invisible this long so a fast load never flashes one.
  static const Duration loadDelay = Duration(milliseconds: 250);

  /// Anything the finger caused.
  static const Curve spring = Curves.easeOutBack;

  /// Anything the system caused.
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
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
/// nav pill. Kuber's pill casts none, and so does Sinew's: the border is
/// enough. The values stay for the one place a shadow is ever allowed.
abstract final class Elevations {
  static const double none = 0;
  static const double navPill = 6;
  static const double navPillBlur = 18;
}

/// Opacity steps used for states and disabled content.
abstract final class Opacities {
  static const double disabled = 0.38;
  static const double disabledFill = 0.12;
  static const double muted = 0.6;
  static const double pressed = 0.12;
  static const double scrim = 0.32;
  static const double handle = 0.4;
  static const double selection = 0.3;
  static const double track = 0.16;
  static const double skeletonLow = 0.55;
  static const double scrimFade = 0.92;
}

/// Component metrics: the numbers behind the shared widgets, named once.
abstract final class Sizes {
  // Nav pill (Kuber's exact geometry: 56 tall, padding 8, 40 items, 2 gap).
  static const double navPillHeight = 56;
  static const double navItem = 40;
  static const double navItemGap = 2;
  static const double navPadding = 8;

  /// Border of the pill, both sides.
  static const double hairlineBorders = 2;

  /// Vertical inset that leaves the 48dp hit row inside the 56 pill: the pill
  /// height minus its border minus the hit row, halved.
  static const double navPillInsetV = 3;
  static const double navLabelPadLeft = 11;
  static const double navLabelPadRight = 14;
  static const double navLabelGap = 8;
  static const double navBottomMin = 22;
  static const double navScrim = 32;
  static const double navHideTravel = 72;

  /// Above this text height a selected tab drops its label.
  static const double navLabelMaxText = 20;
  static const double glyphSlot = 24;
  static const double glyphWidth = 20;
  static const double glyphHeight = 16;

  // Buttons.
  static const double buttonLarge = 56;
  static const double buttonSmall = 40;
  static const double buttonPadLarge = 24;
  static const double buttonPadSmall = 16;
  static const double buttonMinWidth = 64;
  static const double buttonWideThreshold = 120;
  static const double dashLength = 4;
  static const double dashGap = 3;

  // Icon buttons.
  static const double iconButton = 40;
  static const double badge = 16;
  static const double badgeInset = 6;

  // Header (app bar).
  static const double headerTop = 14;
  static const double headerRow = 48;
  static const double headerSubtitle = 12;
  static const double headerGap = 6;
  static const double headerSubtitleLift = 4;

  // Sheets and menus.
  static const double handleWidth = 32;
  static const double handleHeight = 4;
  static const double handleBand = 24;
  static const double menuMinWidth = 200;
  static const double menuMaxWidth = 320;
  static const double menuDivider = 17;
  static const double menuHeader = 32;
  static const double menuSubtitleRow = 60;
  static const double infoGlyph = 18;

  // Chips and segmented controls.
  static const double chip = 32;
  static const double segmented = 40;
  static const double segmentedMinWidth = 48;
  static const int segmentedNoCheckFrom = 4;
  static const double chipMenuMinWidth = 184;

  // Empty state, loader, snackbar.
  static const double emptyIcon = 72;
  static const double emptyGlyph = 32;
  static const double loaderSpinner = 32;
  static const double snackMinHeight = 56;
  static const double snackTimer = 4;
  static const double snackSwipeDistance = 80;
  static const double snackSwipeVelocity = 600;
  static const double snackEnterTravel = 80;
  static const double snackDragFade = 200;

  // Extended FAB.
  static const double fab = 56;
  static const double fabPadLeft = 16;
  static const double fabPadRight = 20;
  static const double fabGap = 8;

  /// Gap between the nav pill and an extended FAB above it.
  static const double fabNavGap = 22;

  // Tiles.
  static const double tile = 40;
  static const double dragDistance = 2;

  // Text field.
  static const double fieldPadV = 16;
  static const double fieldBorder = 2;

  // Settings and list rows.
  static const double leadingTile = 40;
  static const double pickerRowLeading = 40;
  static const double switchRowInset = 12;

  // Colour and icon picker.
  static const double swatch = 44;
  static const double swatchGap = 12;
  static const double pickerTile = 48;
  static const double pickerIcon = 28;
}

/// Sinew additions to the space scale (handoff: gloveTarget 64, timerControl
/// 96, setRowHeight 64).
abstract final class SinewSpace {
  /// Active workout and timer secondary controls.
  static const double gloveTarget = 64;

  /// Primary pause / play.
  static const double timerControl = 96;
  static const double setRowHeight = 64;
}

/// Sinew additions to the shape scale.
abstract final class SinewShape {
  /// The pause control: squircle-ish, morphs to a full circle when paused.
  static const double timerPrimary = 32;
}

/// Sinew motion moments (handoff, Motion table).
abstract final class SinewMotion {
  static const Duration plateEnter = Duration(milliseconds: 420);
  static const Duration plateStagger = Duration(milliseconds: 45);
  static const Duration plateExit = Duration(milliseconds: 220);

  /// Spring behind the plate slide, mass 1, stiffness 380, damping 22.
  static const SpringDescription plateSpring = SpringDescription(
    mass: 1,
    stiffness: 380,
    damping: 22,
  );
  static const Duration setComplete = Duration(milliseconds: 260);
  static const Duration prFlash = Duration(milliseconds: 600);
  static const Duration silhouetteMorph = Duration(milliseconds: 480);
  static const Duration phaseSweep = Duration(milliseconds: 360);
}
