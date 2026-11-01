import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/models/measurement.dart';
import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/domain/field_row.dart';
import '../../core/widgets/domain/silhouette_view.dart';
import '../../core/widgets/sinew_bottom_sheet.dart';
import 'body_format.dart';
import 'body_model.dart';
import 'body_providers.dart';

/// The sheet a tap on a silhouette level opens: that region's field (or both
/// sides), its latest value and change, and a way to its entries or to add a
/// new one.
Future<void> showBodyRegionSheet(
  BuildContext context, {
  required BodyAnchor anchor,
  required BodyOverview overview,
}) {
  final List<MeasurementField> fields = <MeasurementField>[
    for (final MeasurementField f in overview.liveFields)
      if (f.bodyAnchor == anchor && f.unitType == MeasurementUnitType.length) f,
  ];
  return showSinewBottomSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) => SinewBottomSheet(
      title: bodyAnchorLabel(anchor),
      child: _RegionBody(
        fields: fields,
        overview: overview,
        onGo: (String route) {
          Navigator.of(sheetContext, rootNavigator: true).pop();
          context.push(route);
        },
      ),
    ),
  );
}

class _RegionBody extends StatelessWidget {
  const _RegionBody({
    required this.fields,
    required this.overview,
    required this.onGo,
  });

  final List<MeasurementField> fields;
  final BodyOverview overview;
  final ValueChanged<String> onGo;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = context.text;
    final ColorScheme cs = context.cs;
    if (fields.isEmpty) {
      return Text(
        'No measurement field is drawn at this level. You can place a field '
        'here from Measurement fields.',
        style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final MeasurementField f in fields) ...<Widget>[
          _RegionField(field: f, overview: overview, onGo: onGo),
          if (f != fields.last) const SizedBox(height: Space.xl),
        ],
      ],
    );
  }
}

class _RegionField extends StatelessWidget {
  const _RegionField({
    required this.field,
    required this.overview,
    required this.onGo,
  });

  final MeasurementField field;
  final BodyOverview overview;
  final ValueChanged<String> onGo;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = context.text;
    final ColorScheme cs = context.cs;
    final FieldUnit unit = fieldUnitFor(field, overview.profile);
    final LatestValue? v = overview.latest[field.id];
    final double? d = v?.delta;
    final String detail = v == null
        ? 'No entries yet'
        : <String>[
            bodyDateLabel(v.date, overview.now),
            if (d != null && v.previous != null)
              '${signedDisplayDelta(unit, d)} since '
                  '${bodyDateLabel(v.previous!.date, overview.now)}',
          ].join('  ·  ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(field.name, style: tt.titleMedium),
        const SizedBox(height: Space.xs),
        Text(
          v == null ? 'No value' : formatFieldValue(unit, v.value),
          style: tt.headlineMedium,
        ),
        Text(
          detail,
          style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: Space.lg),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.sm,
          children: <Widget>[
            if (v != null)
              AppButton(
                label: 'See all entries',
                type: AppButtonType.outline,
                onPressed: () => onGo(Routes.progress(field.id)),
              ),
            AppButton(
              label: 'Add ${field.name.toLowerCase()}',
              type: AppButtonType.primary,
              icon: Icons.add_rounded,
              onPressed: () => onGo('${Routes.newEntry}?field=${field.id}'),
            ),
          ],
        ),
      ],
    );
  }
}
