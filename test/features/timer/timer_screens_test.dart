import 'package:flutter/material.dart' hide Flow;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sinew/app.dart';
import 'package:sinew/core/db/repositories/library_repository.dart';
import 'package:sinew/core/db/repositories/library_types.dart';
import 'package:sinew/core/db/repositories/runtime_state_repository.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/routing/nav_visibility.dart';
import 'package:sinew/core/routing/router.dart';
import 'package:sinew/core/widgets/sinew_snackbar.dart';
import 'package:sinew/engines/timer/timer_engine.dart';
import 'package:sinew/features/timer/controller/timer_session.dart';
import 'package:sinew/features/timer/data/active_timer.dart';
import 'package:sinew/features/timer/run/timer_run_screen.dart';

import 'timer_harness.dart';

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(SinewApp)));

/// Starts [config] through the session, the way the setup screen does.
Future<void> _start(
  WidgetTester tester,
  TimerConfig config, {
  String title = 'Test timer',
  bool open = true,
}) async {
  await _container(tester)
      .read(timerSessionProvider.notifier)
      .start(config, title: title);
  await tester.pump();
  if (open) {
    _go(tester, Routes.timerRun);
    await tester.pump(const Duration(milliseconds: 400));
  }
}

/// Moves the fake clock and lets the frame callbacks see it.
Future<void> _advance(
  WidgetTester tester,
  TimerKit kit,
  Duration d, {
  Duration step = const Duration(milliseconds: 100),
}) async {
  Duration left = d;
  while (left > Duration.zero) {
    final Duration s = left < step ? left : step;
    kit.clock.advance(s);
    await tester.pump(s);
    left -= s;
  }
}

/// Navigates the app's router from a test.
void _go(WidgetTester tester, String location) =>
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go(location);

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  // Drift closes its query streams on a zero-length timer.
  await tester.pump(const Duration(milliseconds: 10));
}

class _FakeLibrary implements LibraryRepository {
  _FakeLibrary(this.flow);

  final Flow flow;

  @override
  Future<Flow?> flowById(String id) async => id == flow.id ? flow : null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late TimerKit kit;

  setUp(() => kit = TimerKit());
  tearDown(() => kit.db.close());

