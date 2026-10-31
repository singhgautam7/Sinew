import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/router.dart';
import '../../core/widgets/phase_placeholder.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) => PhasePlaceholder(
    title: 'More',
    phase: 8,
    actions: <Widget>[
      ListTile(
        leading: const Icon(Icons.bug_report_outlined),
        title: const Text('Debug'),
        subtitle: const Text('Databases, library and theme'),
        onTap: () => context.push(Routes.debug),
      ),
    ],
  );
}
