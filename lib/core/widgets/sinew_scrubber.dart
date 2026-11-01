import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A slider for moving through a series (the Compare screen's date scrubber).
/// [value] runs from 0 to [max]; end labels sit under the track. The slider
/// carries its own TalkBack value and 48dp target.
class SinewScrubber extends StatelessWidget {
  const SinewScrubber({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    this.semanticValue,
    this.onChangeEnd,
    this.startLabel,
    this.endLabel,
  }) : assert(max > 0, 'a scrubber needs somewhere to go');

  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  /// "Compare date".
  final String semanticLabel;

  /// Spoken value, such as "31 Oct".
  final String? semanticValue;
  final String? startLabel;
  final String? endLabel;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = context.text.labelMedium!.copyWith(
      color: context.cs.onSurfaceVariant,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Slider(
          value: value.clamp(0, max),
          min: 0,
          max: max,
          semanticFormatterCallback: semanticValue == null
              ? null
              : (double _) => semanticValue!,
          label: semanticLabel,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
        if (startLabel != null || endLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text(
                    startLabel ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
                Flexible(
                  child: Text(
                    endLabel ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
