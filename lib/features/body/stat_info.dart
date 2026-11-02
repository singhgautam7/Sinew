import 'package:flutter/material.dart';

import '../../core/models/enums.dart';
import '../../core/units/units.dart';
import '../../core/widgets/configs.dart';
import '../../engines/body_stats/body_stats.dart';
import 'body_providers.dart';

/// The body stats that have an info sheet.
enum BodyStatKind {
  bmi,
  healthyWeight,
  bmr,
  tdee,
  bodyFat,
  waistToHeight,
  waistToHip,
  leanMass,
}

String _w(double kg, BodyOverview o) =>
    Units.formatWeight(kg, o.profile.weightUnit);

String _l(double cm, BodyOverview o) =>
    Units.formatLength(cm, o.profile.lengthUnit);

/// "weight 78.4 kg" when the input exists, "weight (not set)" otherwise.
SinewInfoExampleRow _row(String label, String? value) =>
    SinewInfoExampleRow(label, value ?? 'Not set');

/// The "About ..." sheet for one stat: what it means, the formula in words,
/// the inputs this person's number used, the category boundaries and the
/// honest limits (estimates are called estimates).
SinewInfoConfig statInfoConfig(BodyStatKind kind, BodyOverview o) {
  final BodyStatsInput i = o.input;
  final bool asian = o.profile.bmiCutoffs == BmiCutoffs.asian;
  final String cutoffName = asian ? 'Asian' : 'WHO';
  final String ageText = i.age == null ? 'Not set' : '${i.age} years';
  final String sexText = switch (i.sex) {
    Sex.male => 'Male',
    Sex.female => 'Female',
    null => 'Not set (an average is used)',
  };
  final String? weight = i.weightKg == null ? null : _w(i.weightKg!, o);
  final String? height = i.heightCm == null ? null : _l(i.heightCm!, o);
  final String? waist = i.waistCm == null ? null : _l(i.waistCm!, o);
  final String? neck = i.neckCm == null ? null : _l(i.neckCm!, o);
  final String? hips = i.hipsCm == null ? null : _l(i.hipsCm!, o);

  switch (kind) {
    case BodyStatKind.bmi:
      return SinewInfoConfig(
        title: 'About BMI',
        description:
            'Body mass index compares weight to height. It is a quick '
            'population measure, not a verdict on one body.',
        items: <SinewInfoItem>[
          SinewInfoItem(
            icon: Icons.rule_rounded,
            title: '$cutoffName cut-offs',
            description: asian
                ? 'Underweight below 18.5, healthy 18.5 to 22.9, overweight '
                      '23 to 24.9, obese 25 and over.'
                : 'Underweight below 18.5, healthy 18.5 to 24.9, overweight '
                      '25 to 29.9, obese 30 and over.',
          ),
          SinewInfoItem(
            icon: Icons.swap_horiz_rounded,
            title: asian ? 'Switch to WHO' : 'Switch to Asian',
            description:
                'Change the cut-offs under More, Profile. The number does '
                'not change, only the category.',
          ),
        ],
        exampleBlock: SinewInfoExampleBlock(
          label: 'Formula',
          sentence: 'weight (kg) divided by height (m) squared',
          rows: <SinewInfoExampleRow>[
            _row('Weight', weight),
            _row('Height', height),
            if (i.weightKg != null && i.heightCm != null)
              SinewInfoExampleRow(
                'BMI',
                BodyStats.bmiOf(i.weightKg!, i.heightCm!).toStringAsFixed(1),
                highlight: true,
              ),
          ],
          after:
              'BMI does not account for muscle, bone or where fat sits. '
              'Strong, muscular people often read as overweight. It is not '
              'designed for children or pregnancy. Waist to height is a '
              'useful second view.',
        ),
      );
    case BodyStatKind.healthyWeight:
      return SinewInfoConfig(
        title: 'About healthy weight range',
        description:
            'The weights that give a BMI in the healthy band for your '
            'height. It is a range, not a target.',
        exampleBlock: SinewInfoExampleBlock(
          label: 'Formula',
          sentence:
              'BMI 18.5 to ${asian ? '22.9' : '24.9'} ($cutoffName) times '
              'height (m) squared',
          rows: <SinewInfoExampleRow>[
            _row('Height', height),
            _row('Cut-offs', cutoffName),
          ],
          after:
              'It uses your height only, so it does not change when your '
              'weight does.',
        ),
      );
    case BodyStatKind.bmr:
      return SinewInfoConfig(
        title: 'About resting energy (BMR)',
        description:
            'The calories your body uses at complete rest. This is an '
            'estimate from the Mifflin-St Jeor equation, not a measurement.',
        exampleBlock: SinewInfoExampleBlock(
          label: 'Formula',
          sentence:
              '10 x weight (kg) + 6.25 x height (cm) - 5 x age, then '
              '+5 for men, -161 for women (-78 when sex is not set)',
          rows: <SinewInfoExampleRow>[
            _row('Weight', weight),
            _row('Height', height),
            _row('Age', ageText),
            SinewInfoExampleRow('Sex', sexText),
          ],
          after:
              'With no sex set the result is marked approximate. Real '
              'resting energy varies by several hundred calories between '
              'people of the same size.',
        ),
      );
    case BodyStatKind.tdee:
      return SinewInfoConfig(
        title: 'About maintenance calories',
        description:
            'A rough daily calorie figure that keeps your weight steady. '
            'It is an estimate: your resting energy times an activity '
            'factor.',
        items: const <SinewInfoItem>[
          SinewInfoItem(
            icon: Icons.directions_run_rounded,
            title: 'Activity factors',
            description:
                'Sedentary 1.2, light 1.375, moderate 1.55, very active '
                '1.725, extra active 1.9.',
          ),
        ],
        exampleBlock: SinewInfoExampleBlock(
          label: 'Formula',
          sentence: 'resting energy (BMR) x activity factor',
          rows: <SinewInfoExampleRow>[
            _row('Weight', weight),
            _row('Height', height),
            _row('Age', ageText),
            SinewInfoExampleRow('Sex', sexText),
            SinewInfoExampleRow(
              'Activity',
              i.activityLevel == null
                  ? 'Not set'
                  : '${i.activityLevel!.name} (x'
                        '${BodyStats.activityFactor(i.activityLevel!)})',
            ),
          ],
          after: 'Treat it as a starting point and adjust from real results.',
        ),
      );
    case BodyStatKind.bodyFat:
      return SinewInfoConfig(
        title: 'About body fat',
        description:
            'Your logged value is shown when you have one. Otherwise the '
            'figure is an estimate from tape measurements using the US Navy '
            'method.',
        items: const <SinewInfoItem>[
          SinewInfoItem(
            icon: Icons.straighten_rounded,
            title: 'US Navy method',
            description:
                'Men: waist minus neck. Women: waist plus hips minus neck. '
                'Together with height these give a body density, then body '
                'fat. Other formulas may come later.',
          ),
        ],
        exampleBlock: SinewInfoExampleBlock(
          label: 'Inputs used',
          rows: <SinewInfoExampleRow>[
            _row('Height', height),
            _row('Waist', waist),
            _row('Neck', neck),
            if (i.sex != Sex.male) _row('Hips', hips),
            SinewInfoExampleRow('Sex', sexText),
          ],
          after:
              'It is an estimate and can be off by several points, '
              'especially for very lean or very muscular bodies. A scan or '
              'caliper reading you log yourself always takes priority.',
        ),
      );
    case BodyStatKind.waistToHeight:
      return SinewInfoConfig(
        title: 'About waist to height',
        description:
            'Your waist divided by your height. Keeping it under 0.5 is a '
            'common rule of thumb, because it says more about where weight '
            'sits than BMI does.',
        exampleBlock: SinewInfoExampleBlock(
          label: 'Formula',
          sentence: 'waist divided by height, both in the same unit',
          rows: <SinewInfoExampleRow>[
            _row('Waist', waist),
            _row('Height', height),
            if (i.waistCm != null && i.heightCm != null)
              SinewInfoExampleRow(
                'Ratio',
                (i.waistCm! / i.heightCm!).toStringAsFixed(2),
                highlight: true,
              ),
          ],
          after:
              'The 0.5 marker is general guidance, not a diagnosis or a '
              'goal.',
        ),
      );
    case BodyStatKind.waistToHip:
      return SinewInfoConfig(
        title: 'About waist to hip',
        description:
            'Your waist divided by your hips. It describes how your body '
            'carries its shape, not how healthy it is.',
        exampleBlock: SinewInfoExampleBlock(
          label: 'Formula',
          sentence: 'waist divided by hips, both in the same unit',
          rows: <SinewInfoExampleRow>[
            _row('Waist', waist),
            _row('Hips', hips),
            if (i.waistCm != null && i.hipsCm != null)
              SinewInfoExampleRow(
                'Ratio',
                (i.waistCm! / i.hipsCm!).toStringAsFixed(2),
                highlight: true,
              ),
          ],
          after: 'Measure at the same spots each time for a fair trend.',
        ),
      );
    case BodyStatKind.leanMass:
      return SinewInfoConfig(
        title: 'About lean body mass',
        description:
            'Everything that is not fat: muscle, bone, organs and water. '
            'It is only as good as the body fat behind it, so it is an '
            'estimate unless you log body fat yourself.',
        exampleBlock: SinewInfoExampleBlock(
          label: 'Formula',
          sentence: 'weight x (1 - body fat / 100)',
          rows: <SinewInfoExampleRow>[
            _row('Weight', weight),
            _row('Height', height),
            _row('Waist', waist),
            _row('Neck', neck),
          ],
          after:
              'Body fat comes from your logged value, or the US Navy '
              'estimate when you have not logged one.',
        ),
      );
  }
}
