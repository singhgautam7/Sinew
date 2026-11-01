import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'sinew_app_bar.dart';

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
      appBar: SinewAppBar(title: title),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.screen,
            Space.screen,
            Space.bottomSafe,
          ),
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
