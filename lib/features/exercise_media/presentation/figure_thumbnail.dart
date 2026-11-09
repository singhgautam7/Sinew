// 48dp figure thumbnail widget for ExerciseTile in library and picker lists.
//
// Asynchronously rasterizes thumbnail using ThumbnailRasterizer and caches ui.Image.
// Cross-fades from a subtle placeholder to the rasterized figure.
// Falls back to MuscleMap when motion is absent or corrupt.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/core/providers.dart';
import 'package:sinew/core/settings/app_settings.dart';
import 'package:sinew/core/theme/app_theme.dart' hide Motion;
import 'package:sinew/core/widgets/domain/muscle_map.dart';

import '../data/motion_model.dart';
import '../render/thumbnail_rasterizer.dart';
import 'media_providers.dart';

class FigureThumbnail extends StatelessWidget {
  const FigureThumbnail({
    super.key,
    required this.exerciseId,
    required this.primaryMuscles,
    this.secondaryMuscles = const <String>[],
    this.sex,
    this.size = 48.0,
  });

  final String exerciseId;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final Sex? sex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool hasScope =
        context.findAncestorWidgetOfExactType<ProviderScope>() != null ||
        context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() != null;

    if (!hasScope) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.cs.surface,
          borderRadius: Radii.thumbR,
        ),
        clipBehavior: Clip.antiAlias,
        child: MuscleMap(
          primary: primaryMuscles,
          secondary: secondaryMuscles,
          fit: MuscleMapFit.crop,
          sex: sex,
          showLabels: false,
        ),
      );
    }

    return _FigureThumbnailConsumer(
      exerciseId: exerciseId,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      sex: sex,
      size: size,
    );
  }
}

class _FigureThumbnailConsumer extends ConsumerStatefulWidget {
  const _FigureThumbnailConsumer({
    required this.exerciseId,
    required this.primaryMuscles,
    this.secondaryMuscles = const <String>[],
    this.sex,
    this.size = 48.0,
  });

  final String exerciseId;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final Sex? sex;
  final double size;

  @override
  ConsumerState<_FigureThumbnailConsumer> createState() =>
      _FigureThumbnailConsumerState();
}

class _FigureThumbnailConsumerState
    extends ConsumerState<_FigureThumbnailConsumer> {
  ui.Image? _image;
  bool _rasterizing = false;

  bool _isFemale(AppSettings settings, Profile? profile) {
    return switch (settings.figureBody) {
      FigureBodySetting.male => false,
      FigureBodySetting.female => true,
      FigureBodySetting.followProfile =>
        (widget.sex ?? profile?.sex) == Sex.female,
    };
  }

  void _requestRasterization(
    Motion motion,
    FigureColors colors,
    bool female,
    double dpr,
  ) {
    if (_rasterizing) return;

    // Check synchronous cache first
    final cached = ThumbnailRasterizer.instance.getCached(
      motion,
      colors,
      female: female,
      width: widget.size,
      height: widget.size,
      dpr: dpr,
    );
    if (cached != null) {
      if (_image != cached) {
        setState(() => _image = cached);
      }
      return;
    }

    _rasterizing = true;
    ThumbnailRasterizer.instance
        .rasterize(
          motion,
          colors,
          female: female,
          width: widget.size,
          height: widget.size,
          dpr: dpr,
        )
        .then((ui.Image img) {
          if (mounted) {
            setState(() {
              _image = img;
              _rasterizing = false;
            });
          }
        })
        .catchError((_) {
          if (mounted) {
            setState(() => _rasterizing = false);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final FigureColors figColors = context.figureColors;
    final AppSettings settings = ref.watch(settingsProvider);
    final Profile? profile = ref.watch(currentProfileProvider).value;
    final bool female = _isFemale(settings, profile);
    final double dpr = MediaQuery.devicePixelRatioOf(context);

    final AsyncValue<Motion?> motionAsync = ref.watch(
      motionProvider(widget.exerciseId),
    );

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: Radii.thumbR,
      ),
      clipBehavior: Clip.antiAlias,
      child: motionAsync.when(
        loading: () => _buildPlaceholder(cs),
        error: (Object _, StackTrace? _) => _buildFallbackMap(),
        data: (Motion? motion) {
          if (motion == null || motion.tier == MotionTier.mapOnly) {
            return _buildFallbackMap();
          }

          // Check/trigger rasterization
          _requestRasterization(motion, figColors, female, dpr);

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _image != null
                ? RawImage(
                    key: const ValueKey<String>('rasterized_figure'),
                    image: _image,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.contain,
                  )
                : _buildPlaceholder(cs),
          );
        },
      ),
    );
  }

  Widget _buildFallbackMap() {
    return MuscleMap(
      primary: widget.primaryMuscles,
      secondary: widget.secondaryMuscles,
      fit: MuscleMapFit.crop,
      sex: widget.sex,
      showLabels: false,
    );
  }

  Widget _buildPlaceholder(ColorScheme cs) {
    return Container(
      key: const ValueKey<String>('placeholder'),
      color: cs.surfaceContainerLow,
      alignment: Alignment.center,
      child: Icon(
        Icons.accessibility_new_rounded,
        size: widget.size * 0.45,
        color: cs.outlineVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
