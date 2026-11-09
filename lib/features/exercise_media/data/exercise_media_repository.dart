// Repository for loading exercise motion records from Drift library DB.
//
// Features:
// - LRU cache of 64 motions
// - Resilient fallbacks: returns null on missing row or corrupt data
// - Off-UI-thread decoding using compute()
// - Immutable Motion model

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sinew/core/db/library/library_db.dart';

import '../core/binary_payload.dart';
import '../core/camera.dart';
import '../core/timeline.dart';
import 'motion_model.dart';

/// Decodes binary payload and JSON metadata into an immutable [Motion].
Motion _decodeMotionRow(ExerciseMotionRow row) {
  final DecodedPayload payload = BinaryPayload.decode(row.payload);

  final List<dynamic> stepFramesRaw = (jsonDecode(row.stepFrames) as List<dynamic>?) ?? <dynamic>[];
  final Map<int, String?> stepFramesMap = <int, String?>{};
  for (final dynamic item in stepFramesRaw) {
    if (item is Map<String, dynamic>) {
      final int step = (item['step'] as num?)?.toInt() ?? 0;
      final String? kf = item['keyframe'] as String?;
      stepFramesMap[step] = kf;
    }
  }

  final Map<String, dynamic> highlightRaw = (jsonDecode(row.highlight) as Map<String, dynamic>?) ?? <String, dynamic>{};
  final List<String> primary = ((highlightRaw['primary'] as List<dynamic>?) ?? <dynamic>[])
      .map((dynamic e) => e.toString())
      .toList();
  final List<String> secondary = ((highlightRaw['secondary'] as List<dynamic>?) ?? <dynamic>[])
      .map((dynamic e) => e.toString())
      .toList();

  final LoopMode loop = LoopMode.parse(row.loop);

  final MotionTimeline timeline = MotionTimeline(
    keyframes: payload.keyframes,
    segments: payload.segments,
    loop: loop,
  );

  return Motion(
    exerciseId: row.exerciseId,
    tier: MotionTier.parse(row.tier),
    view: FigureView.parse(row.view),
    loop: loop,
    mirror: row.mirror,
    stepFrames: stepFramesMap,
    highlight: MotionHighlight(primary: primary, secondary: secondary),
    props: payload.props,
    timeline: timeline,
  );
}

class ExerciseMediaRepository {
  ExerciseMediaRepository({required this.db, this.cacheCapacity = 64});

  final LibraryDatabase db;
  final int cacheCapacity;

  /// In-memory LRU cache: exerciseId -> Motion
  final LinkedHashMap<String, Motion> _cache = LinkedHashMap<String, Motion>();

  /// Returns the decoded [Motion] for [exerciseId], or null if unavailable.
  /// Never throws; logs decode errors in debug builds only.
  Future<Motion?> motionFor(String exerciseId) async {
    // 1. Custom exercises stay mapOnly in this phase
    if (exerciseId.startsWith('custom-')) {
      return null;
    }

    // 2. Check LRU cache
    if (_cache.containsKey(exerciseId)) {
      final Motion cached = _cache.remove(exerciseId)!;
      _cache[exerciseId] = cached;
      return cached;
    }

    // 3. Query DB
    try {
      final ExerciseMotionRow? row = await (db.select(db.exerciseMotions)
            ..where(($ExerciseMotionsTable t) => t.exerciseId.equals(exerciseId)))
          .getSingleOrNull();

      if (row == null) return null;

      // 4. Decode (synchronously or off-thread)
      final Motion motion;
      if (kIsWeb || row.payload.length < 512) {
        motion = _decodeMotionRow(row);
      } else {
        motion = await compute(_decodeMotionRow, row);
      }

      // 5. Insert into LRU cache
      if (_cache.length >= cacheCapacity) {
        _cache.remove(_cache.keys.first);
      }
      _cache[exerciseId] = motion;

      return motion;
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('ExerciseMediaRepository error loading $exerciseId: $e\n$st');
      }
      return null;
    }
  }

  void clearCache() {
    _cache.clear();
  }
}
