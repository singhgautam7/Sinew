import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/timer_preset.dart';
import '../ids.dart';
import '../user/user_db.dart';
import 'payload.dart';

/// Saved timers. The sequence and cues are a JSON payload; a preset that
/// cannot be read (corrupt, or from a newer build) is skipped, not fatal.
class TimerPresetRepository {
  TimerPresetRepository(this._db, {this._clock = systemClock});

  final UserDatabase _db;
  final Clock _clock;

  Stream<List<TimerPreset>> watchAll() => _ordered().watch().map(_decodeAll);

  Future<List<TimerPreset>> all() async => _decodeAll(await _ordered().get());

  Future<TimerPreset?> byId(String id) async {
    final TimerPresetRow? row = await (_db.select(
      _db.timerPresets,
    )..where(($TimerPresetsTable t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _decode(row);
  }

  /// True when a row with [id] exists, readable or not. [byId] returns null
  /// for both an absent preset and one written by a newer build; the built-in
  /// seed must tell them apart so it never overwrites the second.
  Future<bool> exists(String id) async =>
      await (_db.select(
        _db.timerPresets,
      )..where(($TimerPresetsTable t) => t.id.equals(id))).getSingleOrNull() !=
      null;

  Future<void> save(TimerPreset preset) {
    final TimerPreset p = preset.copyWith(
      schemaVersion: TimerPreset.currentSchemaVersion,
      updatedAt: _clock(),
    );
    return _db
        .into(_db.timerPresets)
        .insertOnConflictUpdate(
          TimerPresetsCompanion.insert(
            id: p.id,
            name: p.name,
            mode: p.mode,
            payload: jsonEncode(p.toJson()),
            position: Value<int>(p.position),
            builtIn: Value<bool>(p.builtIn),
            updatedAt: p.updatedAt,
          ),
        );
  }

  Future<void> delete(String id) => (_db.delete(
    _db.timerPresets,
  )..where(($TimerPresetsTable t) => t.id.equals(id))).go();

  SimpleSelectStatement<$TimerPresetsTable, TimerPresetRow> _ordered() =>
      _db.select(_db.timerPresets)
        ..orderBy(<OrderClauseGenerator<$TimerPresetsTable>>[
          ($TimerPresetsTable t) => OrderingTerm.asc(t.position),
          ($TimerPresetsTable t) => OrderingTerm.asc(t.name),
        ]);

  static List<TimerPreset> _decodeAll(List<TimerPresetRow> rows) =>
      <TimerPreset>[
        for (final TimerPresetRow r in rows)
          if (_decode(r) case final TimerPreset p) p,
      ];

  static TimerPreset? _decode(TimerPresetRow row) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(row.payload) as Map<String, dynamic>;
      if (payloadVersion(json) > TimerPreset.currentSchemaVersion) return null;
      return TimerPreset.fromJson(json);
    } on Object {
      return null;
    }
  }
}
