import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/sinew_states.dart';

/// A centred spinner that stays invisible for the first moments, so a fast
/// load never flashes one.
class TrainLoading extends StatelessWidget {
  const TrainLoading({super.key});

  @override
  Widget build(BuildContext context) => Delayed(
    child: Center(
      child: Semantics(
        liveRegion: true,
        label: 'Loading',
        child: const CircularProgressIndicator(
          strokeWidth: Strokes.spinnerLarge,
        ),
      ),
    ),
  );
}

/// The caps label above a block of rows.
class TrainSectionLabel extends StatelessWidget {
  const TrainSectionLabel(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding:
        padding ??
        const EdgeInsets.only(top: Space.xl, bottom: Space.sectionHeaderGap),
    child: Semantics(
      header: true,
      child: Text(text.toUpperCase(), style: context.sectionHeader),
    ),
  );
}
