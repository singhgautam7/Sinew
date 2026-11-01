import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../engines/plates/plates.dart';
import '../../models/enums.dart';
import '../../models/plate_inventory.dart';
import '../../theme/app_theme.dart';
import '../../units/units.dart';
import '../sinew_chips.dart';
import '_painters/plate_bar_painter.dart';
import '_painters/plate_stack_painter.dart';

/// What the loader draws.
enum PlateLoaderKind { barbell, dumbbell, stack }

/// The plates on a barbell or a dumbbell handle, or the pin on a machine
/// stack, for one target weight.
///
/// Give it the engine's [PlateResult] for [targetKg] and the [Bar] used; it
/// draws what the engine says (the closer neighbour when the target is not
/// reachable) and tells the user so. Everything is metric; [unit] only
/// changes the numbers in the caption and the screen-reader label.
///
/// When the plates change it follows `PlateEngine.transition`: plates that
/// stay never move, leaving plates slide out outermost first, new ones slide
/// in inside to out, 45ms apart, with a selection click each. Under reduced
/// motion the new load simply appears.
class PlateLoader extends StatefulWidget {
  /// A barbell, or a dumbbell when [bar] `isDumbbell`.
  const PlateLoader({
    super.key,
    required PlateResult this.result,
    required this.targetKg,
    required Bar this.bar,
    this.unit = WeightUnit.kg,
    this.showCaption = true,
    this.onPickNearest,
    this.haptics = true,
  }) : stepKg = null,
       stackCount = PlateSpec.stackDefaultCount;

  /// A machine weight stack with the pin at [targetKg] (snapped to [stepKg]).
  const PlateLoader.stack({
    super.key,
    required this.targetKg,
    required double this.stepKg,
    this.stackCount = PlateSpec.stackDefaultCount,
    this.unit = WeightUnit.kg,
    this.showCaption = true,
    this.onPickNearest,
    this.haptics = true,
  }) : result = null,
       bar = null;

  final PlateResult? result;
  final Bar? bar;
  final double targetKg;

  /// Machine stack only: the weight of one plate in kg, and how many there
  /// are.
  final double? stepKg;
  final int stackCount;
  final WeightUnit unit;

  /// The line under the art ("Bar 20 kg, 40 kg per side: 25 + 15").
  final bool showCaption;

  /// Tapping a "nearest" chip hands back its weight in kg. Null leaves the
  /// chips as plain labels.
  final ValueChanged<double>? onPickNearest;
  final bool haptics;

  PlateLoaderKind get kind => stepKg != null
      ? PlateLoaderKind.stack
      : (bar!.isDumbbell ? PlateLoaderKind.dumbbell : PlateLoaderKind.barbell);

  @override
  State<PlateLoader> createState() => _PlateLoaderState();
}

class _Hint {
  const _Hint(this.kg, this.down);

  final double kg;
  final bool down;
}

class _Info {
  const _Info({
    required this.line,
    required this.semantics,
    this.note,
    this.hints = const <_Hint>[],
  });

  final String line;
  final String? note;
  final String semantics;
  final List<_Hint> hints;
}

