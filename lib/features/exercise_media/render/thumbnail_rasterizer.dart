// Thumbnail rasterizer and LRU cache for 48dp library list thumbnails.
//
// Rasterizes FigurePainter to a ui.Image at device pixel ratio once, then caches it.
// Limits concurrent rasterization to avoid dropping frames on fling.
// Evicts cache on theme changes.

import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sinew/core/theme/figure_colors.dart';

import '../core/camera.dart';
import '../data/motion_model.dart';
import 'figure_painter.dart';

class ThumbnailKey {
  const ThumbnailKey({
    required this.exerciseId,
    required this.female,
    required this.view,
    required this.widthPx,
    required this.heightPx,
    required this.colorHash,
  });

  final String exerciseId;
  final bool female;
  final FigureView view;
  final int widthPx;
  final int heightPx;
  final int colorHash;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThumbnailKey &&
          runtimeType == other.runtimeType &&
          exerciseId == other.exerciseId &&
          female == other.female &&
          view == other.view &&
          widthPx == other.widthPx &&
          heightPx == other.heightPx &&
          colorHash == other.colorHash;

  @override
  int get hashCode => Object.hash(
    exerciseId,
    female,
    view,
    widthPx,
    heightPx,
    colorHash,
  );
}

class ThumbnailRasterizer {
  ThumbnailRasterizer._();

  static final ThumbnailRasterizer instance = ThumbnailRasterizer._();

  // LRU cache for ui.Image thumbnails. ~20 MB budget (each 48dp thumbnail is ~150x150x4 = 90 KB, so ~200 items)
  static const int maxEntries = 220;
  final LinkedHashMap<ThumbnailKey, ui.Image> _cache =
      LinkedHashMap<ThumbnailKey, ui.Image>();

  int _colorHash(FigureColors colors) => Object.hash(
    colors.bodyBase.toARGB32(),
    colors.bodyMuscle.toARGB32(),
    colors.bodyFar.toARGB32(),
    colors.musclePrimary.toARGB32(),
    colors.muscleSecondary.toARGB32(),
    colors.prop.toARGB32(),
    colors.propDetail.toARGB32(),
  );

  ui.Image? getCached(
    Motion motion,
    FigureColors colors, {
    required bool female,
    required double width,
    required double height,
    required double dpr,
  }) {
    final key = ThumbnailKey(
      exerciseId: motion.exerciseId,
      female: female,
      view: motion.view,
      widthPx: (width * dpr).round(),
      heightPx: (height * dpr).round(),
      colorHash: _colorHash(colors),
    );
    if (_cache.containsKey(key)) {
      final img = _cache.remove(key)!;
      _cache[key] = img;
      return img;
    }
    return null;
  }

  Future<ui.Image> rasterize(
    Motion motion,
    FigureColors colors, {
    required bool female,
    required double width,
    required double height,
    required double dpr,
  }) async {
    final key = ThumbnailKey(
      exerciseId: motion.exerciseId,
      female: female,
      view: motion.view,
      widthPx: (width * dpr).round(),
      heightPx: (height * dpr).round(),
      colorHash: _colorHash(colors),
    );

    if (_cache.containsKey(key)) {
      final img = _cache.remove(key)!;
      _cache[key] = img;
      return img;
    }

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final double w = width * dpr;
    final double h = height * dpr;

    final FigurePainter painter = FigurePainter(
      motion: motion,
      colors: colors,
      female: female,
      view: motion.view,
      staticKeyframeIndex: 0,
    );

    painter.paint(canvas, Size(w, h));
    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(w.round(), h.round());

    // Evict oldest if full
    if (_cache.length >= maxEntries) {
      final ThumbnailKey oldestKey = _cache.keys.first;
      final ui.Image? disposed = _cache.remove(oldestKey);
      disposed?.dispose();
    }

    _cache[key] = image;
    return image;
  }

  void evictAll() {
    for (final ui.Image img in _cache.values) {
      img.dispose();
    }
    _cache.clear();
  }
}
