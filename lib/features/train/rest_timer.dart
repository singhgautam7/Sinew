import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/timer_preset.dart';
import '../../core/providers.dart';
import '../../core/routing/nav_visibility.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/domain/timer_ring.dart';
import '../../engines/timer/timer_engine.dart';
import '../timer/api/timer_api.dart';
import 'train_format.dart' show formatElapsed;
import 'train_providers.dart';

/// The workout rest timer's state: one [TimerRun] of a single rest step.
///
/// Time always comes from `run.snapshotAt(now)`; a ticker only repaints.
@immutable
class RestState {
  const RestState({required this.run, this.nextLabel, this.nextDetail});

  final TimerRun run;

  /// "Incline dumbbell press · set 3" (what comes next).
  final String? nextLabel;

  /// "24.5 kg × 10".
  final String? nextDetail;

  int get totalSec => ((run.effectiveTotalMs ?? 0) / 1000).round();

  RestState withRun(TimerRun r) =>
      RestState(run: r, nextLabel: nextLabel, nextDetail: nextDetail);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schemaVersion': RestController.schemaVersion,
    'run': run.toJson(),
    'nextLabel': nextLabel,
    'nextDetail': nextDetail,
  };
}

/// Owns the rest timer. Lives above the workout screen so the rest keeps
/// running when the workout is minimised; survives an app kill through
/// `RuntimeStateRepository` (key `train.rest`).
class RestController extends Notifier<RestState?> {
  static const String storageKey = 'train.rest';
  static const int schemaVersion = 1;
  static const TimerCues cues = TimerCues();

  /// Cues strictly before this instant have fired.
  int _firedUntilMs = 0;

  @override
  RestState? build() => null;

  int _now() => ref.read(trainNowMsProvider)();

  /// Starts a rest of [seconds], replacing any running one.
  Future<void> start(
    int seconds, {
    String? nextLabel,
    String? nextDetail,
  }) async {
    final int now = _now();
    final TimerRun run = TimerRun.rest(seconds, now);
    _firedUntilMs = now + 1;
    state = RestState(run: run, nextLabel: nextLabel, nextDetail: nextDetail);
    ref.read(navHideReasonsProvider.notifier).hide(NavHideReason.restTimer);
    await _persist();
    unawaited(
      ref.read(backgroundTimerHostProvider).show(run, cues, title: 'Rest'),
    );
  }

  /// Reads a rest saved before the app was killed. A finished or unreadable
  /// one is dropped.
  Future<void> restore() async {
    if (state != null) return;
    final repo = ref.read(runtimeStateRepositoryProvider);
    final Map<String, dynamic>? json = await repo.read(storageKey);
    if (json == null) return;
    final Object? raw = json['run'];
    final TimerRun? run = TimerRun.fromJson(
      raw is Map<String, dynamic> ? raw : null,
    );
    final int now = _now();
    if (run == null || run.snapshotAt(now).finished) {
      await repo.clear(storageKey);
      return;
    }
    _firedUntilMs = now + 1;
    state = RestState(
      run: run,
      nextLabel: json['nextLabel'] as String?,
      nextDetail: json['nextDetail'] as String?,
    );
    ref.read(navHideReasonsProvider.notifier).hide(NavHideReason.restTimer);
    unawaited(
      ref.read(backgroundTimerHostProvider).show(run, cues, title: 'Rest'),
    );
  }

  /// Called every frame while a rest is on screen: fires due cues and ends
  /// the rest when its time is up. Cheap when nothing is due.
  void tick() {
    final RestState? s = state;
    if (s == null) return;
    final int now = _now();
    final List<CueEvent> due = s.run.cuesBetween(_firedUntilMs, now + 1, cues);
    _firedUntilMs = now + 1;
    final CuePlayer player = ref.read(cuePlayerProvider);
    for (final CueEvent e in due) {
      unawaited(player.play(e, cues));
    }
    if (s.run.snapshotAt(now).finished) unawaited(end());
  }

  /// Adds [seconds] to the rest (negative shortens it; at zero it ends).
  Future<void> adjust(int seconds) async {
    final RestState? s = state;
    if (s == null) return;
    final int now = _now();
    final TimerRun run = s.run.addTime(now, ms: seconds * 1000);
    if (run.snapshotAt(now).finished) {
      await end();
      return;
    }
    state = s.withRun(run);
    await _persist();
    unawaited(
      ref.read(backgroundTimerHostProvider).show(run, cues, title: 'Rest'),
    );
  }

