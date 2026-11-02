import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/ids.dart';
import '../../core/models/enums.dart';
import '../../core/models/measurement.dart';
import '../../core/models/profile.dart';
import '../../core/providers.dart';
import '../../core/routing/router.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/units/units.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/sinew_form.dart';
import '../more/profile_form.dart';

/// Optional, skippable: the few numbers that unlock BMI, resting calories and
/// the silhouette. Nothing is required and nothing leaves the phone.
class QuickProfileScreen extends ConsumerStatefulWidget {
  const QuickProfileScreen({super.key});

  @override
  ConsumerState<QuickProfileScreen> createState() => _QuickProfileScreenState();
}

class _QuickProfileScreenState extends ConsumerState<QuickProfileScreen> {
  final TextEditingController _year = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _weight = TextEditingController();

  WeightUnit _weightUnit = WeightUnit.kg;
  LengthUnit _lengthUnit = LengthUnit.cm;
  DistanceUnit _distanceUnit = DistanceUnit.km;
  Sex? _sex;
  ActivityLevel _activity = ActivityLevel.moderate;
  BmiCutoffs _cutoffs = BmiCutoffs.who;
  bool _saving = false;

  @override
  void dispose() {
    _year.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  int get _thisYear => DateTime.now().year;

  // Believable human ranges, in the stored (metric) unit.
  static const double _minHeightCm = 50;
  static const double _maxHeightCm = 272;
  static const double _minWeightKg = 20;
  static const double _maxWeightKg = 500;

  double? get _heightCm {
    final double? v = parseNumber(_height.text);
    return v == null ? null : Units.toCm(v, _lengthUnit);
  }

  double? get _weightKg {
    final double? v = parseNumber(_weight.text);
    return v == null ? null : Units.toKg(v, _weightUnit);
  }

  String? get _yearError =>
      _year.text.trim().isNotEmpty &&
          parseBirthYear(_year.text, thisYear: _thisYear) == null
      ? 'Enter a year like 1994.'
      : null;

  String? get _heightError {
    final double? cm = _heightCm;
    if (_height.text.trim().isEmpty) return null;
    return cm == null || cm < _minHeightCm || cm > _maxHeightCm
        ? 'Check this height.'
        : null;
  }

  String? get _weightError {
    final double? kg = _weightKg;
    if (_weight.text.trim().isEmpty) return null;
    return kg == null || kg < _minWeightKg || kg > _maxWeightKg
        ? 'Check this weight.'
        : null;
  }

  bool get _valid =>
      _yearError == null && _heightError == null && _weightError == null;

  void _changeWeightUnit(WeightUnit next) {
    final double? kg = _weightKg;
    setState(() {
      _weightUnit = next;
      if (kg != null) {
        _weight.text = Units.trim(Units.fromKg(kg, next), maxDecimals: 1);
      }
    });
  }

  void _changeLengthUnit(LengthUnit next) {
    final double? cm = _heightCm;
    setState(() {
      _lengthUnit = next;
      if (cm != null) {
        _height.text = Units.trim(Units.fromCm(cm, next), maxDecimals: 1);
      }
    });
  }

  Future<void> _finish({required bool save}) async {
    if (_saving) return;
    setState(() => _saving = true);
    if (save) {
      final DateTime now = systemClock();
      await ref
          .read(profileRepositoryProvider)
          .save(
            Profile(
              sex: _sex,
              birthYear: parseBirthYear(_year.text, thisYear: _thisYear),
              heightCm: _heightCm,
              activityLevel: _activity,
              weightUnit: _weightUnit,
              lengthUnit: _lengthUnit,
              distanceUnit: _distanceUnit,
              bmiCutoffs: _cutoffs,
              updatedAt: now,
            ),
          );
      final double? kg = _weightKg;
      if (kg != null) {
        await ref
            .read(measurementRepositoryProvider)
            .saveEntry(
              MeasurementEntry(
                id: newId(),
                date: now,
                values: <String, double>{'weight': kg},
                updatedAt: now,
              ),
            );
      }
    }
    await ref.read(settingsProvider.notifier).setOnboarded(value: true);
    if (mounted) context.go(Routes.today);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = context.text;
    final ColorScheme cs = context.cs;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.sm,
                Space.screen,
                0,
              ),
              child: Row(
                children: <Widget>[
                  AppIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Skip all',
                    height: Sizes.buttonSmall,
                    onPressed: _saving ? null : () => _finish(save: false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  Space.sm,
                  Space.screen,
                  Space.xl,
                ),
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text('About you', style: tt.headlineMedium),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    'Every field is optional and only used on this phone. '
                    'Change it any time in More, then Profile.',
                    style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: Space.xl),
                  const SinewFieldLabel('Units'),
                  const SizedBox(height: Space.sm),
                  UnitChoosers(
                    weight: _weightUnit,
                    length: _lengthUnit,
                    distance: _distanceUnit,
                    onWeight: _changeWeightUnit,
                    onLength: _changeLengthUnit,
                    onDistance: (DistanceUnit u) =>
                        setState(() => _distanceUnit = u),
                  ),
                  const SizedBox(height: Space.xl),
                  const SinewFieldLabel('Sex', optional: true),
                  const SizedBox(height: Space.sm),
                  SexChooser(
                    value: _sex,
                    onChanged: (Sex? s) => setState(() => _sex = s),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    'Used only by formulas (BMR, body fat) and the silhouette '
                    'base.',
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: Space.xl),
                  SinewTextField.number(
                    key: const ValueKey<String>('onboarding-year'),
                    textInputAction: TextInputAction.next,
                    label: 'Birth year',
                    optional: true,
                    decimal: false,
                    controller: _year,
                    hint: '1994',
                    helperText: 'Unlocks resting calories.',
                    errorText: _yearError,
                    onChanged: (String _) => setState(() {}),
                  ),
                  const SizedBox(height: Space.lg),
                  SinewTextField.number(
                    key: const ValueKey<String>('onboarding-height'),
                    textInputAction: TextInputAction.next,
                    label: 'Height',
                    optional: true,
                    controller: _height,
                    suffixText: Units.lengthLabel(_lengthUnit),
                    helperText: 'Add height to see BMI.',
                    errorText: _heightError,
                    onChanged: (String _) => setState(() {}),
                  ),
                  const SizedBox(height: Space.lg),
                  SinewTextField.number(
                    key: const ValueKey<String>('onboarding-weight'),
                    textInputAction: TextInputAction.done,
                    label: 'Current weight',
                    optional: true,
                    controller: _weight,
                    suffixText: Units.weightLabel(_weightUnit),
                    helperText: 'Saved as your first body entry.',
                    errorText: _weightError,
                    onChanged: (String _) => setState(() {}),
                  ),
                  const SizedBox(height: Space.xl),
                  const SinewFieldLabel('Activity level'),
                  const SizedBox(height: Space.sm),
                  ActivityChooser(
                    value: _activity,
                    onChanged: (ActivityLevel a) =>
                        setState(() => _activity = a),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    'Unlocks maintenance calories.',
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: Space.xl),
                  const SinewFieldLabel('BMI cut-offs'),
                  const SizedBox(height: Space.sm),
                  CutoffsChooser(
                    value: _cutoffs,
                    onChanged: (BmiCutoffs c) => setState(() => _cutoffs = c),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.sm,
                Space.screen,
                Space.lg,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: AppButton(
                      label: 'Skip',
                      type: AppButtonType.outline,
                      fullWidth: true,
                      onPressed: _saving ? null : () => _finish(save: false),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: AppButton(
                      label: 'Continue',
                      type: AppButtonType.primary,
                      fullWidth: true,
                      isLoading: _saving,
                      onPressed: _valid && !_saving
                          ? () => _finish(save: true)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
