import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/exercise.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/theme/app_theme.dart' hide Motion;
import 'package:sinew/core/widgets/domain/muscle_map.dart';
import 'package:sinew/features/exercise_media/core/camera.dart';
import 'package:sinew/features/exercise_media/core/math3d.dart';
import 'package:sinew/features/exercise_media/core/timeline.dart';
import 'package:sinew/features/exercise_media/data/motion_model.dart';
import 'package:sinew/features/exercise_media/presentation/exercise_media_view.dart';
import 'package:sinew/features/exercise_media/presentation/figure_thumbnail.dart';
import 'package:sinew/features/exercise_media/presentation/frame_strip_view.dart';
import 'package:sinew/features/exercise_media/presentation/media_providers.dart';
import 'package:sinew/features/exercise_media/presentation/motion_player.dart';
import 'package:sinew/features/settings/settings_screen.dart';

Motion _createTestMotion({
  String id = 'test-squat',
  MotionTier tier = MotionTier.animated,
  bool mirror = true,
}) {
  const kf0 = PoseKeyframe(
    id: 'start',
    rootPos: Vec3(0, 0.54, 0),
    rootRot: Quat.identity,
    joints: <Quat>[
      Quat.identity, Quat.identity, Quat.identity, Quat.identity,
      Quat.identity, Quat.identity, Quat.identity, Quat.identity,
      Quat.identity, Quat.identity, Quat.identity, Quat.identity,
      Quat.identity, Quat.identity, Quat.identity, Quat.identity,
      Quat.identity, Quat.identity, Quat.identity,
    ],
  );

  const kf1 = PoseKeyframe(
    id: 'bottom',
    rootPos: Vec3(0, 0.35, 0),
    rootRot: Quat.identity,
    joints: <Quat>[
      Quat.identity, Quat.identity, Quat.identity, Quat.identity,
      Quat.identity, Quat.identity, Quat.identity, Quat.identity,
      Quat.identity, Quat.identity, Quat.identity, Quat.identity,
      Quat.identity, Quat.identity, Quat.identity, Quat.identity,
      Quat.identity, Quat.identity, Quat.identity,
    ],
  );

  final timeline = MotionTimeline(
    keyframes: const <PoseKeyframe>[kf0, kf1],
    segments: const <TimelineSegment>[
      TimelineSegment(fromIndex: 0, toIndex: 1, durationSec: 1.0),
      TimelineSegment(fromIndex: 1, toIndex: 0, durationSec: 1.0),
    ],
    loop: LoopMode.repeat,
  );

  return Motion(
    exerciseId: id,
    tier: tier,
    view: FigureView.side,
    loop: LoopMode.repeat,
    mirror: mirror,
    stepFrames: const <int, String?>{0: 'start', 1: 'bottom'},
    highlight: const MotionHighlight(
      primary: <String>['quadriceps'],
      secondary: <String>['glutes'],
    ),
    props: const <String>['barbell'],
    timeline: timeline,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  Widget wrapWithHarness(
    Widget child, {
    List<dynamic> overrides = const <dynamic>[],
    bool disableAnimations = false,
    bool scaffold = true,
  }) {
    return ProviderScope(
      overrides: <Override>[
        prefsProvider.overrideWithValue(prefs),
        ...overrides.whereType<Override>(),
      ],
      child: MaterialApp(
        theme: AppTheme.of(Tone.light),
        builder: (BuildContext context, Widget? w) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
          ),
          child: w!,
        ),
        home: scaffold ? Scaffold(body: child) : child,
      ),
    );
  }

  group('MotionPlayer Widget Tests', () {
    testWidgets('Renders figure and interactive playback controls', (
      WidgetTester tester,
    ) async {
      final motion = _createTestMotion();

      await tester.pumpWidget(
        wrapWithHarness(
          MotionPlayer(motion: motion, height: 260.0),
        ),
      );
      await tester.pump();

      // Controls overlay: play/pause icon button, speed pill, scrub bar
      expect(find.byType(MotionPlayer), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('1.0x'), findsOneWidget);
      expect(find.text('Side A'), findsOneWidget);

      // Tap speed pill -> toggles to 0.5x
      await tester.tap(find.text('1.0x'));
      await tester.pump();
      expect(find.text('0.5x'), findsOneWidget);

      // Tap mirror / switch side pill -> toggles to Side B
      await tester.tap(find.text('Side A'));
      await tester.pump();
      expect(find.text('Side B'), findsOneWidget);

      // Tap play/pause button to pause
      final Finder playPauseBtn = find.byTooltip('Pause');
      expect(playPauseBtn, findsOneWidget);
      await tester.tap(playPauseBtn);
      await tester.pump();
      expect(find.byTooltip('Play'), findsOneWidget);
    });

    testWidgets('Auto-fade hides controls after 2s; surface tap restores them', (
      WidgetTester tester,
    ) async {
      final motion = _createTestMotion();

      await tester.pumpWidget(
        wrapWithHarness(
          MotionPlayer(motion: motion, height: 260.0),
        ),
      );
      await tester.pump();

      // Controls start visible
      final Finder speedPill = find.text('1.0x');
      expect(speedPill, findsOneWidget);

      // Advance by 2.1 seconds while playing -> controls fade out
      await tester.pump(const Duration(milliseconds: 2100));

      // AnimatedOpacity opacity should be 0.0
      final Finder opacityFinder = find.byType(AnimatedOpacity);
      expect(opacityFinder, findsOneWidget);
      final AnimatedOpacity opacity = tester.widget<AnimatedOpacity>(opacityFinder);
      expect(opacity.opacity, 0.0);

      // Tap surface to reveal controls
      await tester.tap(find.byType(MotionPlayer));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      final AnimatedOpacity restoredOpacity = tester.widget<AnimatedOpacity>(opacityFinder);
      expect(restoredOpacity.opacity, 1.0);
    });

    testWidgets('Reduced motion disables autoplay and starts paused', (
      WidgetTester tester,
    ) async {
      final motion = _createTestMotion();

      await tester.pumpWidget(
        wrapWithHarness(
          MotionPlayer(motion: motion, height: 260.0),
          disableAnimations: true,
        ),
      );
      await tester.pump();

      // Starts paused with Play button visible
      expect(find.byTooltip('Play'), findsOneWidget);
    });

    testWidgets('Spring to step on activeStepIndex change', (
      WidgetTester tester,
    ) async {
      final motion = _createTestMotion();
      int activeStep = 0;

      await tester.pumpWidget(
        wrapWithHarness(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: <Widget>[
                  MotionPlayer(
                    motion: motion,
                    activeStepIndex: activeStep,
                    onStepChanged: (int idx) => setState(() => activeStep = idx),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => activeStep = 1),
                    child: const Text('Go Step 2'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pump();

      // Tap button to step 2
      await tester.tap(find.text('Go Step 2'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Player pauses on step jump
      expect(find.byTooltip('Play'), findsOneWidget);
    });
  });

  group('FrameStripView Widget Tests', () {
    testWidgets('Renders pageable frames strip with step badge and dots', (
      WidgetTester tester,
    ) async {
      final motion = _createTestMotion(tier: MotionTier.frames);
      int currentStep = 0;

      await tester.pumpWidget(
        wrapWithHarness(
          FrameStripView(
            motion: motion,
            activeStepIndex: currentStep,
            onStepChanged: (int idx) => currentStep = idx,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Step 1'), findsOneWidget);

      // Tap on second step dot indicator
      final Finder dotFinder = find.byType(GestureDetector);
      await tester.tap(dotFinder.last);
      await tester.pumpAndSettle();

      expect(currentStep, 1);
      expect(find.text('Step 2'), findsOneWidget);
    });
  });

  group('ExerciseMediaView & Fallback Tests', () {
    testWidgets('Toggles between Figure and Muscles via SinewSegmentedControl', (
      WidgetTester tester,
    ) async {
      final motion = _createTestMotion();
      const exercise = Exercise(
        id: 'test-squat',
        name: 'Barbell Back Squat',
        category: 'strength',
        trackingType: TrackingType.weightReps,
        primaryMuscles: <String>['quadriceps'],
        secondaryMuscles: <String>['glutes'],
      );

      await tester.pumpWidget(
        wrapWithHarness(
          const ExerciseMediaView(exercise: exercise),
          disableAnimations: true,
          overrides: <Override>[
            motionProvider('test-squat').overrideWith((Ref ref) async => motion),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Starts on Figure tab
      expect(find.text('Figure'), findsOneWidget);
      expect(find.text('Muscles'), findsOneWidget);

      // Tap Muscles segment -> switches to MuscleMap
      await tester.tap(find.text('Muscles'));
      await tester.pumpAndSettle();

      expect(find.byType(MuscleMap), findsOneWidget);
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('Gracefully falls back to MuscleMap when motion is absent', (
      WidgetTester tester,
    ) async {
      const exercise = Exercise(
        id: 'custom-exercise',
        name: 'Custom Pushup',
        category: 'calisthenics',
        trackingType: TrackingType.reps,
        primaryMuscles: <String>['chest'],
      );

      await tester.pumpWidget(
        wrapWithHarness(
          const ExerciseMediaView(exercise: exercise),
          overrides: <Override>[
            motionProvider('custom-exercise').overrideWith((Ref ref) async => null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Shows MuscleMap directly without crashing
      expect(find.byType(MuscleMap), findsOneWidget);
      expect(find.text('Figure'), findsNothing);
    });
  });

  group('FigureThumbnail Widget Tests', () {
    testWidgets('Renders thumbnail and falls back to MuscleMap when motion is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithHarness(
          const FigureThumbnail(
            exerciseId: 'unknown-ex',
            primaryMuscles: <String>['quadriceps'],
            secondaryMuscles: <String>['glutes'],
          ),
          overrides: <Override>[
            motionProvider('unknown-ex').overrideWith((Ref ref) async => null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MuscleMap), findsOneWidget);
    });
  });

  group('Settings Figure Body Option Tests', () {
    testWidgets('Can select Figure Body setting in SettingsScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithHarness(
          const SettingsScreen(),
          scaffold: false,
        ),
      );
      await tester.pumpAndSettle();

      // Appearance section has Figure body row
      expect(find.text('Figure body'), findsOneWidget);
      expect(find.text('Follow profile'), findsOneWidget);

      // Tap row to open sheet
      await tester.tap(find.text('Figure body'));
      await tester.pumpAndSettle();

      // Sheet contains all options: Follow profile, Male, Female
      expect(find.text('Choose the anatomical base for exercise figures.'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);

      // Tap 'Female'
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      // Row updates value
      expect(find.text('Female'), findsOneWidget);
    });
  });
}
