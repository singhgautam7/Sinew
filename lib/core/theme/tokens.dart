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

  /// Extra height a one-line bodyMedium subtitle adds to the header (20 for
  /// the line, less the 4 the bottom padding shrinks by).
  static const double headerSubtitle = 16;
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

// ──────────────────────────────────────────────────────────────────────────
// Sinew components: plate loader, set rows, timer controls and ring, numeric
// stepper. Append-only; every number below comes from the design source
// (`sinew-art.js`, Components, Train and Timer frames).
// ──────────────────────────────────────────────────────────────────────────

/// Plate loader geometry, in the design's own coordinate space (the art is
/// drawn at these sizes and scaled to the available width, like an SVG
/// viewBox).
abstract final class PlateSpec {
  static const double barbellWidth = 340;
  static const double barbellHeight = 120;
  static const double dumbbellWidth = 260;
  static const double dumbbellHeight = 96;
  static const double stackWidth = 200;

  /// Half the length of the bare bar between the sleeves.
  static const double barbellCollar = 64;
  static const double dumbbellCollar = 30;

  /// Distance from the collar to the first plate.
  static const double barbellFirstGap = 3;
  static const double dumbbellFirstGap = 1;

  /// Gap between neighbouring plates.
  static const double plateGap = 2;

  /// Space kept free at the end of the sleeve.
  static const double roomMargin = 14;
  static const double plateStroke = 1.5;
  static const double plateRadius = 3;

  /// How far a plate slides when it enters or leaves.
  static const double slideTravel = 46;

  // Barbell.
  static const double shaftHalfHeight = 3.5;
  static const double sleeveHalfHeight = 6;
  static const double sleeveInset = 8;
  static const double stopHalfHeight = 13;
  static const double stopWidth = 8;
  static const double stopOutset = 6;
  static const double stopInset = 2;
  static const double stopRadius = 3;

  // Dumbbell.
  static const double handleHalfHeight = 5;
  static const double gripHalfHeight = 4;
  static const double gripLength = 34;

  /// Plate sizes in kg, heaviest first, with the face height and thickness
  /// each is drawn at on a barbell.
  static const List<double> sizes = <double>[25, 20, 15, 10, 5, 2.5, 1.25];
  static const List<double> barbellHeights = <double>[
    96,
    96,
    96,
    96,
    62,
    48,
    40,
  ];
  static const List<double> barbellThickness = <double>[15, 13, 11, 9, 8, 7, 6];

  /// Dumbbell plates exist for 5, 2.5 and 1.25 kg only (index 4 to 6).
  static const List<double> dumbbellHeights = <double>[78, 62, 52];
  static const List<double> dumbbellThickness = <double>[12, 9, 7];
  static const int dumbbellFirstIndex = 4;

  /// Two plate sizes closer than this many kilograms are the same size.
  static const double lbMatchTolerance = 0.05;

  // Machine stack.
  static const int stackDefaultCount = 16;
  static const double stackPlateHeight = 9;
  static const double stackPitch = 11;
  static const double stackTop = 10;
  static const double stackBottom = 10;
  static const double stackRodHalf = 3;
  static const double stackPlateHalf = 46;
  static const double stackPlateRadius = 2.5;
  static const int stackLabelEvery = 4;
  static const double stackLabelOffset = 56;
  static const double stackLabelFont = 10;
  static const double pinLength = 30;
  static const double pinHeight = 4;
  static const double pinStart = 64;
  static const double pinKnobOffset = 66;
  static const double pinKnobRadius = 6;

  /// Gap between the art and its caption.
  static const double captionGap = 6;
  static const double captionFont = 13;
  static const double captionLine = 18;
}

/// Set row metrics (Components and Train frames).
abstract final class SetRowSpec {
  static const double minHeight = SinewSpace.setRowHeight;
  static const double plannedHeight = 56;
  static const double compactHeight = 40;
  static const double badge = 32;
  static const double check = 52;
  static const double checkBorder = 2;
  static const double checkGlyph = 28;
  static const double fieldMinHeight = 48;
  static const double fieldPadH = 10;
  static const double rowPadLeft = 8;
  static const double rowPadRight = 6;
  static const double rowPadV = 6;
  static const double focusBorder = 2;
  static const double valueFont = 18;
  static const double valueLine = 22;
  static const double summaryFont = 20;
  static const double plannedFont = 16;
  static const double prPadH = 10;
  static const double prPadV = 4;

