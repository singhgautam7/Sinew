import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/enums.dart';
import '../../models/training.dart';
import '../../theme/app_theme.dart';
import '../../units/units.dart';
import 'timer_ring.dart' show ClockText;

/// One set in a workout, in the shape its [TrackingType] needs.
///
/// Values arrive metric (kg, metres, seconds) and are shown and typed in
/// [weightUnit] and [distanceUnit]; what [onChanged] returns is metric again.
///
/// Three looks, as in the Train frames:
/// - open: the inputs, with last session's numbers as grey hints, and an
///   outlined check (tapping it with empty inputs accepts the hints as they
///   are);
/// - done: tonal fill, one summary line, a filled check, and a PR pill when
///   the set is a personal record. Tapping the row opens it again;
/// - planned (`planned: true`): a quiet summary for a set that comes later.
///
/// [SetRow.compact] is the read-only line for history and session detail.
class SetRow extends StatefulWidget {
  const SetRow({
    super.key,
    required this.entry,
    required this.trackingType,
    required ValueChanged<SetEntry> this.onChanged,
    required ValueChanged<bool> this.onComplete,
    this.onLongPress,
    this.onTap,
    this.previous,
    this.number,
    this.weightUnit = WeightUnit.kg,
    this.distanceUnit = DistanceUnit.km,
    this.focused = false,
    this.planned = false,
    this.paceLabel,
    this.haptics = true,
  }) : compact = false;

  /// The read-only line: number, summary, PR pill.
  const SetRow.compact({
    super.key,
    required this.entry,
    required this.trackingType,
    this.number,
    this.weightUnit = WeightUnit.kg,
    this.distanceUnit = DistanceUnit.km,
    this.onTap,
    this.onLongPress,
  }) : compact = true,
       onChanged = null,
       onComplete = null,
       previous = null,
       focused = false,
       planned = false,
       paceLabel = null,
       haptics = false;

  final SetEntry entry;
  final TrackingType trackingType;

  /// Called with every edit, already converted to metric.
  final ValueChanged<SetEntry>? onChanged;

  /// Called with the new state when the check is tapped. When a set is
  /// completed with empty inputs, [onChanged] fires first with the hints
  /// filled in.
  final ValueChanged<bool>? onComplete;
  final VoidCallback? onLongPress;

  /// Tap on a done or planned row. A done row without it reopens itself
  /// through `onComplete(false)`.
  final VoidCallback? onTap;

  /// The same set last session; its values show as hints.
  final SetEntry? previous;

  /// What to show in the badge; defaults to `entry.position + 1`.
  final int? number;
  final WeightUnit weightUnit;
  final DistanceUnit distanceUnit;

  /// The set being worked on: a 2dp primary outline.
  final bool focused;

  /// A set still to come: summary only, 56dp.
  final bool planned;

  /// Distance + time rows: a pace read-out from the records engine
  /// ("5:32 /km"), shown as a third cell. Widgets never work it out.
  final String? paceLabel;
  final bool haptics;
  final bool compact;

  /// "82.5 kg × 8", "15 reps", "5 km · 27:40": what a set amounts to.
  static String summary(
    SetEntry e,
    TrackingType type, {
    WeightUnit weightUnit = WeightUnit.kg,
    DistanceUnit distanceUnit = DistanceUnit.km,
  }) {
    String clock(int? s) => s == null ? '-' : ClockText.format(s);
    switch (type) {
      case TrackingType.weightReps:
        final String? w = e.weightKg == null
            ? null
            : Units.formatWeight(e.weightKg!, weightUnit, maxDecimals: 2);
        if (w != null && e.reps != null) return '$w × ${e.reps}';
        if (w != null) return w;
        if (e.reps != null) return '${e.reps} reps';
        return '-';
      case TrackingType.reps:
      case TrackingType.unknown:
        return e.reps == null ? '-' : '${e.reps} reps';
      case TrackingType.time:
        return clock(e.durationSec);
      case TrackingType.distanceTime:
        final String d = e.distanceM == null
            ? '-'
            : Units.formatDistance(e.distanceM!, distanceUnit);
        return '$d · ${clock(e.durationSec)}';
      case TrackingType.rounds:
        final String r = e.rounds == null ? '-' : '${e.rounds} rounds';
        return e.durationSec == null ? r : '$r · ${clock(e.durationSec)}';
      case TrackingType.hold:
        return e.holdSec == null ? '-' : '${clock(e.holdSec)} hold';
      case TrackingType.flow:
        final String r = e.rounds == null ? '-' : '${e.rounds} rounds';
        return e.durationSec == null ? r : '$r · ${clock(e.durationSec)}';
    }
  }

