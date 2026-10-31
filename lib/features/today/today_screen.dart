import 'package:flutter/material.dart';

import '../../core/widgets/phase_placeholder.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PhasePlaceholder(title: 'Today', phase: 8);
}
