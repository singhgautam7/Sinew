import 'package:flutter/widgets.dart';

/// The text shown where a value is missing: an en dash, never a hyphen.
const String kNoValue = '–';

/// Number text shared by the screens.
abstract final class NumberText {
  /// `12,345` for 12345.4 (rounded, comma grouped).
  static String thousands(num v) {
    final bool negative = v < 0;
    final String digits = v.abs().round().toString();
    final StringBuffer out = StringBuffer(negative ? '-' : '');
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return out.toString();
  }
}

/// [kNoValue] as a widget that TalkBack reads as "no value" instead of
/// "en dash".
class NoValueText extends StatelessWidget {
  const NoValueText({super.key, this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'no value',
    excludeSemantics: true,
    child: Text(kNoValue, style: style),
  );
}