  @override
  State<SetRow> createState() => _SetRowState();
}

enum _Kind { decimal, integer, clock }

/// One input of a row: how to read it from a [SetEntry], write it back, and
/// show and parse it in the user's units.
class _Field {
  const _Field({
    required this.id,
    required this.unit,
    required this.name,
    required this.kind,
    required this.get,
    required this.set,
    required this.format,
    required this.parse,
  });

  final String id;

  /// Under the value ("kg", "reps", "per round").
  final String unit;

  /// For a screen reader ("Weight in kilograms").
  final String name;
  final _Kind kind;
  final double? Function(SetEntry) get;
  final SetEntry Function(SetEntry, double?) set;
  final String Function(double) format;
  final double? Function(String) parse;

  String text(SetEntry e) {
    final double? v = get(e);
    return v == null ? '' : format(v);
  }
}

List<_Field> _fieldsFor(TrackingType type, WeightUnit wu, DistanceUnit du) {
  final _Field weight = _Field(
    id: 'weight',
    unit: Units.weightLabel(wu),
    name: wu == WeightUnit.kg ? 'Weight in kilograms' : 'Weight in pounds',
    kind: _Kind.decimal,
    get: (SetEntry e) => e.weightKg,
    set: (SetEntry e, double? v) => e.copyWith(weightKg: v),
    format: (double kg) => Units.trim(Units.fromKg(kg, wu)),
    parse: (String t) {
      final double? v = double.tryParse(t.replaceAll(',', '.'));
      return v == null ? null : Units.toKg(v, wu);
    },
  );
  final _Field reps = _Field(
    id: 'reps',
    unit: 'reps',
    name: 'Reps',
    kind: _Kind.integer,
    get: (SetEntry e) => e.reps?.toDouble(),
    set: (SetEntry e, double? v) => e.copyWith(reps: v?.round()),
    format: (double v) => v.round().toString(),
    parse: (String t) => int.tryParse(t)?.toDouble(),
  );
  _Field clock(
    String id,
    String unit,
    String name,
    double? Function(SetEntry) get,
    SetEntry Function(SetEntry, double?) set,
  ) => _Field(
    id: id,
    unit: unit,
    name: name,
    kind: _Kind.clock,
    get: get,
    set: set,
    format: (double v) => ClockText.format(v.round()),
    parse: (String t) => ClockText.parse(t)?.toDouble(),
  );
  final _Field duration = clock(
    'duration',
    'time',
    'Duration, minutes and seconds',
    (SetEntry e) => e.durationSec?.toDouble(),
    (SetEntry e, double? v) => e.copyWith(durationSec: v?.round()),
  );
  final _Field rounds = _Field(
    id: 'rounds',
    unit: 'rounds',
    name: 'Rounds',
    kind: _Kind.integer,
    get: (SetEntry e) => e.rounds?.toDouble(),
    set: (SetEntry e, double? v) => e.copyWith(rounds: v?.round()),
    format: (double v) => v.round().toString(),
    parse: (String t) => int.tryParse(t)?.toDouble(),
  );
  switch (type) {
    case TrackingType.weightReps:
      return <_Field>[weight, reps];
    case TrackingType.reps:
    case TrackingType.unknown:
      return <_Field>[reps];
    case TrackingType.time:
      return <_Field>[duration];
    case TrackingType.distanceTime:
      return <_Field>[
        _Field(
          id: 'distance',
          unit: Units.distanceLabel(du),
          name: du == DistanceUnit.km
              ? 'Distance in kilometres'
              : 'Distance in miles',
          kind: _Kind.decimal,
          get: (SetEntry e) => e.distanceM,
          set: (SetEntry e, double? v) => e.copyWith(distanceM: v),
          format: (double m) => Units.trim(Units.fromMetres(m, du)),
          parse: (String t) {
            final double? v = double.tryParse(t.replaceAll(',', '.'));
            return v == null ? null : Units.toMetres(v, du);
          },
        ),
        duration,
      ];
    case TrackingType.rounds:
      return <_Field>[
        rounds,
        clock(
          'duration',
          'per round',
          'Length of each round, minutes and seconds',
          (SetEntry e) => e.durationSec?.toDouble(),
          (SetEntry e, double? v) => e.copyWith(durationSec: v?.round()),
        ),
      ];
    case TrackingType.hold:
      return <_Field>[
        clock(
          'hold',
          'hold',
          'Hold time, minutes and seconds',
          (SetEntry e) => e.holdSec?.toDouble(),
          (SetEntry e, double? v) => e.copyWith(holdSec: v?.round()),
        ),
      ];
    case TrackingType.flow:
      return <_Field>[rounds, duration];
  }
}