  /// Stops the rest and clears everything that showed it.
  Future<void> end() async {
    if (state == null) return;
    state = null;
    ref.read(navHideReasonsProvider.notifier).show(NavHideReason.restTimer);
    await ref.read(runtimeStateRepositoryProvider).clear(storageKey);
    await ref.read(backgroundTimerHostProvider).clear();
  }

  Future<void> _persist() {
    final RestState? s = state;
    if (s == null) return Future<void>.value();
    return ref
        .read(runtimeStateRepositoryProvider)
        .write(storageKey, s.toJson());
  }
}

final NotifierProvider<RestController, RestState?> trainRestProvider =
    NotifierProvider<RestController, RestState?>(RestController.new);

/// Repaints [builder] while a rest runs: per frame when [smooth] (the ring),
/// otherwise when the shown second changes. Also drives `tick()`.
class RestTicker extends ConsumerStatefulWidget {
  const RestTicker({super.key, required this.builder, this.smooth = false});

  final Widget Function(
    BuildContext context,
    RestState rest,
    TimerSnapshot snapshot,
  )
  builder;
  final bool smooth;

  @override
  ConsumerState<RestTicker> createState() => _RestTickerState();
}

class _RestTickerState extends ConsumerState<RestTicker>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  int _shownSec = -1;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration _) {
    final RestState? rest = ref.read(trainRestProvider);
    if (rest == null) return;
    ref.read(trainRestProvider.notifier).tick();
    final int now = ref.read(trainNowMsProvider)();
    final TimerSnapshot snap = rest.run.snapshotAt(now);
    final int sec = ((snap.stepDurationMs ?? 0) - snap.stepElapsedMs) ~/ 1000;
    if (widget.smooth || sec != _shownSec) {
      _shownSec = sec;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final RestState? rest = ref.watch(trainRestProvider);
    if (rest == null) return const SizedBox.shrink();
    final int now = ref.read(trainNowMsProvider)();
    return widget.builder(context, rest, rest.run.snapshotAt(now));
  }
}

/// Seconds left in the rest step, rounded up (1:14 means 74 s or less).
int restRemainingSec(TimerSnapshot s) {
  final int d = s.stepDurationMs ?? 0;
  final int left = d - s.stepElapsedMs;
  return left <= 0 ? 0 : (left / 1000).ceil();
}

