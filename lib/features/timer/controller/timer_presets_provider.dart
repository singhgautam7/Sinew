import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/timer_preset.dart';
import '../../../core/providers.dart';
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
  );
});

/// The saved presets, live, after the built-ins were seeded.
final StreamProvider<List<TimerPreset>> timerPresetsProvider =
    StreamProvider<List<TimerPreset>>((Ref ref) async* {
      await ref.watch(timerPresetSeedProvider.future);
      yield* ref.watch(timerPresetRepositoryProvider).watchAll();
    });
