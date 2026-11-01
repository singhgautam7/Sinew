import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/router.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../backup/restore_panel.dart';

/// First-run restore: pick a backup, see what is in it, replace the (empty)
/// phone with it and go straight into the app.
class OnboardingRestoreScreen extends ConsumerWidget {
  const OnboardingRestoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const SinewAppBar(title: 'Restore a backup', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.sm,
            Space.screen,
            Space.xl,
          ),
          children: <Widget>[
            RestorePanel(
              allowMerge: false,
              doneLabel: 'Open Sinew',
              onDone: () async {
                await ref
                    .read(settingsProvider.notifier)
                    .setOnboarded(value: true);
                if (context.mounted) context.go(Routes.today);
              },
            ),
          ],
        ),
      ),
    );
  }
}
