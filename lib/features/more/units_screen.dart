import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../core/models/profile.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_option_tile.dart';
import '../../core/widgets/sinew_states.dart';
import 'profile_form.dart';

/// Weight, length and distance, stored on the profile. Everything Sinew
/// stores is metric; these only change what you see and type.
class UnitsScreen extends ConsumerWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Profile> profile = ref.watch(profileProvider);
    final bool monday = ref.watch(
      settingsProvider.select((AppSettings s) => s.weekStartsMonday),
    );
    return Scaffold(
      appBar: const SinewAppBar(title: 'Units', showBack: true),
      body: profile.when(
        loading: () => const Delayed(child: SinewLoader()),
        error: (Object e, StackTrace st) => const SinewEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not load your units',
          description: 'Your data is safe. Go back and try again.',
        ),
        data: (Profile p) => ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.xs,
            Space.screen,
            Space.bottomSafe,
          ),
          children: <Widget>[
            _Group<WeightUnit>(
              title: 'Weight',
              values: WeightUnit.values,
              labels: const <WeightUnit, (String, String)>{
                WeightUnit.kg: ('kg', 'Kilograms'),
                WeightUnit.lb: ('lb', 'Pounds'),
              },
              selected: p.weightUnit,
              onSelected: (WeightUnit u) =>
                  updateProfile(ref, (Profile c) => c.copyWith(weightUnit: u)),
            ),
            _Group<LengthUnit>(
              title: 'Length',
              values: LengthUnit.values,
              labels: const <LengthUnit, (String, String)>{
                LengthUnit.cm: ('cm', 'Centimetres'),
                LengthUnit.inch: ('in', 'Inches'),
              },
              selected: p.lengthUnit,
              onSelected: (LengthUnit u) =>
                  updateProfile(ref, (Profile c) => c.copyWith(lengthUnit: u)),
            ),
            _Group<DistanceUnit>(
              title: 'Distance',
              values: DistanceUnit.values,
              labels: const <DistanceUnit, (String, String)>{
                DistanceUnit.km: ('km', 'Kilometres'),
                DistanceUnit.mi: ('mi', 'Miles'),
              },
              selected: p.distanceUnit,
              onSelected: (DistanceUnit u) => updateProfile(
                ref,
                (Profile c) => c.copyWith(distanceUnit: u),
              ),
            ),
            _Group<bool>(
              title: 'Week starts',
              values: const <bool>[true, false],
              labels: const <bool, (String, String)>{
                true: ('Mon', 'Monday'),
                false: ('Sun', 'Sunday'),
              },
              selected: monday,
              onSelected: (bool m) => ref
                  .read(settingsProvider.notifier)
                  .setWeekStartsMonday(value: m),
            ),
            Text(
              'Your data is always stored in kilograms, centimetres and '
              'metres, so changing units never changes a record.',
              style: context.text.bodySmall!.copyWith(
                color: context.cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Group<T> extends StatelessWidget {
  const _Group({
    required this.title,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<T> values;
  final Map<T, (String, String)> labels;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SinewSectionHeader(title: title),
          for (final T v in values) ...<Widget>[
            if (v != values.first) const SizedBox(height: Space.sm),
            SinewOptionTile(
              tag: labels[v]!.$1,
              title: labels[v]!.$2,
              selected: v == selected,
              onTap: () => onSelected(v),
            ),
          ],
        ],
      ),
    );
  }
}
