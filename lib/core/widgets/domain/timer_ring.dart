import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../../engines/timer/timer_engine.dart';
import '../../models/enums.dart';
import '../../theme/app_theme.dart';

/// Clock text for timers and timed sets. Pure functions, no state.
abstract final class ClockText {
  /// `0:14`, `1:14`, `1:02:03`. Negative values read as zero.
  static String format(int seconds) {
    final int s = math.max(0, seconds);
    final int h = s ~/ 3600;
    final int m = (s % 3600) ~/ 60;
    final int sec = s % 60;
    final String ss = sec.toString().padLeft(2, '0');
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
    return '$m:$ss';
  }

  /// Reads `45`, `1:30` or `1:02:03` as seconds, or null when it is not one.
  static int? parse(String text) {
    final String t = text.trim();
    if (t.isEmpty) return null;
    final List<String> parts = t.split(':');
    if (parts.length > 3) return null;
    int total = 0;
    for (final String p in parts) {
      final int? n = int.tryParse(p.isEmpty ? '0' : p);
      if (n == null || n < 0) return null;
      total = total * 60 + n;
    }
    return total;
  }

  /// "1 minute 14 seconds" for a screen reader.
  static String spoken(int seconds) {
    final int s = math.max(0, seconds);
    final int h = s ~/ 3600;
    final int m = (s % 3600) ~/ 60;
    final int sec = s % 60;
    final List<String> out = <String>[
      if (h > 0) '$h ${h == 1 ? 'hour' : 'hours'}',
      if (m > 0) '$m ${m == 1 ? 'minute' : 'minutes'}',
      if (sec > 0 || (h == 0 && m == 0))
        '$sec ${sec == 1 ? 'second' : 'seconds'}',
    ];
    return out.join(' ');
  }
}

/// A progress ring: a faint full track and a rounded arc that starts at 12
/// o'clock. [fraction] is how much of the arc is drawn (the time remaining).
///
/// The ring is its own [RepaintBoundary]; [child] (the numeral) sits inside.
class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.fraction,
    required this.ringColor,
    required this.trackColor,
    this.size = TimerSpec.ringSize,
    this.strokeWidth = TimerSpec.ringStroke,
    this.fractionListenable,
    this.child,
  });

  final double fraction;

  /// When set, the arc follows this value instead of [fraction] and only the
  /// arc repaints when it changes (no widget rebuild). The run screen feeds it
  /// at frame rate while the rest of the face rebuilds once a second.
  final ValueListenable<double>? fractionListenable;
  final Color ringColor;
  final Color trackColor;
  final double size;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _RingPainter(
                    fraction: fraction.clamp(0.0, 1.0),
                    listenable: fractionListenable,
                    ring: ringColor,
                    track: trackColor,
                    stroke: strokeWidth,
                  ),
                ),
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.ring,
    required this.track,
    required this.stroke,
    this.listenable,
  }) : super(repaint: listenable);

  final double fraction;
  final ValueListenable<double>? listenable;
  final Color ring;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = (math.min(size.width, size.height) - stroke) / 2;
    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..isAntiAlias = true;
    canvas.drawCircle(c, r, base..color = track);
    final double fraction = listenable?.value.clamp(0.0, 1.0) ?? this.fraction;
    if (fraction <= 0) return;
    final Rect rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      base
        ..color = ring
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.listenable != listenable ||
      old.ring != ring ||
      old.track != track ||
      old.stroke != stroke;
}

/// The accent family a [TimerPhase] is drawn with.
SinewPhase sinewPhaseOf(TimerPhase phase) => switch (phase) {
  TimerPhase.work => SinewPhase.work,
  TimerPhase.rest || TimerPhase.roundRest => SinewPhase.rest,
  TimerPhase.prepare => SinewPhase.warmup,
  TimerPhase.cooldown => SinewPhase.cooldown,
  TimerPhase.open => SinewPhase.work,
};

/// The full-screen timer face for one [TimerSnapshot]: the phase colour fills
/// the screen, a ring counts the step down, the big numeral reads across the
/// room. It never ticks: the parent rebuilds it with each new snapshot.
///
/// When the phase changes the new colour sweeps outward from the middle over
/// 360ms (a 90ms cross-fade under reduced motion). Paused dims the ring and
/// shows a PAUSED pill. With [warningSec] set (boxing) the last seconds of a
/// work step switch to a bordered warning face. A finished run shows a
/// check on the plain surface; put the follow-up buttons in [controls].
class PhaseField extends StatefulWidget {
  const PhaseField({
    super.key,
    required this.snapshot,
    this.title,
    this.trailing,
    this.heading,
    this.label,
    this.nextLabel,
    this.warningSec,
    this.finishedTitle = 'Done. Nice work.',
    this.finishedSubtitle,
    this.controls,
    this.ringFraction,
    this.figure,
  });