class _PlateLoaderState extends State<PlateLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  /// The plates now on one side, in kg, inside to out.
  List<double> _shown = const <double>[];

  /// The load before the running transition.
  List<double> _before = const <double>[];
  PlateTransition? _tr;
  double _k = 1;
  int _totalMs = 0;
  int _fired = 0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this)
      ..addListener(_tick)
      ..addStatusListener((AnimationStatus s) {
        if (s == AnimationStatus.completed) {
          setState(() {
            _tr = null;
            _before = _shown;
          });
        }
      });
    _shown = _platesOf(widget);
    _before = _shown;
    _k = _squeezeFor(_shown, _shown);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  List<double> _platesOf(PlateLoader w) =>
      w.kind == PlateLoaderKind.stack ? const <double>[] : w.result!.perSide;

  List<int> _sizes(List<double> kg) => <int>[
    for (final double p in kg) _sizeOf(p),
  ];

  int _sizeOf(double kg) {
    if (widget.unit == WeightUnit.lb) {
      final double lb = Units.fromKg(kg, WeightUnit.lb);
      for (final MapEntry<double, double> e in SinewAccents.plateLb.entries) {
        if ((e.key - lb).abs() < PlateSpec.lbMatchTolerance) {
          return plateSizeIndex(e.value);
        }
      }
    }
    return plateSizeIndex(kg);
  }

  PlateBarKind get _barKind => widget.kind == PlateLoaderKind.dumbbell
      ? PlateBarKind.dumbbell
      : PlateBarKind.barbell;

  double _squeezeFor(List<double> a, List<double> b) {
    final PlateGeometry g = PlateGeometry(_barKind);
    return g.squeeze(math.max(g.span(_sizes(a)), g.span(_sizes(b))));
  }

  static bool _same(List<double> a, List<double> b) {
    return a.length == b.length &&
        PlateEngine.transition(a, b).kept.length == a.length;
  }

  @override
  void didUpdateWidget(PlateLoader old) {
    super.didUpdateWidget(old);
    if (widget.kind == PlateLoaderKind.stack) {
      final int a = _stackSel(old);
      final int b = _stackSel(widget);
      if (a != b && widget.haptics && !Motion.reduced(context)) {
        HapticFeedback.selectionClick();
      }
      return;
    }
    final List<double> next = _platesOf(widget);
    if (_same(_shown, next) && old.kind == widget.kind) return;
    final List<double> prev = _shown;
    _shown = next;
    final bool snap =
        old.kind != widget.kind ||
        old.kind == PlateLoaderKind.stack ||
        Motion.reduced(context);
    if (snap) {
      _c.stop();
      _tr = null;
      _before = next;
      _k = _squeezeFor(next, next);
      return;
    }
    final PlateTransition tr = PlateEngine.transition(prev, next);
    _tr = tr;
    _before = prev;
    _k = _squeezeFor(prev, next);
    _fired = 0;
    final int stagger = SinewMotion.plateStagger.inMilliseconds;
    final int enter = tr.entering.isEmpty
        ? 0
        : (tr.entering.length - 1) * stagger +
              SinewMotion.plateEnter.inMilliseconds;
    final int exit = tr.exiting.isEmpty
        ? 0
        : (tr.exiting.length - 1) * stagger +
              SinewMotion.plateExit.inMilliseconds;
    _totalMs = math.max(enter, exit);
    if (_totalMs == 0) {
      _tr = null;
      return;
    }
    _c.duration = Duration(milliseconds: _totalMs);
    _c.forward(from: 0);
  }

  void _tick() {
    final PlateTransition? tr = _tr;
    if (tr == null || !widget.haptics) return;
    final double ms = _c.value * _totalMs;
    while (_fired < tr.entering.length &&
        ms >= _fired * SinewMotion.plateStagger.inMilliseconds) {
      HapticFeedback.selectionClick();
      _fired++;
    }
  }

  PlateMotion _motion() {
    final PlateTransition? tr = _tr;
    if (tr == null) return PlateMotion.settled(_sizes(_shown));
    return PlateMotion(
      to: _sizes(_shown),
      kept: tr.kept.length,
      exiting: _sizes(tr.exiting),
      from: _sizes(_before),
      progressMs: _c.value * _totalMs,
    );
  }

  // ── text ────────────────────────────────────────────────────────────────

  String _fmt(double kg) =>
      Units.trim(Units.fromKg(kg, widget.unit), maxDecimals: 2);

  String get _label => Units.weightLabel(widget.unit);

  String get _unitWord => widget.unit == WeightUnit.kg ? 'kilograms' : 'pounds';

  String _w(double kg) => '${_fmt(kg)} $_label';

  int _stackSel(PlateLoader w) {
    final double step = w.stepKg!;
    return (w.targetKg / step).round().clamp(1, w.stackCount);
  }

  _Info _info() {
    if (widget.kind == PlateLoaderKind.stack) return _stackInfo();
    final PlateResult r = widget.result!;
    final Bar bar = widget.bar!;
    final bool db = bar.isDumbbell;
    final String what = db ? 'Handle' : 'Bar';
    final List<double> side = r.perSide;
    final double sideSum = side.fold(0, (double a, double b) => a + b);
    final String plates = side.map(_fmt).join(' + ');
    final String line = side.isEmpty
        ? (db
              ? 'Handle only · ${_w(bar.weightKg)}'
              : 'Empty bar · ${_w(bar.weightKg)}')
        : '$what ${_w(bar.weightKg)} · ${_w(sideSum)} per side: $plates';
    final String shown = side.isEmpty
        ? '${_fmt(r.achievedKg)} $_unitWord: ${db ? 'handle only' : 'empty bar'}'
        : '${_fmt(r.achievedKg)} $_unitWord: ${side.map(_fmt).join(', ')} per side';
    if (r.exact) return _Info(line: line, semantics: shown);

    final PlateLoad? below = r.nearestBelow;
    final PlateLoad? above = r.nearestAbove;
    final String target = _w(widget.targetKg);
    if (widget.targetKg < bar.weightKg && below == null) {
      return _Info(
        line: line,
        note: 'Lighter than the ${_w(bar.weightKg)} ${db ? 'handle' : 'bar'}',
        semantics:
            '${_fmt(widget.targetKg)} $_unitWord is lighter than the '
            '${db ? 'handle' : 'bar'}. $shown',
        hints: <_Hint>[if (above != null) _Hint(above.totalKg, false)],
      );
    }
    if (above == null) {
      return _Info(
        line: line,
        note: 'More than your plates can load. Max ${_w(r.achievedKg)}',
        semantics:
            '${_fmt(widget.targetKg)} $_unitWord is more than your plates '
            'can load. $shown',
        hints: <_Hint>[if (below != null) _Hint(below.totalKg, true)],
      );
    }
    return _Info(
      line: line,
      note:
          "$target isn't possible with your plates. Nearest: "
          '${_w(r.achievedKg)}',
      semantics:
          '${_fmt(widget.targetKg)} $_unitWord is not possible with your '
          'plates. Showing $shown',
      hints: <_Hint>[
        if (below != null) _Hint(below.totalKg, true),
        _Hint(above.totalKg, false),
      ],
    );
  }

  _Info _stackInfo() {
    final double step = widget.stepKg!;
    final int n = widget.stackCount;
    final int sel = _stackSel(widget);
    final StackSnap snap = PlateEngine.snapToStack(widget.targetKg, step);
    final String line = 'Pin at ${_w(sel * step)} · plate $sel of $n';
    final String spoken =
        'Pin at ${_fmt(sel * step)} $_unitWord, plate $sel of $n';
    if (snap.exact && widget.targetKg <= n * step) {
      return _Info(line: line, semantics: spoken);
    }
    if (widget.targetKg > n * step) {
      return _Info(
        line: line,
        note: 'More than the stack. Max ${_w(n * step)}',
        semantics: 'More than the stack. $spoken',
        hints: <_Hint>[_Hint(n * step, true)],
      );
    }
    return _Info(
      line: line,
      note: "${_w(widget.targetKg)} isn't a stack step",
      semantics:
          "${_fmt(widget.targetKg)} $_unitWord isn't a stack step. $spoken",
      hints: <_Hint>[
        if (snap.nearestBelow != null) _Hint(snap.nearestBelow!, true),
        if (snap.nearestAbove != null && snap.nearestAbove! <= n * step)
          _Hint(snap.nearestAbove!, false),
      ],
    );
  }

  // ── build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final _Info info = _info();
    final ColorScheme cs = context.cs;
    final SinewAccents acc = context.accents;
    final TextStyle caption = context.text.bodyMedium!.copyWith(
      fontSize: PlateSpec.captionFont,
      height: PlateSpec.captionLine / PlateSpec.captionFont,
      color: cs.onSurfaceVariant,
    );

    final Widget art = widget.kind == PlateLoaderKind.stack
        ? _stackArt(context, acc, cs)
        : _barArt(acc);

    final Widget text = AnimatedSwitcher(
      duration: Motion.of(context, Motion.fast),
      child: Column(
        key: ValueKey<String>('${info.line}|${info.note}'),
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(info.line, textAlign: TextAlign.center, style: caption),
          if (info.note != null)
            Padding(
              padding: const EdgeInsets.only(top: Space.xxs),
              child: Text(
                info.note!,
                textAlign: TextAlign.center,
                style: caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          container: true,
          image: true,
          label: info.semantics,
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                art,
                if (widget.showCaption) ...<Widget>[
                  const SizedBox(height: PlateSpec.captionGap),
                  text,
                ],
              ],
            ),
          ),
        ),
        if (info.hints.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: <Widget>[
                for (final _Hint h in info.hints)
                  SinewChip(
                    label: _w(h.kg),
                    icon: h.down
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    onTap: widget.onPickNearest == null
                        ? null
                        : () => widget.onPickNearest!(h.kg),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _barArt(SinewAccents acc) {
    final PlateGeometry g = PlateGeometry(_barKind);
    final List<PlateColor> colors = <PlateColor>[
      for (final double s in PlateSpec.sizes) acc.plates[s]!,
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: g.width),
      child: AspectRatio(
        aspectRatio: g.width / g.height,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: PlateBarPainter(
              kind: _barKind,
              motion: _motion,
              squeezeK: _k,
              plateColors: colors,
              bar: acc.bar,
              collar: acc.barCollar,
              repaint: _c,
            ),
          ),
        ),
      ),
    );
  }

  Widget _stackArt(BuildContext context, SinewAccents acc, ColorScheme cs) {
    final int n = widget.stackCount;
    final int sel = _stackSel(widget);
    final double step = widget.stepKg!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: PlateSpec.stackWidth),
      child: AspectRatio(
        aspectRatio: PlateSpec.stackWidth / plateStackHeight(n),
        child: RepaintBoundary(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: sel.toDouble()),
            duration: Motion.of(context, SinewMotion.plateEnter),
            curve: Motion.curveOf(context, Motion.spring),
            builder: (BuildContext context, double pin, Widget? _) =>
                CustomPaint(
                  painter: PlateStackPainter(
                    count: n,
                    selected: sel,
                    pin: pin,
                    stepLabel: (int i) => _fmt(i * step),
                    lit: cs.primary,
                    base: acc.muscleBody,
                    rod: acc.barCollar,
                    pinColor: cs.onSurface,
                    labelStyle: context.text.labelSmall!.copyWith(
                      fontSize: PlateSpec.stackLabelFont,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