  /// The check disc grows to this on completion, then settles to 1.
  static const double checkOvershoot = 1.18;

  /// Share of the 260ms check animation spent growing to the overshoot.
  static const double checkGrowShare = 0.6;
}

/// Timer controls, ring and phase field metrics (Timer frames).
abstract final class TimerSpec {
  static const double ringSize = 340;
  static const double ringStroke = 14;

  /// The numeral fits this share of the ring's width (112 of 150 in the
  /// design at full size).
  static const double numeralWidthFactor = 0.62;
  static const double trackOpacity = 0.15;
  static const double secondaryFillOpacity = 0.12;
  static const double pausedOpacity = 0.7;
  static const double nextFillOpacity = 0.08;
  static const double barFutureOpacity = 0.2;

  static const double primaryIcon = 48;
  static const double secondaryIcon = 28;
  static const double addFont = 18;
  static const double labelFont = 12;
  static const double labelGap = 6;

  /// Halo around the lock while locked, and the arc drawn while holding.
  static const double lockHalo = 6;
  static const double lockHaloOpacity = 0.2;
  static const double lockHoldStroke = 4;
  static const Duration holdToUnlock = Duration(seconds: 1);
  static const double controlsGap = 12;

  static const double phaseWordSize = 40;
  static const double phaseWordTracking = 3;
  static const double nextFont = 18;
  static const double nextPadH = 18;
  static const double nextPadV = 10;
  static const double topBarPadV = 8;
  static const double topBarPadH = 20;
  static const double controlsBottom = 44;
  static const double statusPill = 32;

  // Warning (boxing): inset border, pill and round bars.
  static const double warningBorder = 10;
  static const double warningPill = 44;
  static const double barWidth = 36;
  static const double barHeight = 10;
  static const double barGap = 6;

  // AMRAP counter.
  static const double amrapRadius = 40;
  static const double amrapFont = 150;
  static const double amrapTracking = -4;
  static const double amrapMinHeight = 200;

  // Finished.
  static const double finishedDisc = 72;
  static const double finishedGlyph = 40;
}

/// Numeric stepper metrics.
abstract final class StepperSpec {
  static const double button = IconSpec.tapTarget;
  static const double buttonGlove = SinewSpace.gloveTarget;
  static const double glyph = 24;
  static const double glyphGlove = 28;
  static const double valueMinWidth = 64;
  static const double valueMinWidthGlove = 96;

  /// Repeat while a button is held: the first interval, the faster one after
  /// [accelerateAfter] repeats.
  static const Duration repeatSlow = Duration(milliseconds: 120);
  static const Duration repeatFast = Duration(milliseconds: 50);
  static const int accelerateAfter = 12;

  /// Decimal places kept when stepping, to avoid 0.1 + 0.2 drift.
  static const int precision = 4;
}

// ═════════════════════════════════════════════════════════════════════════
// Domain widgets (muscle map, silhouette, stat card, chart card, field row,
// exercise tile). Append-only section: lib/core/widgets/domain/.
// ═════════════════════════════════════════════════════════════════════════

/// Muscle map metrics.
abstract final class MapSpec {
  /// Gap between the front and back figure.
  static const double figureGap = 6;

  /// Figure to its "Front" / "Back" caption.
  static const double labelGap = 4;

  /// Share of a routine tint in the pale secondary colour (the rest is the
  /// surface).
  static const double tintSecondaryMix = 0.4;

  /// The cropped map in an exercise tile: the 48dp thumbnail.
  static const double thumb = 48;
}

/// Silhouette metrics. The `view*` and stroke values are in the reference's
/// own 240 x 424 canvas units and scale with the figure, as an SVG would.
abstract final class SilhouetteSpec {
  static const double viewWidth = 240;
  static const double viewHeight = 424;

  /// Figure height inside the canvas, and the gap above it.
  static const double figureHeight = 400;
  static const double topInset = 12;

  static const double strokeMeasured = 2.25;
  static const double strokeEstimated = 1.75;
  static const double strokeCompare = 1.5;

