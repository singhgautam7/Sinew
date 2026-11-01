import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/picker_palette.dart';
import '../../core/widgets/domain/muscle_map.dart';
import '../../core/models/enums.dart';
import '../../core/models/exercise.dart';

/// How a routine looks in lists: an icon or its muscle map, in a colour.
///
/// The database has no column for this and may not change, so the choice
/// lives in SharedPreferences under `routine.style.<routineId>` as JSON
/// (`{"v":1,"icon":"bolt","color":4281...,"map":true}`). A routine without an
/// entry gets [RoutineStyle.fallback]. Deleting a routine removes its key. The
/// style is not part of backups (a restore falls back to the default look).
@immutable
class RoutineStyle {
  const RoutineStyle({
    this.iconKey = defaultIcon,
    this.colorValue,
    this.useMap = true,
  });

  static const RoutineStyle fallback = RoutineStyle();
  static const String defaultIcon = 'fitness_center';
  static const int schemaVersion = 1;

  final String iconKey;

  /// ARGB of the user's pick, or null for the theme's primary colour.
  final int? colorValue;

  /// The muscle map as the tile (when the routine has muscles), else the icon.
  final bool useMap;

  RoutineStyle copyWith({String? iconKey, int? colorValue, bool? useMap}) =>
      RoutineStyle(
        iconKey: iconKey ?? this.iconKey,
        colorValue: colorValue ?? this.colorValue,
        useMap: useMap ?? this.useMap,
      );

  Map<String, Object?> toJson() => <String, Object?>{
    'v': schemaVersion,
    'icon': iconKey,
    'color': colorValue,
    'map': useMap,
  };

  /// Unreadable or newer payloads fall back to the default look.
  static RoutineStyle fromJsonString(String? raw) {
    if (raw == null) return fallback;
    try {
      final Object? json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return fallback;
      final int v = (json['v'] as num?)?.toInt() ?? 1;
      if (v > schemaVersion) return fallback;
      final Object? icon = json['icon'];
      final Object? color = json['color'];
      final Object? map = json['map'];
      return RoutineStyle(
        iconKey: icon is String && kRoutineIcons.containsKey(icon)
            ? icon
            : defaultIcon,
        colorValue: color is num ? color.toInt() : null,
        useMap: map is bool ? map : true,
      );
    } on Object {
      return fallback;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is RoutineStyle &&
      other.iconKey == iconKey &&
      other.colorValue == colorValue &&
      other.useMap == useMap;

  @override
  int get hashCode => Object.hash(iconKey, colorValue, useMap);
}

/// Preference key for a routine's style.
String routineStyleKey(String routineId) => 'routine.style.$routineId';

/// Icons offered for a routine (Kuber's sheet, the Train frames).
const Map<String, IconData> kRoutineIcons = <String, IconData>{
  'fitness_center': Icons.fitness_center_rounded,
  'self_improvement': Icons.self_improvement_rounded,
  'sports_mma': Icons.sports_mma_rounded,
  'directions_run': Icons.directions_run_rounded,
  'pool': Icons.pool_rounded,
  'directions_bike': Icons.directions_bike_rounded,
  'sports_gymnastics': Icons.sports_gymnastics_rounded,
  'sports_martial_arts': Icons.sports_martial_arts_rounded,
  'hiking': Icons.hiking_rounded,
  'rowing': Icons.rowing_rounded,
  'sports_tennis': Icons.sports_tennis_rounded,
  'sports_basketball': Icons.sports_basketball_rounded,
  'sports_soccer': Icons.sports_soccer_rounded,
  'skateboarding': Icons.skateboarding_rounded,
  'accessibility_new': Icons.accessibility_new_rounded,
  'monitor_heart': Icons.monitor_heart_rounded,
  'bolt': Icons.bolt_rounded,
  'local_fire_department': Icons.local_fire_department_rounded,
};

/// Reads and writes routine styles. Invalidate [routineStyleProvider] after a
/// write (done here).
class RoutineStyleStore {
  RoutineStyleStore(this._ref);

  final Ref _ref;

  Future<void> save(String routineId, RoutineStyle style) async {
    await _ref
        .read(prefsProvider)
        .setString(routineStyleKey(routineId), jsonEncode(style.toJson()));
    _ref.invalidate(routineStyleProvider(routineId));
  }

  Future<void> remove(String routineId) async {
    await _ref.read(prefsProvider).remove(routineStyleKey(routineId));
    _ref.invalidate(routineStyleProvider(routineId));
  }
}

final Provider<RoutineStyleStore> routineStyleStoreProvider =
    Provider<RoutineStyleStore>((Ref ref) => RoutineStyleStore(ref));

final routineStyleProvider = Provider.family<RoutineStyle, String>(
  (Ref ref, String routineId) => RoutineStyle.fromJsonString(
    ref.watch(prefsProvider).getString(routineStyleKey(routineId)),
  ),
);

/// The tile for a routine: a rounded square holding its muscle map (cropped)
/// or its icon, tinted with the routine's colour.
class RoutineTile extends StatelessWidget {
  const RoutineTile({
    super.key,
    required this.style,
    required this.primary,
    required this.secondary,
    required this.size,
    this.sex,
  });

  final RoutineStyle style;
  final List<String> primary;
  final List<String> secondary;
  final double size;
  final Sex? sex;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final Color? picked = style.colorValue == null
        ? null
        : Color(style.colorValue!);
    final Color base = picked ?? cs.primary;
    final bool showMap = style.useMap && primary.isNotEmpty;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: picked == null
              ? cs.primaryContainer
              : base.withValues(alpha: Opacities.track),
          borderRadius: Radii.largeR,
        ),
        alignment: Alignment.center,
        child: showMap
            ? MuscleMap(
                primary: primary,
                secondary: secondary,
                fit: MuscleMapFit.crop,
                showLabels: false,
                sex: sex,
                tint: picked,
              )
            : Icon(
                kRoutineIcons[style.iconKey] ?? Icons.fitness_center_rounded,
                size: size / 2,
                color: picked ?? cs.onPrimaryContainer,
              ),
      ),
    );
  }
}

/// The colour a style resolves to in the picker, whose swatch needs a value.
int pickerColorOf(RoutineStyle s) =>
    s.colorValue ?? SinewPickerPalette.defaultColor;

/// The muscles a routine works: primary muscles in order of how often they
/// are trained, then the secondary ones that are not already primary.
({List<String> primary, List<String> secondary}) routineMuscles(
  Iterable<String> exerciseIds,
  Map<String, Exercise> exercises,
) {
  final Map<String, int> primary = <String, int>{};
  final Map<String, int> secondary = <String, int>{};
  for (final String id in exerciseIds) {
    final Exercise? e = exercises[id];
    if (e == null) continue;
    for (final String m in e.primaryMuscles) {
      primary[m] = (primary[m] ?? 0) + 1;
    }
    for (final String m in e.secondaryMuscles) {
      secondary[m] = (secondary[m] ?? 0) + 1;
    }
  }
  List<String> ranked(Map<String, int> m) =>
      (m.keys.toList()..sort((String a, String b) => m[b]!.compareTo(m[a]!)));
  return (
    primary: ranked(primary),
    secondary: <String>[
      for (final String m in ranked(secondary))
        if (!primary.containsKey(m)) m,
    ],
  );
}
