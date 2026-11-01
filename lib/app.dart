import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/routing/router.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/wallpaper_seed.dart';
import 'core/widgets/sinew_extended_fab.dart';

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
    final AppThemeMode mode = ref.watch(
      settingsProvider.select((AppSettings s) => s.themeMode),
    );
    final String familyId = ref.watch(
      settingsProvider.select((AppSettings s) => s.familyId),
    );
    final double textScale = ref.watch(
      settingsProvider.select((AppSettings s) => s.textScale),
    );
    final Color? seed = ref.watch(activeSeedProvider);

    return MaterialApp.router(
      title: 'Sinew',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: mode.materialMode,
      // Cached per (family or seed, tone): rebuilding the app never rebuilds a
      // theme. AMOLED is the dark theme in its black tone.
      theme: AppTheme.of(Tone.light, familyId: familyId, seed: seed),
      darkTheme: AppTheme.of(
        mode == AppThemeMode.amoled ? Tone.amoled : Tone.dark,
        familyId: familyId,
        seed: seed,
      ),
      // The in-app text size sits on top of the OS scale; nothing caps the
      // OS scale, so 200% must lay out without breaking.
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(
            MediaQuery.textScalerOf(context).scale(1) * textScale,
          ),
        ),
        child: SinewFabScrollWatcher(child: child!),
      ),
    );
  }
}