class _SetRowState extends State<SetRow> with TickerProviderStateMixin {
  late final AnimationController _check;
  late final AnimationController _pulse;

  static final TweenSequence<double> _checkScale = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0,
          end: SetRowSpec.checkOvershoot,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: SetRowSpec.checkGrowShare,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: SetRowSpec.checkOvershoot,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1 - SetRowSpec.checkGrowShare,
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _check = AnimationController(
      vsync: this,
      duration: SinewMotion.setComplete,
      value: widget.entry.completed ? 1 : 0,
    );
    _pulse = AnimationController(vsync: this, duration: SinewMotion.prFlash);
  }

  @override
  void dispose() {
    _check.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SetRow old) {
    super.didUpdateWidget(old);
    final bool nowDone = widget.entry.completed;
    final bool reduced = Motion.reduced(context);
    if (nowDone && !old.entry.completed) {
      if (reduced) {
        _check.value = 1;
      } else {
        _check.forward(from: 0);
      }
    } else if (!nowDone && old.entry.completed) {
      _check.value = 0;
    }
    final bool newPr =
        nowDone &&
        widget.entry.isPR &&
        (!old.entry.completed || !old.entry.isPR);
    if (newPr && !reduced) _pulse.forward(from: 0);
  }

  TrackingType get _type => widget.trackingType == TrackingType.unknown
      ? TrackingType.reps
      : widget.trackingType;

  int get _number => widget.number ?? widget.entry.position + 1;

  String get _summary => SetRow.summary(
    widget.entry,
    _type,
    weightUnit: widget.weightUnit,
    distanceUnit: widget.distanceUnit,
  );

  /// The badge text: the set number, or a letter for a typed set.
  String get _badge {
    final SetEntry e = widget.entry;
    if (e.isWarmup) return 'W';
    return switch (e.type) {
      SetType.normal => '$_number',
      SetType.drop => 'D',
      SetType.failure => 'F',
      SetType.amrap => 'A',
    };
  }

  bool get _typed =>
      widget.entry.isWarmup || widget.entry.type != SetType.normal;

  String get _typeName {
    final SetEntry e = widget.entry;
    if (e.isWarmup) return 'warm-up';
    return switch (e.type) {
      SetType.normal => 'working set',
      SetType.drop => 'drop set',
      SetType.failure => 'set to failure',
      SetType.amrap => 'AMRAP set',
    };
  }

  String get _rowLabel =>
      'Set $_number, $_typeName'
      '${widget.entry.completed ? ', completed' : ''}';

  SetEntry _prefilled() {
    final SetEntry? prev = widget.previous;
    SetEntry e = widget.entry;
    if (prev == null) return e;
    for (final _Field f in _fieldsFor(
      _type,
      widget.weightUnit,
      widget.distanceUnit,
    )) {
      if (f.get(e) == null && f.get(prev) != null) e = f.set(e, f.get(prev));
    }
    return e;
  }

  void _toggle() {
    final bool done = widget.entry.completed;
    if (!done) {
      if (widget.haptics) HapticFeedback.lightImpact();
      final SetEntry filled = _prefilled();
      if (filled != widget.entry) widget.onChanged?.call(filled);
      widget.onComplete?.call(true);
    } else {
      widget.onComplete?.call(false);
    }
  }

  void _edit(_Field f, String text) {
    final double? v = text.trim().isEmpty ? null : f.parse(text.trim());
    if (text.trim().isNotEmpty && v == null) return;
    widget.onChanged?.call(f.set(widget.entry, v));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) return _compact(context);
    final ColorScheme cs = context.cs;
    final bool done = widget.entry.completed;
    final bool planned = widget.planned && !done;

    final Color fill = done
        ? cs.secondaryContainer
        : (planned ? Colors.transparent : cs.surfaceContainer);
    final Color border = done
        ? Colors.transparent
        : (widget.focused ? cs.primary : cs.outlineVariant);
    final double borderWidth = widget.focused && !done
        ? SetRowSpec.focusBorder
        : Strokes.hairline;

    final Widget content = done
        ? _doneContent(context)
        : (planned ? _plannedContent(context) : _openContent(context));

    final Widget row = AnimatedContainer(
      duration: Motion.of(context, Motion.fast),
      constraints: BoxConstraints(
        minHeight: planned ? SetRowSpec.plannedHeight : SetRowSpec.minHeight,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: Radii.largeR,
        border: Border.all(color: border, width: borderWidth),
      ),
      child: ClipRRect(
        borderRadius: Radii.largeR,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (BuildContext context, Widget? _) => ColoredBox(
                    color: cs.primaryContainer.withValues(
                      alpha: math.sin(math.pi * _pulse.value),
                    ),
                  ),
                ),
              ),
            ),
            content,
          ],
        ),
      ),
    );

    final bool tappable = done || planned;
    return Semantics(
      container: true,
      explicitChildNodes: !tappable,
      label: tappable ? '$_rowLabel, $_summary' : _rowLabel,
      onTap: tappable
          ? (widget.onTap ??
                (done ? () => widget.onComplete?.call(false) : null))
          : null,
      onLongPress: widget.onLongPress,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: widget.onLongPress,
        onTap: tappable
            ? (widget.onTap ??
                  (done ? () => widget.onComplete?.call(false) : null))
            : null,
        child: tappable ? ExcludeSemantics(child: row) : row,
      ),
    );
  }

  // ── looks ───────────────────────────────────────────────────────────────

  Widget _badgeBox(BuildContext context, {required bool plain}) {
    final ColorScheme cs = context.cs;
    final Color bg = plain
        ? Colors.transparent
        : (_typed ? cs.tertiaryContainer : cs.surfaceContainerHigh);
    final Color fg = plain
        ? (_typed ? cs.tertiary : cs.onSurfaceVariant)
        : (_typed ? cs.onTertiaryContainer : cs.onSurface);
    return Container(
      width: SetRowSpec.badge,
      height: SetRowSpec.badge,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: Radii.chipR),
      child: Text(
        _badge,
        maxLines: 1,
        style: context.text.labelLarge!.copyWith(color: fg),
      ),
    );
  }

  EdgeInsets get _pad => const EdgeInsets.fromLTRB(
    SetRowSpec.rowPadLeft,
    SetRowSpec.rowPadV,
    SetRowSpec.rowPadRight,
    SetRowSpec.rowPadV,
  );

  Widget _openContent(BuildContext context) {
    final List<_Field> fields = _fieldsFor(
      _type,
      widget.weightUnit,
      widget.distanceUnit,
    );
    final SetEntry? prev = widget.previous;
    return Padding(
      padding: _pad,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ExcludeSemantics(child: _badgeBox(context, plain: false)),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Row(
              children: <Widget>[
                for (int i = 0; i < fields.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: Space.xs + Space.xxs),
                  Expanded(
                    child: _SetField(
                      key: ValueKey<String>(fields[i].id),
                      text: fields[i].text(widget.entry),
                      hint: prev == null || fields[i].get(prev) == null
                          ? null
                          : fields[i].format(fields[i].get(prev)!),
                      unit: fields[i].unit,
                      name: fields[i].name,
                      kind: fields[i].kind,
                      onChanged: (String t) => _edit(fields[i], t),
                    ),
                  ),
                ],
                if (widget.paceLabel != null &&
                    _type == TrackingType.distanceTime) ...<Widget>[
                  const SizedBox(width: Space.xs + Space.xxs),
                  Expanded(child: _ReadOnlyCell(text: widget.paceLabel!)),
                ],
              ],
            ),
          ),
          const SizedBox(width: Space.sm),
          _checkButton(context),
        ],
      ),
    );
  }

  Widget _doneContent(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Padding(
      padding: _pad,
      child: Row(
        children: <Widget>[
          _badgeBox(context, plain: true),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Text(
              _summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleLarge!.copyWith(
                fontSize: SetRowSpec.summaryFont,
                color: cs.onSecondaryContainer,
              ),
            ),
          ),
          if (widget.entry.isPR) ...<Widget>[
            const _PrPill(),
            const SizedBox(width: Space.sm),
          ],
          _checkButton(context),
        ],
      ),
    );
  }

  Widget _plannedContent(BuildContext context) {
    return Padding(
      padding: _pad,
      child: Row(
        children: <Widget>[
          _badgeBox(context, plain: true),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Text(
              _summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyLarge!.copyWith(
                fontSize: SetRowSpec.plannedFont,
                color: context.cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkButton(BuildContext context) {
    final ColorScheme cs = context.cs;
    final bool done = widget.entry.completed;
    return Semantics(
      button: true,
      checked: done,
      label: done ? 'Set $_number completed' : 'Mark set $_number complete',
      excludeSemantics: true,
      onTap: _toggle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: SizedBox(
          width: SetRowSpec.check,
          height: SetRowSpec.check,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: SetRowSpec.check,
                height: SetRowSpec.check,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.focused ? cs.primary : cs.outline,
                    width: SetRowSpec.checkBorder,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: SetRowSpec.checkGlyph,
                  color: widget.focused ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
              AnimatedBuilder(
                animation: _check,
                builder: (BuildContext context, Widget? child) {
                  final double s = _checkScale.evaluate(_check);
                  if (!done || s <= 0) return const SizedBox.shrink();
                  return Transform.scale(scale: s, child: child);
                },
                child: Container(
                  width: SetRowSpec.check,
                  height: SetRowSpec.check,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: SetRowSpec.checkGlyph,
                    color: cs.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compact(BuildContext context) {
    final ColorScheme cs = context.cs;
    final bool done = widget.entry.completed;
    return Semantics(
      container: true,
      label:
          '$_rowLabel, $_summary${widget.entry.isPR ? ', personal record' : ''}',
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: SetRowSpec.compactHeight,
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: SetRowSpec.badge,
                  child: Text(
                    _badge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: context.text.labelLarge!.copyWith(
                      color: _typed ? cs.tertiary : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    _summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyLarge!.copyWith(
                      color: done ? cs.onSurface : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (widget.entry.isPR) ...<Widget>[
                  const SizedBox(width: Space.sm),
                  const _PrPill(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "PR": primary fill, onPrimary text, 12/700.
class _PrPill extends StatelessWidget {
  const _PrPill();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Semantics(
      label: 'Personal record',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SetRowSpec.prPadH,
          vertical: SetRowSpec.prPadV,
        ),
        decoration: BoxDecoration(color: cs.primary, borderRadius: Radii.fullR),
        child: Text(
          'PR',
          maxLines: 1,
          style: context.text.labelMedium!.copyWith(
            color: cs.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// A 48dp-minimum input cell: the value on top, its unit (and last time's
/// number) underneath. Typing commits on every keystroke.
class _SetField extends StatefulWidget {
  const _SetField({
    super.key,
    required this.text,
    required this.hint,
    required this.unit,
    required this.name,
    required this.kind,
    required this.onChanged,
  });

  final String text;
  final String? hint;
  final String unit;
  final String name;
  final _Kind kind;
  final ValueChanged<String> onChanged;

  @override
  State<_SetField> createState() => _SetFieldState();
}

class _SetFieldState extends State<_SetField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(_SetField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && _controller.text != widget.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_focus.hasFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    } else if (_controller.text != widget.text) {
      _controller.text = widget.text;
    }
  }

  TextInputType get _keyboard => switch (widget.kind) {
    _Kind.decimal => const TextInputType.numberWithOptions(decimal: true),
    _Kind.integer => TextInputType.number,
    _Kind.clock => TextInputType.datetime,
  };

  RegExp get _allowed => switch (widget.kind) {
    _Kind.decimal => RegExp(r'[0-9.,]'),
    _Kind.integer => RegExp(r'[0-9]'),
    _Kind.clock => RegExp(r'[0-9:]'),
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextStyle value = context.text.titleMedium!.copyWith(
      fontSize: SetRowSpec.valueFont,
      height: SetRowSpec.valueLine / SetRowSpec.valueFont,
      color: cs.onSurface,
    );
    final String label = widget.hint == null
        ? widget.unit
        : '${widget.unit} · last ${widget.hint}';
    final Color fieldBg = cs.brightness == Brightness.light
        ? cs.surfaceContainerLowest
        : cs.surfaceContainerHigh;
    return Semantics(
      container: true,
      label: widget.name,
      hint: widget.hint == null ? null : 'Last time ${widget.hint}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: SetRowSpec.fieldMinHeight),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _focus.requestFocus,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: Radii.mediumR,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SetRowSpec.fieldPadH,
                vertical: Space.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    focusNode: _focus,
                    keyboardType: _keyboard,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(_allowed),
                    ],
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    style: value,
                    cursorColor: cs.primary,
                    onChanged: widget.onChanged,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: widget.hint ?? '',
                      hintStyle: value.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A read-only cell beside the inputs (pace).
class _ReadOnlyCell extends StatelessWidget {
  const _ReadOnlyCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: SetRowSpec.fieldMinHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SetRowSpec.fieldPadH),
        child: Center(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelMedium!.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
