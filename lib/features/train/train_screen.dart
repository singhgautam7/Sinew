import 'package:flutter/material.dart';

import '../../core/widgets/phase_placeholder.dart';

class TrainScreen extends StatelessWidget {
  const TrainScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PhasePlaceholder(title: 'Train', phase: 4);
}
