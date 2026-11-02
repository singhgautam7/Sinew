import 'package:flutter/material.dart';

/// One bank of user-pickable swatches.
@immutable
class PickerBank {
  const PickerBank(this.label, this.swatches);

  final String label;
  final List<int> swatches;
}

/// The colours a user can give a routine or a custom field (Kuber's Vibrant,
/// Muted and Neutral banks). User data stores the ARGB int; drawing it goes
/// through `Color(value)` in the colour picker only. Raw colours live in the
/// theme layer, and these are the one deliberate set of colours that do not
/// follow the theme: they are the user's own choice.
abstract final class SinewPickerPalette {
  static const PickerBank vibrant = PickerBank('Vibrant', <int>[
    0xFF3B82F6,
    0xFF6366F1,
    0xFF8B5CF6,
    0xFFEC4899,
    0xFFF43F5E,
    0xFFEF4444,
    0xFFF97316,
    0xFFF59E0B,
    0xFFEAB308,
    0xFF84CC16,
    0xFF22C55E,
    0xFF10B981,
    0xFF14B8A6,
    0xFF06B6D4,
    0xFF0EA5E9,
    0xFFA855F7,
    0xFFD946EF,
    0xFFFB7185,
  ]);

  static const PickerBank muted = PickerBank('Muted', <int>[
    0xFF64748B,
    0xFF5EAD9D,
    0xFF7C9E78,
    0xFFB89B6E,
    0xFFB8748B,
    0xFF8C7CB0,
    0xFF7B8294,
    0xFFA89F8B,
  ]);

  static const PickerBank neutral = PickerBank('Neutral', <int>[
    0xFF27272A,
    0xFF52525B,
    0xFF71717A,
    0xFFA1A1AA,
    0xFFD4D4D8,
    0xFF78716C,
  ]);

  static const List<PickerBank> banks = <PickerBank>[vibrant, muted, neutral];

  /// The default pick: the first vibrant swatch.
  static const int defaultColor = 0xFF3B82F6;
}
