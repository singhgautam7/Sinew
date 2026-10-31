import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/routing/router.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/palette.dart';
import 'core/theme/wallpaper_seed.dart';

class SinewApp extends ConsumerStatefulWidget {
  const SinewApp({super.key, this.initialLocation = Routes.today});

  final String initialLocation;

  @override
  ConsumerState<SinewApp> createState() => _SinewAppState();
}

class _SinewAppState extends ConsumerState<SinewApp> {
  late final GoRouter _router = buildRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Narrow selects: the app rebuilds only when a theme input changes.
    final ThemeMode mode = ref.watch(
      settingsProvider.select((AppSettings s) => s.themeMode),
    );
    final bool amoled = ref.watch(
      settingsProvider.select((AppSettings s) => s.amoled),
    );
    final double textScale = ref.watch(
      settingsProvider.select((AppSettings s) => s.textScale),
    );
    final Color? seed = ref.watch(activeSeedProvider);

    return MaterialApp.router(
      title: 'Sinew',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: mode,
      // Cached per (seed, tone): rebuilding the app never rebuilds a theme.
      theme: AppTheme.of(Tone.light, seed: seed),
      darkTheme: AppTheme.of(amoled ? Tone.amoled : Tone.dark, seed: seed),
      // The in-app text size sits on top of the OS scale; nothing caps the
      // OS scale, so 200% must lay out without breaking.
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(
            MediaQuery.textScalerOf(context).scale(1) * textScale,
          ),
        ),
        child: child!,
      ),
    );
  }
}
