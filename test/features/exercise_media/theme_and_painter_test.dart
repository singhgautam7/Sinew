import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/theme/app_theme.dart' hide Motion;
import 'package:sinew/features/exercise_media/core/camera.dart';
import 'package:sinew/features/exercise_media/core/timeline.dart';
import 'package:sinew/features/exercise_media/data/motion_model.dart';
import 'package:sinew/features/exercise_media/render/figure_painter.dart';
import 'package:sinew/features/exercise_media/render/shape_cache.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  final double r = channel(c.r);
  final double g = channel(c.g);
  final double b = channel(c.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color c1, Color c2) {
  final double l1 = _luminance(c1);
  final double l2 = _luminance(c2);
  final double lighter = math.max(l1, l2);
  final double darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Exercise Media Guardrails & Lints', () {
    test('No color literals Color(0x in lib/features/exercise_media/', () {
      final Directory dir = Directory('lib/features/exercise_media');
      final RegExp hexPattern = RegExp(r'Color\(0x|Color\.fromARGB|Color\.fromRGBO');

      final List<String> violations = <String>[];
      for (final FileSystemEntity entity in dir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final String content = entity.readAsStringSync();
          if (hexPattern.hasMatch(content)) {
            violations.add(entity.path);
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Raw Color literals are banned in exercise_media. Use FigureColors tokens.',
      );
    });
  });

  group('FigureColors Contrast Requirements', () {
    final List<Tone> tones = <Tone>[Tone.light, Tone.dark, Tone.amoled];
    final List<Color> sampleSeeds = <Color>[
      const Color(0xFF6E8A16), // Sinew brand green
      const Color(0xFF2E79B7), // Blue
      const Color(0xFFC2460D), // Red
    ];

    for (final Tone tone in tones) {
      for (final Color seed in sampleSeeds) {
        test('Contrast checks for ${tone.name} with seed ${seed.toARGB32().toRadixString(16)}', () {
          final ThemeData theme = AppTheme.of(tone, seed: seed);
          final FigureColors colors = theme.extension<FigureColors>()!;
          final ColorScheme cs = theme.colorScheme;

          // 1. prop against bodyMuscle >= 3:1
          final double propVsMuscle = _contrastRatio(colors.prop, colors.bodyMuscle);
          expect(
            propVsMuscle,
            greaterThanOrEqualTo(3.0),
            reason: 'prop vs bodyMuscle ratio $propVsMuscle in ${tone.name}',
          );

          // 2. prop against bodyBase >= 3:1
          final double propVsBase = _contrastRatio(colors.prop, colors.bodyBase);
          expect(
            propVsBase,
            greaterThanOrEqualTo(3.0),
            reason: 'prop vs bodyBase ratio $propVsBase in ${tone.name}',
          );

          // 3. prop against card surface >= 3:1
          final double propVsSurface = _contrastRatio(colors.prop, cs.surfaceContainer);
          expect(
            propVsSurface,
            greaterThanOrEqualTo(3.0),
            reason: 'prop vs card surface ratio $propVsSurface in ${tone.name}',
          );

          // 4. musclePrimary against bodyMuscle >= 2.5:1 (or 3:1)
          final double primVsMuscle = _contrastRatio(colors.musclePrimary, colors.bodyMuscle);
          expect(
            primVsMuscle,
            greaterThanOrEqualTo(2.4),
            reason: 'musclePrimary vs bodyMuscle ratio $primVsMuscle in ${tone.name}',
          );
        });
      }
    }
  });

  group('ShapeCache & FigurePainter', () {
    test('ShapeCache singleton initializes unit paths without errors', () {
      final ShapeCache cache = ShapeCache.instance;
      expect(cache.unitCircle, isNotNull);
      expect(cache.unitEllipse, isNotNull);
      expect(cache.unitRoundedRect, isNotNull);
      expect(cache.unitCapsule, isNotNull);
      expect(cache.unitChestPlate, isNotNull);
      expect(cache.unitFoot, isNotNull);
    });

    testWidgets('FigurePainter paints into canvas without throwing', (WidgetTester tester) async {
      final ThemeData theme = AppTheme.of(Tone.light);
      final FigureColors colors = theme.extension<FigureColors>()!;

      final Motion motion = Motion(
        exerciseId: 'test-squat',
        tier: MotionTier.animated,
        view: FigureView.side,
        loop: LoopMode.repeat,
        mirror: false,
        stepFrames: const <int, String?>{},
        highlight: const MotionHighlight(primary: <String>['quadriceps']),
        props: const <String>['barbell'],
        timeline: MotionTimeline(
          keyframes: const <PoseKeyframe>[],
          segments: const <TimelineSegment>[],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: FigurePainter(
                  motion: motion,
                  colors: colors,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
