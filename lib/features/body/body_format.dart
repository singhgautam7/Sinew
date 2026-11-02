import '../../core/format/date_text.dart';
import '../../core/models/enums.dart';
import '../../core/models/measurement.dart';
import '../../core/models/profile.dart';
import '../../core/units/units.dart';
import '../../core/widgets/domain/field_row.dart';
import '../../core/widgets/domain/stat_card.dart';

/// The true minus sign, as the design uses for decreases.
const String kMinus = '−';

/// "31 Oct", or "31 Oct 2025" when it is not this year.
String bodyDateLabel(DateTime date, DateTime now) =>
    DateText.dayMonthSmart(date, now);

/// "Today, 31 Oct" for the current day, else [bodyDateLabel].
String bodyDateLabelLong(DateTime date, DateTime now) =>
    DateText.dayMonthLong(date, now);

/// The date at local midnight, which is how entries are dated.
DateTime dayOf(DateTime d) {
  final DateTime l = d.toLocal();
  return DateTime(l.year, l.month, l.day);
}

/// How a field's metric value is typed and shown in the profile's units.
FieldUnit fieldUnitFor(MeasurementField field, Profile profile) {
  switch (field.unitType) {
    case MeasurementUnitType.length:
      return FieldUnit.length(profile.lengthUnit);
    case MeasurementUnitType.mass:
      return FieldUnit.weight(profile.weightUnit);
    case MeasurementUnitType.percent:
      return FieldUnit.plain('%');
    case MeasurementUnitType.count:
      return FieldUnit.plain('count', decimals: 0);
    case MeasurementUnitType.custom:
      final String label = (field.customUnit ?? '').trim();
      return FieldUnit.plain(label.isEmpty ? 'units' : label, decimals: 2);
  }
}

/// "84 cm", "176.4 lb", "18 %".
String formatFieldValue(FieldUnit unit, double metric) =>
    '${unit.format(metric)} ${unit.label}';

/// "+0.5" or "−1.0" in display units; "0" when nothing changed.
String signedDisplayDelta(FieldUnit unit, double metricDelta) {
  final double shown = unit.toDisplay(metricDelta);
  final String text = Units.trim(shown.abs(), maxDecimals: unit.decimals);
  if (text == '0') return '0';
  return '${shown > 0 ? '+' : kMinus}$text';
}

StatDelta? statDeltaFor(FieldUnit unit, double? metricDelta) {
  if (metricDelta == null) return null;
  final String text = signedDisplayDelta(unit, metricDelta);
  final StatTrend trend = text == '0'
      ? StatTrend.flat
      : (metricDelta > 0 ? StatTrend.up : StatTrend.down);
  return StatDelta('$text ${unit.label}', trend: trend);
}

/// Plain-words name of a body anchor in a field's meta line.
String anchorMeta(BodyAnchor? a) =>
    a == null ? 'not drawn' : 'Silhouette: ${bodyAnchorWord(a)}';

String bodyAnchorWord(BodyAnchor a) => switch (a) {
  BodyAnchor.neck => 'neck',
  BodyAnchor.shoulders => 'shoulders',
  BodyAnchor.chest => 'chest',
  BodyAnchor.upperArm => 'upper arm',
  BodyAnchor.forearm => 'forearm',
  BodyAnchor.aboveNavel => 'above navel',
  BodyAnchor.waist => 'waist',
  BodyAnchor.belowNavel => 'below navel',
  BodyAnchor.hips => 'hips',
  BodyAnchor.thigh => 'thigh',
  BodyAnchor.calf => 'calf',
};

String unitTypeLabel(MeasurementUnitType t) => switch (t) {
  MeasurementUnitType.length => 'Length',
  MeasurementUnitType.mass => 'Weight',
  MeasurementUnitType.percent => 'Percent',
  MeasurementUnitType.count => 'Number',
  MeasurementUnitType.custom => 'Custom',
};
