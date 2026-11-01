import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// A square-ish on / off tile with a glyph above its label, for a row of
/// options such as the timer's cues (Sound, Vibration, Spoken).
///
/// On: primary container fill and a primary border. Off: the plain surface
/// container. Announced to a screen reader as a toggle button with its state.
class SinewToggleTile extends StatelessWidget {
  const SinewToggleTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.height = ToggleTileSpec.height,
    this.haptics = true,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double height;
  final bool haptics;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final Color bg = value ? cs.primaryContainer : cs.surfaceContainer;
    final Color fg = value ? cs.onPrimaryContainer : cs.onSurfaceVariant;
    final Color border = value ? cs.primary : cs.outline;
    return Semantics(
      button: true,
      toggled: value,
      label: label,
      excludeSemantics: true,
      onTap: () => onChanged(!value),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.largeR,
          side: BorderSide(color: border, width: Strokes.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (haptics) HapticFeedback.selectionClick();
            onChanged(!value);
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.xs,
                vertical: Space.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: IconSpec.size, color: fg),
                  const SizedBox(height: Space.xs),
                  Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelLarge!.copyWith(color: fg),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
