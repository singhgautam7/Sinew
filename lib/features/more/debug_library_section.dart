import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/library/library_installer.dart';
import '../../core/db/repositories/exercise_repository.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';

/// What the debug section shows about the installed library.
class LibraryStatus {
  const LibraryStatus({
    required this.version,
    required this.total,
    required this.byCategory,
    required this.flows,
  });

  final String? version;
  final int total;
  final Map<String, int> byCategory;
  final int flows;
}

final FutureProvider<LibraryStatus> _libraryStatusProvider =
    FutureProvider.autoDispose<LibraryStatus>((Ref ref) async {
      final LibraryRepository repo = await ref.watch(
        libraryRepositoryProvider.future,
      );
      return LibraryStatus(
        version: await repo.libraryVersion(),
        total: await repo.count(),
        byCategory: await repo.categoryCounts(),
        flows: (await repo.flows()).length,
      );
    });

/// The library block of the debug screen: version, total and the count per
/// category. Wired into `DebugScreen` separately.
class DebugLibrarySection extends ConsumerWidget {
  const DebugLibrarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LibraryStatus> status = ref.watch(_libraryStatusProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.lg,
            Space.lg,
            Space.lg,
            Space.xs,
          ),
          child: Text(
            'Exercise library',
            style: context.text.titleSmall,
            semanticsLabel: 'Exercise library',
          ),
        ),
        switch (status) {
          AsyncValue<LibraryStatus>(:final Object error) when status.hasError =>
            _Row(
              label: 'Library',
              value: error is LibraryAssetMissing
                  ? 'Not bundled'
                  : 'Could not open',
            ),
          AsyncData<LibraryStatus>(:final LibraryStatus value) => Column(
            children: <Widget>[
              _Row(label: 'Version', value: value.version ?? 'unknown'),
              _Row(label: 'Exercises', value: '${value.total}'),
              _Row(label: 'Flows', value: '${value.flows}'),
              for (final MapEntry<String, int> e in value.byCategory.entries)
                _Row(label: _title(e.key), value: '${e.value}', indent: true),
            ],
          ),
          _ => const _Row(label: 'Library', value: 'Opening'),
        },
      ],
    );
  }

  static String _title(String key) =>
      key.isEmpty ? key : '${key[0].toUpperCase()}${key.substring(1)}';
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.indent = false});

  final String label;
  final String value;
  final bool indent;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Semantics(
        label: '$label $value',
        excludeSemantics: true,
        child: Padding(
          padding: EdgeInsets.only(
            left: Space.lg + (indent ? Space.lg : 0),
            right: Space.lg,
          ),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label, style: context.text.bodyMedium)),
              const SizedBox(width: Space.md),
              Text(value, style: context.text.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
