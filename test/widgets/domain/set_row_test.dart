import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/theme/app_theme.dart';
import 'package:sinew/core/widgets/domain/set_row.dart';

import '../harness.dart';

SetEntry _entry({
  String id = 's1',
  int position = 0,
  SetType type = SetType.normal,
  double? weightKg,
  int? reps,
  int? durationSec,
  double? distanceM,
  int? rounds,
  int? holdSec,
  bool completed = false,
  bool isWarmup = false,
  bool isPR = false,
}) => SetEntry(
  id: id,
  position: position,
  type: type,
  weightKg: weightKg,
  reps: reps,
  durationSec: durationSec,
  distanceM: distanceM,
  rounds: rounds,
  holdSec: holdSec,
  completed: completed,
  isWarmup: isWarmup,
  isPR: isPR,
);

/// Hosts a [SetRow] that keeps its own entry, like a screen would.
class _Host extends StatefulWidget {
  const _Host({
    super.key,
    required this.initial,
    required this.type,
    this.previous,
    this.weightUnit = WeightUnit.kg,
    this.distanceUnit = DistanceUnit.km,
    this.log,
    this.completes,
    this.longPresses,
    this.haptics = false,
    this.planned = false,
    this.paceLabel,
  });

  final SetEntry initial;
  final TrackingType type;
  final SetEntry? previous;
  final WeightUnit weightUnit;
  final DistanceUnit distanceUnit;
  final List<SetEntry>? log;
  final List<bool>? completes;
  final List<int>? longPresses;
  final bool haptics;
  final bool planned;
  final String? paceLabel;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late SetEntry entry = widget.initial;

  @override
  Widget build(BuildContext context) {
    return SetRow(
      entry: entry,
      trackingType: widget.type,
      previous: widget.previous,
      weightUnit: widget.weightUnit,
      distanceUnit: widget.distanceUnit,
      haptics: widget.haptics,
      planned: widget.planned,
      paceLabel: widget.paceLabel,
      onChanged: (SetEntry e) {
        widget.log?.add(e);
        setState(() => entry = e);
      },
      onComplete: (bool done) {
        widget.completes?.add(done);
        setState(() => entry = entry.copyWith(completed: done));
      },
      onLongPress: () => widget.longPresses?.add(1),
    );
  }
}