/// The inline rest bar above the workout's action row.
class RestBar extends ConsumerWidget {
  const RestBar({super.key, required this.onExpand});

  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RestTicker(
      builder: (BuildContext context, RestState rest, TimerSnapshot snap) {
        final ColorScheme cs = context.cs;
        final TextTheme tt = context.text;
        final int left = restRemainingSec(snap);
        final double total = (snap.stepDurationMs ?? 1).toDouble();
        final double fraction = total <= 0
            ? 0
            : ((total - snap.stepElapsedMs) / total).clamp(0.0, 1.0);
        final RestController c = ref.read(trainRestProvider.notifier);
        return Container(
          margin: const EdgeInsets.only(bottom: Space.sm),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: Radii.cardR,
            border: Border.all(color: cs.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              LinearProgressIndicator(
                value: fraction,
                minHeight: TrainSpec.restBarProgress,
                backgroundColor: cs.surfaceContainerHighest,
                color: context.accents.phase(SinewPhase.rest).ring,
              ),
              InkWell(
                onTap: onExpand,
                child: Semantics(
                  button: true,
                  label:
                      'Rest timer, ${ClockText.spoken(left)} left. '
                      'Opens the full screen timer.',
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Space.lg,
                      Space.md,
                      Space.lg,
                      Space.xs,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            rest.nextLabel == null
                                ? 'Rest'
                                : 'Rest · then ${rest.nextLabel}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodyMedium!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: Space.md),
                        Text(
                          formatElapsed(left),
                          key: const ValueKey<String>('rest-remaining'),
                          style: tt.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.sm,
                  0,
                  Space.sm,
                  Space.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _RestButton(
                        label: '-${TrainSpec.restStepSec} s',
                        semantic: 'Subtract ${TrainSpec.restStepSec} seconds',
                        onPressed: () => c.adjust(-TrainSpec.restStepSec),
                      ),
                    ),
                    Expanded(
                      child: _RestButton(
                        label: '+${TrainSpec.restStepSec} s',
                        semantic: 'Add ${TrainSpec.restStepSec} seconds',
                        onPressed: () => c.adjust(TrainSpec.restStepSec),
                      ),
                    ),
                    Expanded(
                      child: _RestButton(
                        label: 'Skip',
                        semantic: 'Skip rest',
                        tonal: true,
                        onPressed: c.end,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RestButton extends StatelessWidget {
  const _RestButton({
    required this.label,
    required this.semantic,
    required this.onPressed,
    this.tonal = false,
  });

  final String label;
  final String semantic;
  final VoidCallback onPressed;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    const ButtonStyle style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(
        Size(IconSpec.tapTarget, SinewSpace.gloveTarget),
      ),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: Space.xs),
      ),
    );
    final Widget child = Text(label, maxLines: 1, textAlign: TextAlign.center);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.xxs),
      child: Semantics(
        button: true,
        label: semantic,
        excludeSemantics: true,
        onTap: onPressed,
        child: tonal
            ? FilledButton.tonal(
                onPressed: onPressed,
                style: style,
                child: child,
              )
            : TextButton(onPressed: onPressed, style: style, child: child),
      ),
    );
  }
}

/// The full-screen rest timer (frame "Rest timer expanded"): the ring, what is
/// next, and -10 s / Skip rest / +10 s.
class RestExpanded extends ConsumerWidget {
  const RestExpanded({super.key, required this.onCollapse});

  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final PhaseColor phase = context.accents.phase(SinewPhase.rest);
    return Material(
      color: cs.surface,
      child: SafeArea(
        child: RestTicker(
          smooth: true,
          builder: (BuildContext context, RestState rest, TimerSnapshot snap) {
            final int left = restRemainingSec(snap);
            final double total = (snap.stepDurationMs ?? 1).toDouble();
            final double fraction = total <= 0
                ? 0
                : ((total - snap.stepElapsedMs) / total).clamp(0.0, 1.0);
            final RestController c = ref.read(trainRestProvider.notifier);
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.sm,
                    Space.sm,
                    Space.screen,
                    Space.sm,
                  ),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Back to workout',
                        onPressed: onCollapse,
                        constraints: const BoxConstraints.tightFor(
                          width: IconSpec.tapTarget,
                          height: IconSpec.tapTarget,
                        ),
                        icon: const Icon(Icons.close_fullscreen_rounded),
                      ),
                      const SizedBox(width: Space.sm),
                      Text('Rest', style: tt.titleLarge),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.screen,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Semantics(
                            label:
                                'Rest, ${ClockText.spoken(left)} left of '
                                '${ClockText.spoken(rest.totalSec)}',
                            excludeSemantics: true,
                            child: TimerRing(
                              fraction: fraction,
                              ringColor: phase.ring,
                              trackColor: phase.ring.withValues(
                                alpha: Opacities.track,
                              ),
                              size: TrainSpec.restRing,
                              strokeWidth: TrainSpec.restRingStroke,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      formatElapsed(left),
                                      key: const ValueKey<String>(
                                        'rest-expanded-remaining',
                                      ),
                                      style: context.timerNumeral,
                                    ),
                                  ),
                                  Text(
                                    'of ${formatElapsed(rest.totalSec)}',
                                    style: tt.bodyLarge!.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (rest.nextLabel != null) ...<Widget>[
                            const SizedBox(height: Space.xl),
                            Text(
                              'NEXT',
                              style: context.sectionHeader,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: Space.xs),
                            Text(
                              rest.nextLabel!,
                              style: tt.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            if (rest.nextDetail != null)
                              Text(
                                rest.nextDetail!,
                                style: tt.bodyLarge!.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.screen,
                    Space.sm,
                    Space.screen,
                    Space.xl,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _RestButton(
                          label: '-${TrainSpec.restStepSec} s',
                          semantic: 'Subtract ${TrainSpec.restStepSec} seconds',
                          onPressed: () => c.adjust(-TrainSpec.restStepSec),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _RestButton(
                          label: 'Skip rest',
                          semantic: 'Skip rest',
                          tonal: true,
                          onPressed: () {
                            onCollapse();
                            c.end();
                          },
                        ),
                      ),
                      Expanded(
                        child: _RestButton(
                          label: '+${TrainSpec.restStepSec} s',
                          semantic: 'Add ${TrainSpec.restStepSec} seconds',
                          onPressed: () => c.adjust(TrainSpec.restStepSec),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
