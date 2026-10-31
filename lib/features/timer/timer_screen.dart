import 'package:flutter/material.dart';

import '../../core/widgets/phase_placeholder.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PhasePlaceholder(title: 'Timer', phase: 6);
}