  /// Estimated outline: dashes of 3 with gaps of 5.
  static const double dashOn = 3;
  static const double dashOff = 5;

  /// Comparison outline: dots of 1 with gaps of 4.
  static const double dotOn = 1;
  static const double dotOff = 4;

  /// Highlighted level: a 1.25 dashed line and a dot at its end.
  static const double highlightStroke = 1.25;
  static const double highlightDashOn = 2;
  static const double highlightDashOff = 4;
  static const double highlightInset = 18;
  static const double markerRadius = 4.5;
  static const double markerRadiusSmall = 2.5;
  static const double labelSize = 9;
  static const double labelGap = 4;

  /// Height of the view when its parent gives none.
  static const double defaultHeight = 300;
}

/// Stat card metrics.
abstract final class StatSpec {
  /// Gap between the value and its unit.
  static const double valueGap = 8;

  /// Vertical rhythm inside a card.
  static const double gap = 10;

  /// Lock glyph in a locked card.
  static const double lockGlyph = 20;

  /// The compact card (Today).
  static const double compactMinWidth = 132;
  static const double skeletonValue = 32;
  static const double skeletonLabel = 14;
  static const double skeletonLabelWidth = 0.5;
  static const double skeletonValueWidth = 0.35;
}

/// Chart card metrics.
abstract final class ChartSpec {
  static const double height = 160;
  static const double lineWidth = 2.5;
  static const double secondaryLineWidth = 2;
  static const double dotRadius = 3;
  static const double lastDotRadius = 5;
  static const double dotRing = 2;
  static const double areaTop = 0.18;
  static const double leftReserved = 40;
  static const double bottomReserved = 24;
  static const double referenceDashOn = 5;
  static const double referenceDashOff = 4;
  static const double headerGap = 8;

  /// The y range grows by this share of its span so the line never touches
  /// the edge.
  static const double padRatio = 0.12;

  /// Horizontal gridlines.
  static const int gridLines = 3;

  /// Most x labels shown.
  static const int maxXLabels = 4;
}

/// Measurement field row metrics.
abstract final class FieldSpec {
  static const double inputWidth = 112;
  static const double inputGap = 12;
  static const double dragSlot = 40;
  static const double switchRowMinHeight = 72;
  static const double tagPadH = 6;
  static const double tagPadV = 2;
}

/// Exercise tile metrics (the thumbnail is [MapSpec.thumb] with
/// [Radii.thumb]).
abstract final class ExerciseTileSpec {
  static const double actionSize = 40;
  static const double actionGlyph = 20;
  static const double metaGlyph = 16;
}

// ──────────────────────────────────────────────────────────────────────────
// TRAIN FEATURE (append-only section owned by lib/features/train)
// ──────────────────────────────────────────────────────────────────────────

/// Metrics and defaults for the Train feature.
abstract final class TrainSpec {
  // Routine cards and tiles.
  static const double routineTile = 56;
  static const double routinePlay = 48;
  static const double routinePlayGlyph = 26;
  static const double routineEditorTile = 48;

  /// Rough work time per set, in seconds, for "about N min" estimates.
  static const int estimatedWorkSecPerSet = 40;

  // Defaults.
  static const int defaultRestSec = 90;
  static const int defaultSetCount = 3;
  static const int restStepSec = 10;
  static const int maxSets = 20;
  static const int maxRestSec = 600;

  // Active workout.
  static const double progressSegment = 4;
  static const double plateStageHeight = 150;
  static const double plateStageMachine = 180;
  static const double headerGlyph = 24;
  static const double exerciseBarGap = 6;
  static const double restBarHeight = 64;
  static const double restBarProgress = 4;
  static const double restRing = 280;
  static const double restRingStroke = 12;
  static const double setGap = 8;

  // History.
  static const int historyPage = 40;
  static const double dateBlock = 48;
  static const double dateBlockRadius = 12;

  // Summary.
  static const double summaryBadge = 72;
  static const double summaryBadgeGlyph = 40;
  static const double statTileMinWidth = 140;
  static const double mapPreview = 96;
  static const double mapPreviewHeight = 100;

  // Exercise history.
  static const int recentSessions = 20;
}
