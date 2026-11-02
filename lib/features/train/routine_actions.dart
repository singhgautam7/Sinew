import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/widgets/sinew_snackbar.dart';
import 'routine_style.dart';

/// Deletes [routine] (its style too) and offers Undo, which puts both back.
///
/// The snackbar is shown on the root overlay captured before the delete, so it
/// survives the screen that asked going away (the editor pops right after).
Future<void> deleteRoutineWithUndo(
  BuildContext context,
  WidgetRef ref,
  Routine routine,
) async {
  final repo = ref.read(routineRepositoryProvider);
  final RoutineStyleStore store = ref.read(routineStyleStoreProvider);
  final RoutineStyle style = ref.read(routineStyleProvider(routine.id));
  final OverlayState? overlay = Navigator.of(
    context,
    rootNavigator: true,
  ).overlay;
  await repo.delete(routine.id);
  await store.remove(routine.id);
  if (overlay == null || !overlay.mounted) return;
  showSinewSnackBar(
    overlay.context,
    'Routine deleted',
    overlay: overlay,
    actionLabel: 'Undo',
    onAction: () async {
      await repo.save(routine);
      if (style != RoutineStyle.fallback) await store.save(routine.id, style);
    },
  );
}
