import 'package:flutter/material.dart';

/// The reference values the handoff lists (`tokens/sinew_tokens.dart`,
/// "Sinew 1 Foundations" schemeL / schemeD / schemeA), keyed by the
/// `ColorScheme` role name. Tests compare the family formula against them.
const Map<String, Color> kSinewLight = <String, Color>{
  'primary': Color(0xFF617600),
  'onPrimary': Color(0xFFFFFFFF),
  'primaryContainer': Color(0xFFE0EAC9),
  'onPrimaryContainer': Color(0xFF394B00),
  'secondaryContainer': Color(0xFFE0EAC9),
  'onSecondaryContainer': Color(0xFF394B00),
  'inversePrimary': Color(0xFFA1B567),
  'surface': Color(0xFFF9FBF4),
  'surfaceContainerLowest': Color(0xFFFFFFFF),
  'surfaceContainerLow': Color(0xFFF4F7ED),
  'surfaceContainer': Color(0xFFEFF2E5),
  'surfaceContainerHigh': Color(0xFFE6EADB),
  'surfaceContainerHighest': Color(0xFFDDE1D1),
  'outlineVariant': Color(0xFFD4D8C7),
  'outline': Color(0xFF858878),
  'onSurface': Color(0xFF15180B),
  'onSurfaceVariant': Color(0xFF626556),
  'inverseSurface': Color(0xFF191C0F),
  'onInverseSurface': Color(0xFFF5F6F2),
  'error': Color(0xFFBD413F),
  'errorContainer': Color(0xFFFFE7E4),
  'onErrorContainer': Color(0xFFA92227),
};

const Map<String, Color> kSinewDark = <String, Color>{
  'primary': Color(0xFFA1B567),
  'onPrimary': Color(0xFF090A05),
  'primaryContainer': Color(0xFF252C0F),
  'onPrimaryContainer': Color(0xFFD9E3C0),
  'secondaryContainer': Color(0xFF252C0F),
  'onSecondaryContainer': Color(0xFFD9E3C0),
  'inversePrimary': Color(0xFF677C06),
  'surface': Color(0xFF161811),
  'surfaceContainerLowest': Color(0xFF0F100A),
  'surfaceContainerLow': Color(0xFF1C1E16),
  'surfaceContainer': Color(0xFF22241B),
  'surfaceContainerHigh': Color(0xFF2D2F24),
  'surfaceContainerHighest': Color(0xFF35372C),
  'outlineVariant': Color(0xFF3C3F33),
  'outline': Color(0xFF7F8178),
  'onSurface': Color(0xFFF1F2EE),
  'onSurfaceVariant': Color(0xFFA3A69C),
  'inverseSurface': Color(0xFFE7E9E2),
  'onInverseSurface': Color(0xFF15180B),
  'error': Color(0xFFF07F77),
  'errorContainer': Color(0xFF391917),
  'onErrorContainer': Color(0xFFFFA8A0),
};

/// AMOLED (Foundations `schemeA`). `onInverseSurface` is not listed there.
const Map<String, Color> kSinewAmoled = <String, Color>{
  'primary': Color(0xFFA1B567),
  'onPrimary': Color(0xFF000000),
  'primaryContainer': Color(0xFF1A2005),
  'onPrimaryContainer': Color(0xFFD9E3C0),
  'inversePrimary': Color(0xFF677C06),
  'error': Color(0xFFF07F77),
  'surface': Color(0xFF000000),
  'surfaceContainerLowest': Color(0xFF000000),
  'surfaceContainerLow': Color(0xFF050603),
  'surfaceContainer': Color(0xFF0B0D06),
  'surfaceContainerHigh': Color(0xFF13160B),
  'surfaceContainerHighest': Color(0xFF1B1F11),
  'outlineVariant': Color(0xFF2E3324),
  'outline': Color(0xFF6F7A52),
  'onSurfaceVariant': Color(0xFFA9B98A),
  'onSurface': Color(0xFFE4ECC7),
  'inverseSurface': Color(0xFFE4ECC7),
  'errorContainer': Color(0xFF2A0E0C),
};

/// Reads a scheme role by name.
Color roleOf(ColorScheme s, String role) => switch (role) {
  'primary' => s.primary,
  'onPrimary' => s.onPrimary,
  'primaryContainer' => s.primaryContainer,
  'onPrimaryContainer' => s.onPrimaryContainer,
  'secondaryContainer' => s.secondaryContainer,
  'onSecondaryContainer' => s.onSecondaryContainer,
  'inversePrimary' => s.inversePrimary,
  'surface' => s.surface,
  'surfaceContainerLowest' => s.surfaceContainerLowest,
  'surfaceContainerLow' => s.surfaceContainerLow,
  'surfaceContainer' => s.surfaceContainer,
  'surfaceContainerHigh' => s.surfaceContainerHigh,
  'surfaceContainerHighest' => s.surfaceContainerHighest,
  'outlineVariant' => s.outlineVariant,
  'outline' => s.outline,
  'onSurface' => s.onSurface,
  'onSurfaceVariant' => s.onSurfaceVariant,
  'inverseSurface' => s.inverseSurface,
  'onInverseSurface' => s.onInverseSurface,
  'error' => s.error,
  'errorContainer' => s.errorContainer,
  'onErrorContainer' => s.onErrorContainer,
  _ => throw ArgumentError('unknown role $role'),
};

/// The largest per-channel difference between two colours, in 8-bit steps.
int channelDelta(Color a, Color b) {
  int c(double v) => (v * 255).round();
  final List<int> d = <int>[
    (c(a.r) - c(b.r)).abs(),
    (c(a.g) - c(b.g)).abs(),
    (c(a.b) - c(b.b)).abs(),
  ];
  return d.reduce((int x, int y) => x > y ? x : y);
}