  group('home', () {
    testWidgets('shows the nine modes and the seeded presets', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await tester.pumpAndSettle();
      for (final String label in <String>[
        'Stopwatch',
        'Countdown',
        'Interval',
        'Tabata',
        'EMOM',
        'AMRAP',
        'Boxing',
        'Yoga flow',
        'Custom',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
      expect(find.text('EMOM 10'), findsOneWidget);
      expect(find.text('AMRAP 12'), findsOneWidget);
      expect(find.text('Boxing rounds'), findsOneWidget);
      expect(find.text('5 minute countdown'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('seeding twice leaves five presets', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await tester.pumpAndSettle();
      await _close(tester);
      // A second launch on the same database.
      await kit.pumpApp(tester);
      await tester.pumpAndSettle();
      final List<String> names = <String>[
        for (final p in await _container(
          tester,
        ).read(timerPresetRepositoryProvider).all())
          p.name,
      ];
      expect(names, hasLength(5));
      await _close(tester);
    });

    testWidgets('a running timer shows a banner that opens it', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await tester.pumpAndSettle();
      expect(find.text('Running'), findsNothing);
      await _start(tester, const TabataConfig(), title: 'Legs', open: false);
      await tester.pumpAndSettle();
      expect(find.text('Running'), findsOneWidget);
      await tester.tap(find.text('Running'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(TimerRunScreen), findsOneWidget);
      await _close(tester);
    });
  });

  group('setup', () {
    testWidgets('Tabata total updates live', (WidgetTester tester) async {
      await kit.pumpApp(tester, location: Routes.timerSetup('tabata'));
      await tester.pumpAndSettle();
      expect(find.text('4:00'), findsOneWidget);
      expect(find.text('Start · 4:00'), findsOneWidget);
      // Fields: get ready, work, rest, rounds. Work +5 s -> 8 x 5 s more.
      await tester.tap(
        find.byKey(const ValueKey<String>('stepper-plus')).at(1),
      );
      await tester.pump();
      expect(find.text('4:40'), findsOneWidget);
      expect(find.text('Start · 4:40'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('Interval total follows rounds', (WidgetTester tester) async {
      await kit.pumpApp(tester, location: Routes.timerSetup('interval'));
      await tester.pumpAndSettle();
      // 10 + 8 x 30 + 7 x 15 = 355 s
      expect(find.text('5:55'), findsOneWidget);
      // Rounds is the fourth field: one more round adds 30 + 15 s.
      await tester.tap(
        find.byKey(const ValueKey<String>('stepper-plus')).at(3),
      );
      await tester.pump();
      expect(find.text('6:40'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('a bad mode in the link opens the Timer home', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester, location: '/timer/setup/nonsense');
      await tester.pumpAndSettle();
      expect(find.text('SAVED PRESETS'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('Save preset adds it to the list', (WidgetTester tester) async {
      await kit.pumpApp(tester, location: Routes.timerSetup('emom'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save preset'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Kettlebell EMOM');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final names = <String>[
        for (final p in await _container(
          tester,
        ).read(timerPresetRepositoryProvider).all())
          p.name,
      ];
      expect(names, contains('Kettlebell EMOM'));
      await _close(tester);
    });

    testWidgets('?flow loads a library flow into the yoga setup', (
      WidgetTester tester,
    ) async {
      const Flow flow = Flow(
        id: 'evening',
        name: 'Evening wind-down',
        category: 'yoga',
        totalDurationSec: 70,
        rounds: 1,
        steps: <FlowStep>[
          FlowStep(
            position: 0,
            exerciseId: 'child-pose',
            label: 'Child pose',
            holdSec: 30,
            transitionSec: 5,
          ),
          FlowStep(
            position: 1,
            exerciseId: 'pigeon-pose',
            label: 'Pigeon pose',
            holdSec: 30,
            transitionSec: 5,
          ),
        ],
      );
      await kit.pumpApp(
        tester,
        location: '${Routes.timerSetup('yogaFlow')}?flow=evening',
        library: libraryRepositoryProvider.overrideWith(
          (Ref ref) async => _FakeLibrary(flow),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Child pose'), findsOneWidget);
      expect(find.text('Pigeon pose'), findsOneWidget);
      // 30 + 5 + 30
      expect(find.text('1:05'), findsWidgets);
      await tester.tap(find.textContaining('Start ·'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      final ActiveTimer a = _container(tester)
          .read(timerSessionProvider)
          .value!;
      expect(a.run.mode, TimerMode.yogaFlow);
      expect(a.run.steps.first.exerciseId, 'child-pose');
      expect(a.title, 'Evening wind-down');
      await _close(tester);
    });

    testWidgets('a custom sequence is built step by step', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester, location: Routes.timerSetup('custom'));
      await tester.pumpAndSettle();
      expect(find.text('Start'), findsOneWidget);
      await tester.tap(find.text('Add step'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Swings');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Swings'), findsOneWidget);
      expect(find.text('Start · 0:30'), findsOneWidget);
      await _close(tester);
    });
  });

  group('running', () {
    testWidgets('start from setup shows the first numeral, then moves on', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester, location: Routes.timerSetup('tabata'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start · 4:00'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(TimerRunScreen), findsOneWidget);
      expect(find.text('GET READY'), findsOneWidget);
      expect(find.text('0:10'), findsOneWidget);
      expect(find.text('Next: Work 0:20'), findsOneWidget);
      await _advance(tester, kit, const Duration(seconds: 12));
      expect(find.text('WORK'), findsOneWidget);
      expect(find.text('0:18'), findsOneWidget);
      expect(find.text('Round 1 of 8'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('pause stops the numeral, resume continues', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await _start(tester, const TabataConfig(prepareSec: 0));
      await tester.pump(const Duration(milliseconds: 400));
      await _advance(tester, kit, const Duration(seconds: 3));
      expect(find.text('0:17'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();
      await _advance(tester, kit, const Duration(minutes: 3));
      expect(find.text('0:17'), findsOneWidget);
      expect(find.text('PAUSED'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      await _advance(tester, kit, const Duration(seconds: 2));
      expect(find.text('0:15'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('skip and +10s change the step', (WidgetTester tester) async {
      await kit.pumpApp(tester);
      await _start(tester, const TabataConfig(prepareSec: 0));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('+10s'));
      await tester.pump();
      expect(find.text('0:30'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('REST'), findsOneWidget);
      expect(find.text('0:10'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('five minutes in the background shows the right step', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await _start(tester, const TabataConfig());
      await tester.pump(const Duration(milliseconds: 400));
      // 10 s prepare, then 30 s cycles: 155 s is 5 s into the 5th rest.
      kit.clock.advance(const Duration(seconds: 155));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('REST'), findsOneWidget);
      expect(find.text('0:05'), findsOneWidget);
      expect(find.text('Round 5 of 8'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('the boxing warning face shows in the last 10 seconds', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await _start(
        tester,
        const BoxingConfig(rounds: 2, roundSec: 30, restSec: 10, prepareSec: 0),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('10 seconds left'), findsNothing);
      await _advance(tester, kit, const Duration(seconds: 21));
      expect(find.text('10 seconds left'), findsOneWidget);
      expect(find.text('0:09'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('lock disables the controls', (WidgetTester tester) async {
      await kit.pumpApp(tester);
      await _start(tester, const TabataConfig(prepareSec: 0));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byIcon(Icons.lock_open_rounded));
      await tester.pump();
      expect(find.textContaining('Controls are locked'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();
      final ActiveTimer a = _container(tester)
          .read(timerSessionProvider)
          .value!;
      expect(a.run.isPaused, isFalse);
      expect(a.run.locked, isTrue);
      await _close(tester);
    });

    testWidgets('stop asks first, then shows the summary', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await _start(tester, const TabataConfig(prepareSec: 0));
      // The ticker keeps the screen busy, so pump by hand, never settle.
      await tester.tap(find.text('Stop'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Stop the timer?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Stopped'), findsNothing);
      await tester.tap(find.text('Stop'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Stop'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Stopped'), findsOneWidget);
      expect(find.text('Log as workout'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('the nav is hidden while the run screen is open', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await _start(tester, const TabataConfig());
      await tester.pump(const Duration(milliseconds: 400));
      final ProviderContainer c = _container(tester);
      expect(
        c.read(navHideReasonsProvider),
        contains(NavHideReason.runningTimer),
      );
      expect(kit.wake.calls, contains(true));
      // Leaving the screen brings the nav and the sleep timer back.
      _go(tester, Routes.timer);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        c.read(navHideReasonsProvider),
        isNot(contains(NavHideReason.runningTimer)),
      );
      expect(kit.wake.calls.last, isFalse);
      await _close(tester);
    });

    testWidgets('AMRAP counts rounds from a tap and takes one back', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await _start(tester, const AmrapConfig(capSec: 300));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('5:00'), findsOneWidget);
      expect(find.text('Rounds'), findsOneWidget);
      await tester.tap(find.text('Tap anywhere here'));
      await tester.pump();
      await tester.tap(find.text('Tap anywhere here'));
      await tester.pump();
      await tester.tap(find.text('Tap anywhere here'));
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('stopwatch counts up and records laps', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await _start(tester, const StopwatchConfig(), title: 'Stopwatch');
      await tester.pump(const Duration(milliseconds: 400));
      await _advance(tester, kit, const Duration(seconds: 65));
      expect(find.text('1:05'), findsWidgets);
      await tester.tap(find.text('Lap'));
      await tester.pump();
      expect(find.text('Lap 1'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('yoga flow shows the pose and what is next', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await _start(
        tester,
        const YogaFlowConfig(
          poses: <YogaPose>[
            YogaPose(label: 'Pigeon pose', holdSec: 60),
            YogaPose(label: 'Cobra', holdSec: 30),
          ],
        ),
        title: 'Evening wind-down',
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Pigeon pose'), findsOneWidget);
      expect(find.text('hold of 1:00'), findsOneWidget);
      expect(find.text('Next: Transition 0:05'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('a persisted run is restored after a kill', (
      WidgetTester tester,
    ) async {
      // First "process": start, then drop everything but the database.
      final ProviderContainer first = kit.container();
      await first.read(timerSessionProvider.future);
      await first
          .read(timerSessionProvider.notifier)
          .start(const TabataConfig(), title: 'Legs');
      await first.read(timerSessionProvider.notifier).flush();
      first.dispose();
      kit.clock.advance(const Duration(seconds: 25));

      // Second "process": a cold start straight onto the run screen.
      await kit.pumpApp(tester, location: Routes.timerRun);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(TimerRunScreen), findsOneWidget);
      // 10 s prepare, then 15 s into the first work step.
      expect(find.text('WORK'), findsOneWidget);
      expect(find.text('0:05'), findsOneWidget);
      expect(find.text('Legs'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('finished: Log as workout saves a session', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await _start(tester, const CountdownConfig(durationSec: 20));
      await tester.pump(const Duration(milliseconds: 400));
      await _advance(tester, kit, const Duration(seconds: 21));
      expect(find.text('Done. Nice work.'), findsOneWidget);
      expect(find.text('Log as workout'), findsOneWidget);
      expect(kit.cues.kinds.last, CueKind.finish);

      await tester.tap(find.text('Log as workout'));
      // Not pumpAndSettle: the snackbar's own timer would run out first.
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      final List<WorkoutSession> saved = await _container(tester)
          .read(sessionRepositoryProvider)
          .allWithTree();
      expect(saved, hasLength(1));
      expect(saved.single.source, SessionSource.timer);
      expect(find.text('Workout logged.'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      hideSinewSnackBar();
      expect(_container(tester).read(timerSessionProvider).value, isNull);
      expect(
        await _container(tester)
            .read(runtimeStateRepositoryProvider)
            .read(RuntimeStateRepository.runningTimer),
        isNull,
      );
      await _close(tester);
    });

    testWidgets('finished: Close discards without logging', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester);
      await _start(tester, const CountdownConfig(durationSec: 5));
      await tester.pump(const Duration(milliseconds: 400));
      await _advance(tester, kit, const Duration(seconds: 6));
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(
        await _container(tester).read(sessionRepositoryProvider).allWithTree(),
        isEmpty,
      );
      expect(find.text('SAVED PRESETS'), findsOneWidget);
      await _close(tester);
    });
  });

  group('text scale', () {
    testWidgets('home, setup and run lay out at 200% on a 360dp phone', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester, textScale: 2);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final String mode in <String>[
        'tabata',
        'interval',
        'amrap',
        'boxing',
        'custom',
        'yogaFlow',
        'stopwatch',
      ]) {
        _go(tester, Routes.timerSetup(mode));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'setup $mode');
      }
      await _close(tester);
    });

    testWidgets('the run and finished screens lay out at 200%', (
      WidgetTester tester,
    ) async {
      await kit.pumpApp(tester, textScale: 2);
      for (final TimerConfig c in <TimerConfig>[
        const BoxingConfig(rounds: 2, roundSec: 30, restSec: 10, prepareSec: 0),
        const AmrapConfig(capSec: 300),
        const StopwatchConfig(),
        const TabataConfig(prepareSec: 0),
      ]) {
        await _start(tester, c);
        await tester.pump(const Duration(milliseconds: 400));
        await _advance(tester, kit, const Duration(seconds: 22));
        expect(tester.takeException(), isNull, reason: '${c.mode}');
      }
      await _start(tester, const CountdownConfig(durationSec: 3));
      await _advance(tester, kit, const Duration(seconds: 4));
      expect(find.text('Log as workout'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _close(tester);
    });
  });
}
