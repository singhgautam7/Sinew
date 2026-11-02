import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/timer_preset.dart';
import '../../../engines/timer/timer_engine.dart';
import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../data/timer_cues.dart';
import '../data/timer_presets.dart';

/// Inserts the built-in presets the first time the Timer is used. Idempotent:
/// safe to watch on every visit.
final FutureProvider<void> timerPresetSeedProvider = FutureProvider<void>((
  Ref ref,
) async {
  await seedBuiltInPresets(
    presets: ref.read(timerPresetRepositoryProvider),
    state: ref.read(runtimeStateRepositoryProvider),
    now: DateTime.now().toUtc(),
    cuesFor: (TimerConfig c) =>
        seedCues(c.defaultCues, ref.read(settingsProvider)),
  );
});

/// The saved presets, after the built-ins were seeded. A plain future, not a
/// database stream: every place that changes a preset invalidates it, and
/// there is no open query to keep alive behind the tab.
final FutureProvider<List<TimerPreset>> timerPresetsProvider =
    FutureProvider<List<TimerPreset>>((Ref ref) async {
      await ref.watch(timerPresetSeedProvider.future);
      return ref.watch(timerPresetRepositoryProvider).all();
    });
