import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/measurement.dart';
import '../../core/models/profile.dart';
import '../../core/providers.dart';
import '../../engines/body_stats/body_stats.dart';
import '../../engines/silhouette/silhouette_engine.dart';
import 'body_model.dart';

/// The clock the Body screens read. Override in tests.
final Provider<DateTime> bodyNowProvider = Provider<DateTime>(
  (Ref ref) => DateTime.now(),
);

/// Every measurement field (archived ones included, filter with `archived`),
/// in position order. Live: edits in the fields manager flow through.
final StreamProvider<List<MeasurementField>> bodyFieldsProvider =
    StreamProvider.autoDispose<List<MeasurementField>>(
      (Ref ref) => ref
          .watch(measurementRepositoryProvider)
          .watchFields(includeArchived: true),
    );

/// The profile (defaults when none is saved).
final StreamProvider<Profile> bodyProfileProvider =
    StreamProvider.autoDispose<Profile>(
      (Ref ref) => ref.watch(profileRepositoryProvider).watch(),
    );

/// Every entry with its values, newest first. Invalidate after a write.
final FutureProvider<List<MeasurementEntry>> bodyEntriesProvider =
    FutureProvider.autoDispose<List<MeasurementEntry>>(
      (Ref ref) => ref.watch(measurementRepositoryProvider).entries(),
    );

/// Everything the overview draws, computed once per change of its inputs.
class BodyOverview {
  BodyOverview({
    required this.fields,
    required this.entries,
    required this.profile,
    required this.now,
  }) : latestValues = valuesAsOf(entries),
       latest = latestWithPrevious(entries) {
    input = bodyStatsInputFor(latestValues, profile, now);
    geometry = buildSilhouette(
      silhouetteInputFor(fields, latestValues, profile),
    );
  }

  final List<MeasurementField> fields;
  final List<MeasurementEntry> entries;
  final Profile profile;
  final DateTime now;
  final Map<String, DatedValue> latestValues;
  final Map<String, LatestValue> latest;
  late final BodyStatsInput input;
  late final SilhouetteGeometry geometry;

  /// Live fields in position order.
  List<MeasurementField> get liveFields => <MeasurementField>[
    for (final MeasurementField f in fields)
      if (!f.archived) f,
  ];

  bool get hasData => entries.any((MeasurementEntry e) => e.values.isNotEmpty);

  MeasurementField? fieldById(String id) {
    for (final MeasurementField f in fields) {
      if (f.id == id) return f;
    }
    return null;
  }
}

final FutureProvider<BodyOverview> bodyOverviewProvider =
    FutureProvider.autoDispose<BodyOverview>((Ref ref) async {
      final List<MeasurementField> fields = await ref.watch(
        bodyFieldsProvider.future,
      );
      final Profile profile = await ref.watch(bodyProfileProvider.future);
      final List<MeasurementEntry> entries = await ref.watch(
        bodyEntriesProvider.future,
      );
      return BodyOverview(
        fields: fields,
        entries: entries,
        profile: profile,
        now: ref.watch(bodyNowProvider),
      );
    });

/// Writes an entry and refreshes what reads entries.
Future<void> saveBodyEntry(WidgetRef ref, MeasurementEntry entry) async {
  await ref.read(measurementRepositoryProvider).saveEntry(entry);
  ref.invalidate(bodyEntriesProvider);
}

Future<void> deleteBodyEntry(WidgetRef ref, String id) async {
  await ref.read(measurementRepositoryProvider).deleteEntry(id);
  ref.invalidate(bodyEntriesProvider);
}