  final TimerSnapshot snapshot;

  /// Drives the ring arc at frame rate without rebuilding the face (see
  /// [TimerRing.fractionListenable]). The face itself still follows
  /// [snapshot], which the parent may refresh only once a second.
  final ValueListenable<double>? ringFraction;

  /// Top left, for example "Tabata, legs".
  final String? title;

  /// Top right while running, for example "Set 1 of 2".
  final String? trailing;

  /// The big word above the ring. Defaults to WORK, REST, GET READY or COOL
  /// DOWN from the phase; an open-ended step has none.
  final String? heading;

  /// Under the numeral. Defaults to "Round 3 of 8" when the run has rounds.
  final String? label;

  /// "Next: Rest 0:10", in the chip under the ring.
  final String? nextLabel;

  /// Seconds before the end of a work step that switch to the warning face.
  final int? warningSec;
  final String finishedTitle;
  final String? finishedSubtitle;

  /// Below the face: usually `TimerControls`.
  final Widget? controls;

  /// Optional figure widget (e.g. for yoga flow mode).
  final Widget? figure;

  @override
  State<PhaseField> createState() => _PhaseFieldState();
}

class _PhaseFieldState extends State<PhaseField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep;
  SinewPhase? _phase;
  PhaseColor? _from;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(vsync: this, value: 1);
    _phase = sinewPhaseOf(widget.snapshot.phase);
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  PhaseColor _lerp(PhaseColor a, PhaseColor b, double t) => (
    field: Color.lerp(a.field, b.field, t)!,
    on: Color.lerp(a.on, b.on, t)!,
    ring: Color.lerp(a.ring, b.ring, t)!,
  );

  double get _eased => Curves.easeOutCubic.transform(_sweep.value);

  @override
  void didUpdateWidget(PhaseField old) {
    super.didUpdateWidget(old);
    final SinewPhase next = sinewPhaseOf(widget.snapshot.phase);
    if (next == _phase) return;
    final SinewAccents acc = context.accents;
    final PhaseColor target = acc.phase(_phase!);
    _from = _sweep.value < 1 && _from != null
        ? _lerp(_from!, target, _eased)
        : target;
    _phase = next;
    _sweep.duration = Motion.of(context, SinewMotion.phaseSweep);
    _sweep.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final TimerSnapshot snap = widget.snapshot;
    if (snap.finished) return _finished(context);
    return AnimatedBuilder(
      animation: _sweep,
      builder: (BuildContext context, Widget? _) => _face(context, snap),
    );
  }

  bool _warning(TimerSnapshot snap) {
    final int? w = widget.warningSec;
    final int? left = snap.stepRemainingMs;
    return w != null &&
        left != null &&
        snap.phase == TimerPhase.work &&
        !snap.paused &&
        left > 0 &&
        left <= w * 1000;
  }

  String? _heading(TimerSnapshot snap) {
    if (widget.heading != null) return widget.heading;
    return switch (snap.phase) {
      TimerPhase.work => 'WORK',
      TimerPhase.rest || TimerPhase.roundRest => 'REST',
      TimerPhase.prepare => 'GET READY',
      TimerPhase.cooldown => 'COOL DOWN',
      TimerPhase.open => null,
    };
  }

  int _seconds(TimerSnapshot snap) {
    final int? left = snap.stepRemainingMs;
    return left == null ? snap.stepElapsedMs ~/ 1000 : (left + 999) ~/ 1000;
  }

  Widget _face(BuildContext context, TimerSnapshot snap) {
    final SinewAccents acc = context.accents;
    final SinewPhase phase = _phase!;
    final PhaseColor target = acc.phase(phase);
    final bool sweeping = _from != null && _sweep.value < 1;
    final bool reduced = Motion.reduced(context);
    final double t = reduced ? _sweep.value : _eased;
    final PhaseColor now = sweeping ? _lerp(_from!, target, t) : target;
    final Color warnColor = acc.phase(SinewPhase.warmup).ring;
    final bool warn = _warning(snap);
    final bool paused = snap.paused;

    final String? heading = warn ? null : _heading(snap);
    final String? label =
        widget.label ??
        (snap.roundCount > 1 && snap.round > 0
            ? 'Round ${snap.round} of ${snap.roundCount}'
            : null);
    final String clock = ClockText.format(_seconds(snap));
    final TextTheme tt = context.text;

    final TextStyle numeral = context.timerNumeral.copyWith(color: now.on);
    final Widget numeralBox = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(clock, maxLines: 1, style: numeral),
    );

    Widget centre;
    if (warn) {
      centre = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: TimerSpec.warningPill,
            padding: const EdgeInsets.symmetric(horizontal: Space.lg),
            decoration: BoxDecoration(
              color: warnColor,
              borderRadius: Radii.fullR,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.notifications_active_rounded,
                  size: IconSpec.size,
                  color: acc.phase(SinewPhase.warmup).field,
                ),
                const SizedBox(width: Space.sm),
                Text(
                  '${widget.warningSec} seconds left',
                  style: tt.titleMedium!.copyWith(
                    fontSize: TimerSpec.nextFont,
                    color: acc.phase(SinewPhase.warmup).field,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          SizedBox(width: TimerSpec.ringSize, child: numeralBox),
          if (snap.roundCount > 1) ...<Widget>[
            const SizedBox(height: Space.md),
            _RoundBars(
              count: snap.roundCount,
              current: snap.round - 1,
              done: now.on,
              active: warnColor,
            ),
          ],
        ],
      );
    } else {
      centre = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.figure != null) ...<Widget>[
            widget.figure!,
            const SizedBox(height: Space.xs),
          ],
          if (heading != null)
            Opacity(
              opacity: paused ? TimerSpec.pausedOpacity : 1,
              child: Text(
                heading,
                maxLines: 1,
                style: tt.headlineLarge!.copyWith(
                  fontSize: TimerSpec.phaseWordSize,
                  letterSpacing: TimerSpec.phaseWordTracking,
                  color: now.on,
                ),
              ),
            ),
          const SizedBox(height: Space.sm),
          TimerRing(
            fraction: snap.stepDurationMs == null ? 1 : 1 - snap.stepProgress,
            fractionListenable: snap.stepDurationMs == null
                ? null
                : widget.ringFraction,
            ringColor: paused
                ? now.ring.withValues(alpha: TimerSpec.pausedOpacity)
                : now.ring,
            trackColor: now.on.withValues(alpha: TimerSpec.trackOpacity),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: TimerSpec.ringSize * TimerSpec.numeralWidthFactor,
                  child: numeralBox,
                ),
                if (label != null)
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleLarge!.copyWith(color: now.on),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    if (widget.nextLabel != null) {
      centre = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          centre,
          const SizedBox(height: Space.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TimerSpec.nextPadH,
              vertical: TimerSpec.nextPadV,
            ),
            decoration: BoxDecoration(
              color: now.on.withValues(alpha: TimerSpec.nextFillOpacity),
              borderRadius: Radii.cardR,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ExcludeSemantics(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: IconSpec.size,
                    color: now.on,
                  ),
                ),
                const SizedBox(width: Space.sm),
                Text(
                  widget.nextLabel!,
                  maxLines: 1,
                  style: tt.titleMedium!.copyWith(
                    fontSize: TimerSpec.nextFont,
                    color: now.on,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final String spoken = <String>[
      if (heading != null && _phaseSpoken(snap).isNotEmpty) _phaseSpoken(snap),
      ClockText.spoken(_seconds(snap)),
      ?label,
      if (warn) '${widget.warningSec} seconds left',
      if (paused) 'Paused',
    ].join(', ');

    final Widget topBar = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TimerSpec.topBarPadH,
        vertical: TimerSpec.topBarPadV,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              widget.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleMedium!.copyWith(color: now.on),
            ),
          ),
          if (paused)
            _PausedPill(fill: now.on, on: now.field)
          else if (widget.trailing != null)
            Flexible(
              child: Text(
                widget.trailing!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleMedium!.copyWith(color: now.on),
              ),
            ),
        ],
      ),
    );

    final Widget body = Column(
      children: <Widget>[
        topBar,
        Expanded(
          child: Semantics(
            container: true,
            label: spoken,
            child: ExcludeSemantics(
              child: Center(
                child: FittedBox(fit: BoxFit.scaleDown, child: centre),
              ),
            ),
          ),
        ),
        if (widget.controls != null)
          Padding(
            padding: const EdgeInsets.only(
              left: Space.screen,
              right: Space.screen,
              bottom: TimerSpec.controlsBottom,
            ),
            child: widget.controls,
          ),
      ],
    );

    return RepaintBoundary(
      child: CustomPaint(
        painter: _SweepPainter(
          from: sweeping ? _from!.field : target.field,
          to: now.field,
          progress: sweeping && !reduced ? t : 1,
          blend: sweeping && reduced,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: now.on),
          child: IconTheme.merge(
            data: IconThemeData(color: now.on),
            child: Stack(
              children: <Widget>[
                SafeArea(child: body),
                if (warn)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: warnColor,
                            width: TimerSpec.warningBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _phaseSpoken(TimerSnapshot snap) => switch (snap.phase) {
    TimerPhase.work => 'Work',
    TimerPhase.rest || TimerPhase.roundRest => 'Rest',
    TimerPhase.prepare => 'Get ready',
    TimerPhase.cooldown => 'Cool down',
    TimerPhase.open => '',
  };

  Widget _finished(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return ColoredBox(
      color: cs.surface,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Semantics(
                container: true,
                label: <String>[
                  widget.finishedTitle,
                  ?widget.finishedSubtitle,
                ].join(', '),
                child: ExcludeSemantics(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: TimerSpec.finishedDisc,
                            height: TimerSpec.finishedDisc,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: TimerSpec.finishedGlyph,
                              color: cs.onPrimary,
                            ),
                          ),
                          const SizedBox(height: Space.md),
                          Text(
                            widget.finishedTitle,
                            style: tt.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          if (widget.finishedSubtitle != null)
                            Text(
                              widget.finishedSubtitle!,
                              style: tt.bodyMedium!.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.controls != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  0,
                  Space.screen,
                  Space.xl,
                ),
                child: widget.controls,
              ),
          ],
        ),
      ),
    );
  }
}

class _PausedPill extends StatelessWidget {
  const _PausedPill({required this.fill, required this.on});

  final Color fill;
  final Color on;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: TimerSpec.statusPill,
      padding: const EdgeInsets.symmetric(horizontal: Space.md),
      decoration: BoxDecoration(color: fill, borderRadius: Radii.fullR),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.pause_rounded, size: IconSpec.tiny, color: on),
          const SizedBox(width: Space.xs),
          Text(
            'PAUSED',
            style: context.text.labelLarge!.copyWith(
              color: on,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBars extends StatelessWidget {
  const _RoundBars({
    required this.count,
    required this.current,
    required this.done,
    required this.active,
  });

  final int count;
  final int current;
  final Color done;
  final Color active;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: TimerSpec.barGap,
      runSpacing: TimerSpec.barGap,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          Container(
            width: TimerSpec.barWidth,
            height: TimerSpec.barHeight,
            decoration: BoxDecoration(
              color: i < current
                  ? done
                  : (i == current
                        ? active
                        : done.withValues(alpha: TimerSpec.barFutureOpacity)),
              borderRadius: Radii.fullR,
            ),
          ),
      ],
    );
  }
}

/// Fills with [from], then grows a disc of [to] outward from the middle.
/// With [blend] it cross-fades instead (reduced motion).
class _SweepPainter extends CustomPainter {
  const _SweepPainter({
    required this.from,
    required this.to,
    required this.progress,
    required this.blend,
  });

  final Color from;
  final Color to;
  final double progress;
  final bool blend;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    if (blend) {
      canvas.drawRect(rect, Paint()..color = Color.lerp(from, to, progress)!);
      return;
    }
    if (progress >= 1) {
      canvas.drawRect(rect, Paint()..color = to);
      return;
    }
    canvas.drawRect(rect, Paint()..color = from);
    final Offset c = size.center(Offset.zero);
    final double maxR = math.sqrt(
      size.width * size.width / 4 + size.height * size.height / 4,
    );
    canvas.drawCircle(c, maxR * progress, Paint()..color = to);
  }

  @override
  bool shouldRepaint(_SweepPainter old) =>
      old.from != from ||
      old.to != to ||
      old.progress != progress ||
      old.blend != blend;
}
