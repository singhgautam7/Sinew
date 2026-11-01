import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../core/models/profile.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sinew_option_tile.dart';
import '../../core/widgets/sinew_segmented_control.dart';

// Pieces shared by the first-run Quick profile and More > Profile / Units.

/// Reads the saved profile, applies [change] and saves it.
Future<void> updateProfile(
  WidgetRef ref,
  Profile Function(Profile current) change,
) async {
  final repo = ref.read(profileRepositoryProvider);
  final Profile current = await repo.get();
  await repo.save(change(current));
}

/// Parses a typed number; null for empty or malformed text.
double? parseNumber(String text) {
  final String t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

/// A four digit birth year in a believable range, else null.
int? parseBirthYear(String text, {required int thisYear}) {
  final int? y = int.tryParse(text.trim());
  if (y == null) return null;
  if (y < MoreSpec.birthYearMin || y > thisYear) return null;
  return y;
}

String sexLabel(Sex? s) => switch (s) {
  Sex.female => 'Female',
  Sex.male => 'Male',
  null => 'Not set',
};

String activityTitle(ActivityLevel a) => switch (a) {
  ActivityLevel.sedentary => 'Mostly sitting',
  ActivityLevel.light => 'Lightly active',
  ActivityLevel.moderate => 'Active',
  ActivityLevel.veryActive => 'Very active',
  ActivityLevel.extraActive => 'Extremely active',
};

String activityHint(ActivityLevel a) => switch (a) {
  ActivityLevel.sedentary => 'Desk job, little walking',
  ActivityLevel.light => 'Light exercise 1 to 3 days a week',
  ActivityLevel.moderate => 'Training 3 to 5 days a week',
  ActivityLevel.veryActive => 'Hard training 6 to 7 days a week',
  ActivityLevel.extraActive => 'Hard training and a physical job',
};

String cutoffsLabel(BmiCutoffs c) => switch (c) {
  BmiCutoffs.who => 'WHO',
  BmiCutoffs.asian => 'Asian',
};

/// Female, Male or neither. Sex only feeds estimates (BMR, body fat) and the
/// silhouette base; it is never needed.
class SexChooser extends StatelessWidget {
  const SexChooser({super.key, required this.value, required this.onChanged});

  final Sex? value;
  final ValueChanged<Sex?> onChanged;

  @override
  Widget build(BuildContext context) {
    // A segmented control cannot hold null, so "Not now" is its own value.
    return SinewSegmentedControl<int>(
      values: const <int>[0, 1, 2],
      labels: const <String>['Female', 'Male', 'Not now'],
      selected: switch (value) {
        Sex.female => 0,
        Sex.male => 1,
        null => 2,
      },
      onSelected: (int i) => onChanged(switch (i) {
        0 => Sex.female,
        1 => Sex.male,
        _ => null,
      }),
    );
  }
}

/// The activity levels as single-choice tiles.
class ActivityChooser extends StatelessWidget {
  const ActivityChooser({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ActivityLevel value;
  final ValueChanged<ActivityLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final ActivityLevel a in ActivityLevel.values) ...<Widget>[
          if (a != ActivityLevel.values.first) const SizedBox(height: Space.sm),
          SinewOptionTile(
            title: activityTitle(a),
            subtitle: activityHint(a),
            selected: a == value,
            onTap: () => onChanged(a),
          ),
        ],
      ],
    );
  }
}

/// WHO or Asian BMI cut-offs.
class CutoffsChooser extends StatelessWidget {
  const CutoffsChooser({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final BmiCutoffs value;
  final ValueChanged<BmiCutoffs> onChanged;

  @override
  Widget build(BuildContext context) {
    return SinewSegmentedControl<BmiCutoffs>(
      values: BmiCutoffs.values,
      labels: <String>[
        for (final BmiCutoffs c in BmiCutoffs.values) cutoffsLabel(c),
      ],
      selected: value,
      onSelected: onChanged,
    );
  }
}

/// The three unit choices as segmented controls with a caps label each.
class UnitChoosers extends StatelessWidget {
  const UnitChoosers({
    super.key,
    required this.weight,
    required this.length,
    required this.distance,
    required this.onWeight,
    required this.onLength,
    required this.onDistance,
  });

  final WeightUnit weight;
  final LengthUnit length;
  final DistanceUnit distance;
  final ValueChanged<WeightUnit> onWeight;
  final ValueChanged<LengthUnit> onLength;
  final ValueChanged<DistanceUnit> onDistance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SinewSegmentedControl<WeightUnit>(
          values: WeightUnit.values,
          labels: const <String>['kg', 'lb'],
          selected: weight,
          onSelected: onWeight,
        ),
        const SizedBox(height: Space.sm),
        SinewSegmentedControl<LengthUnit>(
          values: LengthUnit.values,
          labels: const <String>['cm', 'in'],
          selected: length,
          onSelected: onLength,
        ),
        const SizedBox(height: Space.sm),
        SinewSegmentedControl<DistanceUnit>(
          values: DistanceUnit.values,
          labels: const <String>['km', 'mi'],
          selected: distance,
          onSelected: onDistance,
        ),
      ],
    );
  }
}