List<String> _recordHaptics(WidgetTester tester) {
  final List<String> calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall c) async {
      if (c.method == 'HapticFeedback.vibrate') {
        calls.add(c.arguments as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}

String _fieldText(WidgetTester tester, int index) =>
    tester.widget<TextField>(find.byType(TextField).at(index)).controller!.text;

void main() {
  group('inputs per tracking type', () {
    final Map<TrackingType, (int fields, List<String> labels)> expected =
        <TrackingType, (int, List<String>)>{
          TrackingType.weightReps: (2, <String>['kg', 'reps']),
          TrackingType.reps: (1, <String>['reps']),
          TrackingType.time: (1, <String>['time']),
          TrackingType.distanceTime: (2, <String>['km', 'time']),
          TrackingType.rounds: (2, <String>['rounds', 'per round']),
          TrackingType.hold: (1, <String>['hold']),
          TrackingType.flow: (2, <String>['rounds', 'time']),
          TrackingType.unknown: (1, <String>['reps']),
        };
    for (final MapEntry<TrackingType, (int, List<String>)> e
        in expected.entries) {
      for (final Tone tone in <Tone>[Tone.light, Tone.dark]) {
        testWidgets('${e.key.name} in ${tone.name}', (
          WidgetTester tester,
        ) async {
          await pumpThemed(
            tester,
            _Host(initial: _entry(), type: e.key),
            tone: tone,
          );
          expect(find.byType(TextField), findsNWidgets(e.value.$1));
          for (final String l in e.value.$2) {
            expect(find.text(l), findsOneWidget, reason: l);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('a pace read-out is a third cell on distance rows', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(),
          type: TrackingType.distanceTime,
          paceLabel: '5:32 /km',
        ),
      );
      expect(find.text('5:32 /km'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });
  });

  group('typing and units', () {
    testWidgets('weight shows and takes pounds, stores kilograms', (
      WidgetTester tester,
    ) async {
      final List<SetEntry> log = <SetEntry>[];
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(weightKg: 100, reps: 5),
          type: TrackingType.weightReps,
          weightUnit: WeightUnit.lb,
          log: log,
        ),
      );
      expect(_fieldText(tester, 0), '220.46');
      expect(find.text('lb'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), '225');
      expect(log.last.weightKg, closeTo(102.0582, 0.001));
      expect(log.last.reps, 5);
    });

    testWidgets('reps are integers and clearing a field clears the value', (
      WidgetTester tester,
    ) async {
      final List<SetEntry> log = <SetEntry>[];
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(weightKg: 80, reps: 8),
          type: TrackingType.weightReps,
          log: log,
        ),
      );
      await tester.enterText(find.byType(TextField).at(1), '10');
      expect(log.last.reps, 10);
      await tester.enterText(find.byType(TextField).at(1), '');
      expect(log.last.reps, isNull);
      expect(log.last.weightKg, 80);
    });

    testWidgets('time takes m:ss and plain seconds', (
      WidgetTester tester,
    ) async {
      final List<SetEntry> log = <SetEntry>[];
      await pumpThemed(
        tester,
        _Host(initial: _entry(), type: TrackingType.time, log: log),
      );
      await tester.enterText(find.byType(TextField), '1:30');
      expect(log.last.durationSec, 90);
      await tester.enterText(find.byType(TextField), '45');
      expect(log.last.durationSec, 45);
    });

    testWidgets('hold writes holdSec', (WidgetTester tester) async {
      final List<SetEntry> log = <SetEntry>[];
      await pumpThemed(
        tester,
        _Host(initial: _entry(), type: TrackingType.hold, log: log),
      );
      await tester.enterText(find.byType(TextField), '0:30');
      expect(log.last.holdSec, 30);
      expect(log.last.durationSec, isNull);
    });

    testWidgets('distance converts miles to metres', (
      WidgetTester tester,
    ) async {
      final List<SetEntry> log = <SetEntry>[];
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(distanceM: 5000, durationSec: 1660),
          type: TrackingType.distanceTime,
          distanceUnit: DistanceUnit.mi,
          log: log,
        ),
      );
      expect(_fieldText(tester, 0), '3.11');
      expect(_fieldText(tester, 1), '27:40');
      await tester.enterText(find.byType(TextField).at(0), '1');
      expect(log.last.distanceM, closeTo(1609.344, 0.001));
    });

    testWidgets('rounds and flow write rounds, with a time beside', (
      WidgetTester tester,
    ) async {
      final List<SetEntry> log = <SetEntry>[];
      await pumpThemed(
        tester,
        _Host(initial: _entry(), type: TrackingType.rounds, log: log),
      );
      await tester.enterText(find.byType(TextField).at(0), '6');
      await tester.enterText(find.byType(TextField).at(1), '3:00');
      expect(log.last.rounds, 6);
      expect(log.last.durationSec, 180);
    });

    testWidgets("last session's numbers show as hints", (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(weightKg: 82.5),
          previous: _entry(weightKg: 80, reps: 8),
          type: TrackingType.weightReps,
        ),
      );
      expect(find.text('kg · last 80'), findsOneWidget);
      expect(find.text('reps · last 8'), findsOneWidget);
      expect(_fieldText(tester, 0), '82.5');
      expect(_fieldText(tester, 1), '');
      expect(find.text('8'), findsOneWidget); // the hint text
    });
  });

  group('completing', () {
    testWidgets('the check completes the set and shows the done row', (
      WidgetTester tester,
    ) async {
      final List<bool> completes = <bool>[];
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(weightKg: 82.5, reps: 8),
          type: TrackingType.weightReps,
          completes: completes,
        ),
      );
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();
      expect(completes, <bool>[true]);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('82.5 kg × 8'), findsOneWidget);
      expect(find.text('PR'), findsNothing);
    });

    testWidgets('accepting empty inputs fills the hints in first', (
      WidgetTester tester,
    ) async {
      final List<SetEntry> log = <SetEntry>[];
      final List<bool> completes = <bool>[];
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(weightKg: 82.5),
          previous: _entry(weightKg: 80, reps: 8),
          type: TrackingType.weightReps,
          log: log,
          completes: completes,
        ),
      );
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();
      expect(log, hasLength(1));
      expect(log.single.weightKg, 82.5);
      expect(log.single.reps, 8);
      expect(completes, <bool>[true]);
      expect(find.text('82.5 kg × 8'), findsOneWidget);
    });

    testWidgets('tapping a done row opens it again', (
      WidgetTester tester,
    ) async {
      final List<bool> completes = <bool>[];
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(weightKg: 82.5, reps: 8, completed: true),
          type: TrackingType.weightReps,
          completes: completes,
        ),
      );
      await tester.tap(find.text('82.5 kg × 8'));
      await tester.pumpAndSettle();
      expect(completes, <bool>[false]);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('a light impact on complete, none with haptics off', (
      WidgetTester tester,
    ) async {
      final List<String> calls = _recordHaptics(tester);
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(weightKg: 80, reps: 8),
          type: TrackingType.weightReps,
          haptics: true,
        ),
      );
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();
      expect(
        calls.where((String c) => c == 'HapticFeedbackType.lightImpact'),
        hasLength(1),
      );
      calls.clear();
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(id: 'other', weightKg: 80, reps: 8),
          type: TrackingType.reps,
          key: const ValueKey<String>('quiet'),
        ),
      );
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
    });

    testWidgets('the check pops to 1.18 and settles at 1 over 260ms', (
      WidgetTester tester,
    ) async {
      double biggest() {
        double m = 0;
        for (final Transform t in tester.widgetList<Transform>(
          find.descendant(
            of: find.byType(SetRow),
            matching: find.byType(Transform),
          ),
        )) {
          final double s = t.transform.getMaxScaleOnAxis();
          if (s > m) m = s;
        }
        return m;
      }

      await pumpThemed(
        tester,
        _Host(
          initial: _entry(weightKg: 80, reps: 8),
          type: TrackingType.weightReps,
        ),
      );
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 156));
      expect(biggest(), closeTo(1.18, 0.02));
      await tester.pumpAndSettle();
      expect(biggest(), closeTo(1, 0.001));
    });

    testWidgets('reduced motion shows the finished check at once', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(weightKg: 80, reps: 8, isPR: true),
          type: TrackingType.weightReps,
        ),
        disableAnimations: true,
      );
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pump();
      expect(find.text('PR'), findsOneWidget);
      double m = 0;
      for (final Transform t in tester.widgetList<Transform>(
        find.descendant(
          of: find.byType(SetRow),
          matching: find.byType(Transform),
        ),
      )) {
        m = t.transform.getMaxScaleOnAxis() > m
            ? t.transform.getMaxScaleOnAxis()
            : m;
      }
      expect(m, closeTo(1, 0.001));
    });
  });

  group('PR', () {
    testWidgets('the PR pill appears on a completed record set', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(weightKg: 82.5, reps: 8, completed: true, isPR: true),
          type: TrackingType.weightReps,
        ),
      );
      expect(find.text('PR'), findsOneWidget);
    });

    testWidgets('a record set pulses once for 600ms when it completes', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(weightKg: 82.5, reps: 8, isPR: true),
          type: TrackingType.weightReps,
        ),
      );
      Color pulse() {
        final ColoredBox box = tester.widget<ColoredBox>(
          find
              .descendant(
                of: find.byType(SetRow),
                matching: find.byType(ColoredBox),
              )
              .first,
        );
        return box.color;
      }

      expect(pulse().a, 0);
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(pulse().a, closeTo(1, 0.05));
      await tester.pumpAndSettle();
      expect(pulse().a, closeTo(0, 0.001));
    });
  });

  group('looks', () {
    testWidgets('a long press reaches the menu callback', (
      WidgetTester tester,
    ) async {
      final List<int> presses = <int>[];
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(position: 1, weightKg: 80, reps: 8),
          type: TrackingType.weightReps,
          longPresses: presses,
        ),
      );
      await tester.longPress(find.text('2'));
      expect(presses, <int>[1]);
    });

    testWidgets('the badge shows W, D, F and A for typed sets', (
      WidgetTester tester,
    ) async {
      final Map<String, SetEntry> cases = <String, SetEntry>{
        'W': _entry(isWarmup: true),
        'D': _entry(type: SetType.drop),
        'F': _entry(type: SetType.failure),
        'A': _entry(type: SetType.amrap),
      };
      for (final MapEntry<String, SetEntry> c in cases.entries) {
        await pumpThemed(
          tester,
          _Host(
            key: ValueKey<String>(c.key),
            initial: c.value,
            type: TrackingType.reps,
          ),
        );
        expect(find.text(c.key), findsOneWidget, reason: c.key);
      }
    });

    testWidgets('a planned row is a quiet summary', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(position: 2, weightKg: 82.5, reps: 8),
          type: TrackingType.weightReps,
          planned: true,
        ),
      );
      expect(find.byType(TextField), findsNothing);
      expect(find.text('82.5 kg × 8'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('open rows are at least 64dp, the check 52dp', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        _Host(initial: _entry(), type: TrackingType.weightReps),
      );
      expect(
        tester.getSize(find.byType(SetRow)).height,
        greaterThanOrEqualTo(64),
      );
      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.byIcon(Icons.check_rounded),
                    matching: find.byType(SizedBox),
                  )
                  .first,
            )
            .height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('speaks the set, its type and the check state', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpThemed(
        tester,
        _Host(
          initial: _entry(position: 1, isWarmup: true),
          type: TrackingType.weightReps,
        ),
      );
      expect(find.bySemanticsLabel('Set 2, warm-up'), findsOneWidget);
      expect(find.bySemanticsLabel('Mark set 2 complete'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('^Weight in kilograms')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('^Reps')), findsOneWidget);
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp(r'Set 2, warm-up, completed')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('compact', () {
    testWidgets('is read-only: summary, number and PR', (
      WidgetTester tester,
    ) async {
      await pumpThemed(
        tester,
        SetRow.compact(
          entry: _entry(
            position: 1,
            weightKg: 100,
            reps: 5,
            completed: true,
            isPR: true,
          ),
          trackingType: TrackingType.weightReps,
          weightUnit: WeightUnit.lb,
        ),
      );
      expect(find.byType(TextField), findsNothing);
      expect(find.text('220.46 lb × 5'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('PR'), findsOneWidget);
    });

    testWidgets('summarises every tracking type', (WidgetTester tester) async {
      expect(SetRow.summary(_entry(reps: 15), TrackingType.reps), '15 reps');
      expect(
        SetRow.summary(_entry(durationSec: 45), TrackingType.time),
        '0:45',
      );
      expect(
        SetRow.summary(
          _entry(distanceM: 5000, durationSec: 1660),
          TrackingType.distanceTime,
        ),
        '5 km · 27:40',
      );
      expect(
        SetRow.summary(
          _entry(rounds: 6, durationSec: 180),
          TrackingType.rounds,
        ),
        '6 rounds · 3:00',
      );
      expect(
        SetRow.summary(_entry(holdSec: 30), TrackingType.hold),
        '0:30 hold',
      );
      expect(SetRow.summary(_entry(rounds: 5), TrackingType.flow), '5 rounds');
      expect(SetRow.summary(_entry(), TrackingType.weightReps), '-');
      expect(SetRow.summary(_entry(reps: 9), TrackingType.unknown), '9 reps');
    });
  });

  group('200% text at 360dp', () {
    for (final TrackingType type in TrackingType.values) {
      testWidgets('${type.name}: open, done, planned and compact', (
        WidgetTester tester,
      ) async {
        final SetEntry e = _entry(
          weightKg: 142.5,
          reps: 12,
          durationSec: 3725,
          distanceM: 12345,
          rounds: 12,
          holdSec: 125,
          isPR: true,
        );
        final SetEntry prev = e.copyWith(weightKg: 140);
        for (final Widget w in <Widget>[
          _Host(initial: e, type: type, previous: prev, paceLabel: '5:32 /km'),
          _Host(initial: e.copyWith(completed: true), type: type),
          _Host(initial: e, type: type, planned: true),
          SetRow.compact(entry: e, trackingType: type),
        ]) {
          await pumpThemed(tester, w, textScale: 2);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  });
}
