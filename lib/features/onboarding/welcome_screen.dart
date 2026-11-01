import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/sinew_brand_mark.dart';

/// The first screen of a first run: what Sinew promises, and two ways in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const List<(IconData, String)> promises = <(IconData, String)>[
    (Icons.person_off_outlined, 'No account, no sign-in'),
    (Icons.wifi_off_rounded, 'Works fully offline'),
    (Icons.smartphone_rounded, 'Data stays on your phone'),
    (Icons.money_off_rounded, 'Free. No ads.'),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.screen,
                    vertical: Space.lg,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: TodaySpec.readableWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SinewBrandMark(),
                        const SizedBox(height: Space.lg),
                        Semantics(
                          header: true,
                          child: Text(
                            'Sinew',
                            style: tt.displaySmall!.copyWith(color: cs.primary),
                          ),
                        ),
                        const SizedBox(height: Space.md),
                        Text(
                          'No account. Works offline. Your data stays on your '
                          'phone.',
                          style: tt.headlineSmall!.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: Space.md),
                        Text(
                          'Log any workout, look up thousands of exercises and '
                          'poses, run interval timers and track your '
                          'measurements. Free, with no ads.',
                          style: tt.bodyLarge!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: Space.xl),
                        for (final (IconData icon, String text) in promises)
                          Padding(
                            padding: const EdgeInsets.only(bottom: Space.md),
                            child: Row(
                              children: <Widget>[
                                Icon(icon, color: cs.primary),
                                const SizedBox(width: Space.md),
                                Expanded(
                                  child: Text(text, style: tt.bodyLarge),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.sm,
                Space.screen,
                Space.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppButton(
                    label: 'Get started',
                    type: AppButtonType.primary,
                    fullWidth: true,
                    onPressed: () => context.push(Routes.onboardingProfile),
                  ),
                  const SizedBox(height: Space.sm),
                  AppButton(
                    label: 'Restore a backup',
                    icon: Icons.settings_backup_restore_rounded,
                    type: AppButtonType.outline,
                    fullWidth: true,
                    onPressed: () => context.push(Routes.onboardingRestore),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
