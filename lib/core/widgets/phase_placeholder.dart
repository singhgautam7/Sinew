import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Stands in for a screen that a later phase builds. Removed as each screen
/// lands; nothing ships with one.
class PhasePlaceholder extends StatelessWidget {
  const PhasePlaceholder({
    super.key,
    required this.title,
    required this.phase,
    this.actions = const <Widget>[],
  });

  final String title;
  final int phase;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Space.screen),
          children: <Widget>[
            Text(
              'Arrives in Phase $phase.',
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            if (actions.isNotEmpty) const SizedBox(height: Space.xl),
            ...actions,
          ],
        ),
      ),
    );
  }
}
