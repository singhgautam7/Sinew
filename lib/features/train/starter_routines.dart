import '../../core/db/ids.dart';
import '../../core/models/training.dart';

/// One exercise of a starter routine: a library id with sets and reps.
class StarterItem {
  const StarterItem(this.exerciseId, this.sets, this.reps);

  final String exerciseId;
  final int sets;
  final int reps;
}

/// A ready-made routine offered on an empty Train tab. Every id is a
/// library exercise (a test checks them against the bundled library), so a
/// starter never points at nothing. Weights are left for the user: the first
/// session fills them in as it goes.
class StarterRoutine {
  const StarterRoutine(this.name, this.blurb, this.items);

  final String name;

  /// One line for the picker.
  final String blurb;
  final List<StarterItem> items;

  /// A new saved [Routine] (fresh ids) at [position].
  Routine build(DateTime now, int position) => Routine(
    id: newId(),
    name: name,
    position: position,
    createdAt: now,
    updatedAt: now,
    items: <RoutineItem>[
      for (int i = 0; i < items.length; i++)
        RoutineItem(
          id: newId(),
          exerciseId: items[i].exerciseId,
          position: i,
          targetSets: items[i].sets,
          targetReps: items[i].reps,
        ),
    ],
  );
}

const List<StarterRoutine> kStarterRoutines = <StarterRoutine>[
  StarterRoutine(
    'Full body A',
    'Squat, press, row and hinge. Twice a week is plenty.',
    <StarterItem>[
      StarterItem('barbell-squat', 3, 8),
      StarterItem('barbell-bench-press', 3, 8),
      StarterItem('barbell-bent-over-row', 3, 8),
      StarterItem('dumbbell-shoulder-press', 3, 10),
      StarterItem('barbell-romanian-deadlift', 3, 10),
    ],
  ),
  StarterRoutine('Push', 'Chest, shoulders and triceps.', <StarterItem>[
    StarterItem('barbell-bench-press', 4, 6),
    StarterItem('barbell-incline-bench-press', 3, 8),
    StarterItem('dumbbell-shoulder-press', 3, 10),
    StarterItem('dumbbell-lateral-raise', 3, 12),
    StarterItem('cable-triceps-pushdown-v-bar', 3, 12),
  ]),
  StarterRoutine('Pull', 'Back and biceps.', <StarterItem>[
    StarterItem('barbell-deadlift', 3, 5),
    StarterItem('pull-up', 4, 8),
    StarterItem('barbell-bent-over-row', 3, 8),
    StarterItem('face-pull', 3, 15),
    StarterItem('barbell-curl', 3, 10),
  ]),
  StarterRoutine('Legs', 'Quads, hamstrings, glutes and calves.', <StarterItem>[
    StarterItem('barbell-squat', 4, 6),
    StarterItem('barbell-romanian-deadlift', 3, 8),
    StarterItem('leg-press', 3, 10),
    StarterItem('lever-lying-leg-curl', 3, 12),
    StarterItem('barbell-standing-calf-raise', 4, 12),
  ]),
];
