import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../core/models/profile.dart';
import '../../core/settings/app_settings.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/units/units.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_form.dart';
import '../../core/widgets/sinew_states.dart';
import 'profile_form.dart';

/// Sex, birth year, height, activity and BMI cut-offs. Every field is
/// optional; a stat that needs one says so instead of guessing. Saved as you
/// type.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Profile> profile = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: const SinewAppBar(
        title: 'Profile',
        subtitle: 'Only used for formulas on this phone',
        showBack: true,
      ),
      body: profile.when(
        loading: () => const Delayed(child: SinewLoader()),
        error: (Object e, StackTrace st) => const SinewEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not load your profile',
          description: 'Your data is safe. Go back and try again.',
        ),
        // The form keeps its own state after the first load: a save must not
        // rebuild the text fields under the cursor.
        data: (Profile p) => _ProfileForm(initial: p),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.initial});

  final Profile initial;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final TextEditingController _name = TextEditingController(
    text: ref.read(settingsProvider).userName,
  );
  late final TextEditingController _year = TextEditingController(
    text: widget.initial.birthYear?.toString() ?? '',
  );
  late final TextEditingController _height = TextEditingController(
    text: widget.initial.heightCm == null
        ? ''
        : Units.trim(
            Units.fromCm(widget.initial.heightCm!, widget.initial.lengthUnit),
            maxDecimals: 1,
          ),
  );
  late Profile _p = widget.initial;

  static const double _minHeightCm = 50;
  static const double _maxHeightCm = 272;

  @override
  void dispose() {
    _name.dispose();
    _year.dispose();
    _height.dispose();
    super.dispose();
  }

  int get _thisYear => DateTime.now().year;

  String? get _yearError =>
      _year.text.trim().isNotEmpty &&
          parseBirthYear(_year.text, thisYear: _thisYear) == null
      ? 'Enter a year like 1994.'
      : null;

  String? get _heightError {
    if (_height.text.trim().isEmpty) return null;
    final double? v = parseNumber(_height.text);
    if (v == null) return 'Check this height.';
    final double cm = Units.toCm(v, _p.lengthUnit);
    return cm < _minHeightCm || cm > _maxHeightCm ? 'Check this height.' : null;
  }

  Future<void> _save(Profile Function(Profile) change) async {
    _p = change(_p);
    await updateProfile(ref, change);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = context.text;
    final ColorScheme cs = context.cs;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.xs,
        Space.screen,
        Space.bottomSafe,
      ),
      children: <Widget>[
        SinewTextField(
          key: const ValueKey<String>('profile-name'),
          textInputAction: TextInputAction.next,
          label: 'Name',
          optional: true,
          controller: _name,
          hint: 'For the greeting on Today',
          textCapitalization: TextCapitalization.words,
          onChanged: (String v) =>
              ref.read(settingsProvider.notifier).setUserName(v),
        ),
        const SizedBox(height: Space.xl),
        const SinewFieldLabel('Sex', optional: true),
        const SizedBox(height: Space.sm),
        SexChooser(
          value: _p.sex,
          onChanged: (Sex? s) {
            setState(() {});
            _save((Profile p) => p.copyWith(sex: s));
          },
        ),
        const SizedBox(height: Space.xs),
        Text(
          'Only used for estimates (resting calories, body fat) and the '
          'silhouette base. Leave it blank if you prefer.',
          style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: Space.xl),
        SinewTextField.number(
          key: const ValueKey<String>('profile-year'),
          textInputAction: TextInputAction.next,
          label: 'Birth year',
          optional: true,
          decimal: false,
          controller: _year,
          hint: '1994',
          helperText: 'For resting calories.',
          errorText: _yearError,
          onChanged: (String v) {
            setState(() {});
            if (v.trim().isEmpty) {
              _save((Profile p) => p.copyWith(birthYear: null));
            } else {
              final int? y = parseBirthYear(v, thisYear: _thisYear);
              if (y != null) _save((Profile p) => p.copyWith(birthYear: y));
            }
          },
        ),
        const SizedBox(height: Space.lg),
        SinewTextField.number(
          key: const ValueKey<String>('profile-height'),
          textInputAction: TextInputAction.done,
          label: 'Height',
          optional: true,
          controller: _height,
          suffixText: Units.lengthLabel(_p.lengthUnit),
          helperText: 'For BMI and proportions.',
          errorText: _heightError,
          onChanged: (String v) {
            setState(() {});
            if (v.trim().isEmpty) {
              _save((Profile p) => p.copyWith(heightCm: null));
            } else if (_heightError == null) {
              final double cm = Units.toCm(parseNumber(v)!, _p.lengthUnit);
              _save((Profile p) => p.copyWith(heightCm: cm));
            }
          },
        ),
        const SizedBox(height: Space.xl),
        const SinewFieldLabel('Activity level'),
        const SizedBox(height: Space.sm),
        ActivityChooser(
          value: _p.activityLevel,
          onChanged: (ActivityLevel a) {
            setState(() {});
            _save((Profile p) => p.copyWith(activityLevel: a));
          },
        ),
        const SizedBox(height: Space.xs),
        Text(
          'For maintenance calories.',
          style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: Space.xl),
        const SinewFieldLabel('BMI cut-offs'),
        const SizedBox(height: Space.sm),
        CutoffsChooser(
          value: _p.bmiCutoffs,
          onChanged: (BmiCutoffs c) {
            setState(() {});
            _save((Profile p) => p.copyWith(bmiCutoffs: c));
          },
        ),
        const SizedBox(height: Space.xs),
        Text(
          'WHO is the standard. The Asian cut-offs flag risk at a lower BMI.',
          style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: Space.xl),
        Text(
          'Leave anything blank. Stats that need it will say so instead of '
          'guessing.',
          style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
