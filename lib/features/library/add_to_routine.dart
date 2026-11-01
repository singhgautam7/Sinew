import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/ids.dart';
import '../../core/db/repositories/routine_repository.dart';
import '../../core/models/exercise.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_snackbar.dart';
import '../../core/widgets/sinew_states.dart';

/// Sets per added routine item, as the routine editor starts a new one.
const int kAddedItemSets = 3;

/// What the sheet resolved to: an existing routine, or "make a new one".
typedef RoutinePick = ({String? routineId, bool createNew});

/// Routines for the picker sheet (without items), live.
final StreamProvider<List<Routine>> libraryRoutinesProvider =
    StreamProvider.autoDispose<List<Routine>>(
      (Ref ref) => ref.watch(routineRepositoryProvider).watchAll(),
    );

/// Appends [exercise] to [routine] with the exercise's defaults (rest or hold
/// from the exercise, [kAddedItemSets] sets) and saves it. Returns the saved
/// routine, or null when it no longer exists.
Future<Routine?> appendExerciseToRoutine(
  RoutineRepository repo,
  String routineId,
  Exercise exercise,
) async {
  final Routine? routine = await repo.byId(routineId);
  if (routine == null) return null;
  final RoutineItem item = RoutineItem(
    id: newId(),
    exerciseId: exercise.id,
    position: routine.items.length,
    targetSets: kAddedItemSets,
    targetDurationSec: exercise.defaultHoldSec,
    restSec: exercise.defaultRestSec,
  );
  return repo.save(
    routine.copyWith(items: <RoutineItem>[...routine.items, item]),
  );
}

/// The "Add to routine" flow: pick a routine in a sheet (or start a new one),
/// append the exercise, confirm with a snackbar that opens the routine.
Future<void> addExerciseToRoutineFlow(
  BuildContext context,
  WidgetRef ref,
  Exercise exercise,
) async {
  final RoutinePick? pick = await showSinewBottomSheet<RoutinePick>(
    context: context,
    builder: (BuildContext _) => AddToRoutineSheet(exercise: exercise),
  );
  if (pick == null || !context.mounted) return;
  if (pick.createNew) {
    unawaited(context.push(Routes.newRoutine));
    return;
  }
  final String id = pick.routineId!;
  final Routine? saved = await appendExerciseToRoutine(
    ref.read(routineRepositoryProvider),
    id,
    exercise,
  );
  if (!context.mounted) return;
  if (saved == null) {
    showSinewSnackBar(context, 'That routine is gone', isError: true);
    return;
  }
  showSinewSnackBar(
    context,
    'Added to ${saved.name}',
    actionLabel: 'Open',
    onAction: () {
      if (context.mounted) context.push(Routes.routine(saved.id));
    },
  );
}

/// Lists the person's routines plus "New routine".
class AddToRoutineSheet extends ConsumerWidget {
  const AddToRoutineSheet({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Routine>> routines = ref.watch(
      libraryRoutinesProvider,
    );
    final ColorScheme cs = context.cs;
    return SinewBottomSheet(
      title: 'Add to routine',
      description: exercise.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          routines.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: Space.lg),
              child: SinewSkeletonCard(lines: 2),
            ),
            error: (Object e, StackTrace _) => const Padding(
              padding: EdgeInsets.symmetric(vertical: Space.lg),
              child: Text('Could not read your routines.'),
            ),
            data: (List<Routine> list) => list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.md),
                    child: Text(
                      'You have no routines yet.',
                      style: context.text.bodyMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                : SinewGroup(
                    children: <Widget>[
                      for (final Routine r in list)
                        SinewListRow(
                          title: r.name,
                          leading: Icon(
                            Icons.view_list_rounded,
                            color: cs.primary,
                          ),
                          onTap: () => Navigator.of(context).pop<RoutinePick>((
                            routineId: r.id,
                            createNew: false,
                          )),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: Space.md),
          AppButton(
            label: 'New routine',
            type: AppButtonType.outline,
            icon: Icons.add_rounded,
            fullWidth: true,
            onPressed: () =>
                Navigator.of(context)
                    .pop<RoutinePick>((routineId: null, createNew: true)),
          ),
        ],
      ),
    );
  }
}
