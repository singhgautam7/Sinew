import 'package:flutter/material.dart';

import '../../core/widgets/phase_placeholder.dart';

class BodyScreen extends StatelessWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PhasePlaceholder(title: 'Body', phase: 7);
}
