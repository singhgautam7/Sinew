import 'dart:math' as math;

import '../../../core/models/timer_preset.dart';
import '../../../engines/timer/timer_engine.dart';

/// A timer that is on screen or in the background: the run, how it cues, and
/// what the user is looking at. This is the payload persisted under
/// `RuntimeStateRepository.runningTimer`.
class ActiveTimer {
  const ActiveTimer({
    required this.run,
    required this.cues,
    required this.title,
    required this.updatedAtMs,
    this.config,
    this.laps = const <int>[],
    this.presetId,
  });

  static const int currentSchemaVersion = 1;

  final TimerRun run;
  final TimerCues cues;

  /// Shown top left of the run screen and in the notification title.
  final String title;

  /// When this state last changed (epoch ms). The newer of two copies (the
  /// database and the background service) wins.
  final int updatedAtMs;
  final TimerConfig? config;

  /// Stopwatch laps as active elapsed ms at the moment of each lap.
  final List<int> laps;
  final String? presetId;

  ActiveTimer copyWith({
    TimerRun? run,
    TimerCues? cues,
    String? title,
    int? updatedAtMs,
    List<int>? laps,
  }) => ActiveTimer(
    run: run ?? this.run,
    cues: cues ?? this.cues,
    title: title ?? this.title,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    config: config,
    laps: laps ?? this.laps,
    presetId: presetId,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schemaVersion': currentSchemaVersion,
    'updatedAtMs': updatedAtMs,
    'title': title,
    'presetId': presetId,
    'cues': cues.toJson(),
    'config': config?.toJson(),
    'laps': laps,
    'run': run.toJson(),
  };

  /// Reads a payload written by [toJson]. A newer version or corrupt data
  /// returns null, never throws.
  static ActiveTimer? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final Object? v = json['schemaVersion'];
      if (v is! int || v > currentSchemaVersion || v < 1) return null;
      final Object? rawRun = json['run'];
      if (rawRun is! Map<Object?, Object?>) return null;
      final TimerRun? run = TimerRun.fromJson(
        Map<String, dynamic>.from(rawRun),
      );
      if (run == null) return null;
      final Object? rawCues = json['cues'];
      final Object? title = json['title'];
      final Object? laps = json['laps'];
      final Object? pid = json['presetId'];
      final Object? at = json['updatedAtMs'];
      return ActiveTimer(
        run: run,
        cues: rawCues is Map<Object?, Object?>
            ? TimerCues.fromJson(Map<String, dynamic>.from(rawCues))
            : const TimerCues(),
        title: title is String ? title : 'Timer',
        updatedAtMs: at is num ? at.toInt() : run.startedAtMs,
        config: TimerConfig.fromJson(json['config']),
        laps: laps is List<Object?>
            ? <int>[
                for (final Object? l in laps)
                  if (l is num) l.toInt(),
              ]
            : const <int>[],
        presetId: pid is String ? pid : null,
      );
    } on Object {
      return null;
    }
  }

  /// True when [other] is the same run (so a copy held by the background
  /// service may be merged with this one). Another feature's timer, such as
  /// the rest timer, never matches.
  bool sameRunAs(TimerRun other) =>
      other.startedAtMs == run.startedAtMs &&
      other.mode == run.mode &&
      other.steps.length == run.steps.length;

  /// Laps with their split (time since the previous lap), oldest first.
  List<({int number, int splitMs, int cumulativeMs})> get lapRows {
    final List<({int number, int splitMs, int cumulativeMs})> rows =
        <({int number, int splitMs, int cumulativeMs})>[];
    int prev = 0;
    for (int i = 0; i < laps.length; i++) {
      rows.add((
        number: i + 1,
        splitMs: math.max(0, laps[i] - prev),
        cumulativeMs: laps[i],
      ));
      prev = laps[i];
    }
    return rows;
  }
}
