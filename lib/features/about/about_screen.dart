import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/platform_channel.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_brand_mark.dart';
import '../../core/widgets/sinew_list.dart';
import '../../core/widgets/sinew_markdown.dart';
import '../../core/widgets/sinew_settings.dart';
import 'attributions.dart';

/// `versionName+versionCode` from the platform, or null where there is none
/// (tests without a fake channel). Never a string in Dart.
final FutureProvider<String?> appVersionProvider =
    FutureProvider.autoDispose<String?>(
      (Ref ref) => SinewPlatform.appVersion(),
    );

/// `0.1.0+1` as `0.1.0 (1)`.
String versionLabel(String? raw) {
  if (raw == null || raw.isEmpty) return 'Version unknown';
  final List<String> parts = raw.split('+');
  return parts.length == 2
      ? 'Version ${parts[0]} (${parts[1]})'
      : 'Version $raw';
}

/// The offline promise, where the data comes from, the fonts, the licences
/// and the version.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const List<String> tags = <String>[
    'Offline',
    'Private',
    'Free',
    'No ads',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final String version = versionLabel(ref.watch(appVersionProvider).value);
    return Scaffold(
      appBar: const SinewAppBar(title: 'About Sinew', showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          Space.xs,
          Space.screen,
          Space.bottomSafe,
        ),
        children: <Widget>[
          SinewCard(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('WHAT IS SINEW', style: context.sectionHeader),
                const SizedBox(height: Space.md),
                Semantics(
                  header: true,
                  child: Text.rich(
                    TextSpan(
                      style: tt.headlineSmall!.copyWith(color: cs.onSurface),
                      children: <InlineSpan>[
                        const TextSpan(text: 'One place to '),
                        TextSpan(
                          text: 'train and keep track',
                          style: context.serifAccent.copyWith(
                            color: cs.primary,
                            fontSize: tt.headlineSmall!.fontSize,
                          ),
                        ),
                        const TextSpan(text: ', with nothing sent anywhere.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Space.md),
                Text(
                  'Sinew logs your workouts, times your intervals and keeps '
                  'your measurements. It has no account, no server and no '
                  'ads. Everything lives in one database on this phone, and '
                  'you can export it whenever you like.',
                  style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: Space.md),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: <Widget>[
                    for (final String t in tags) SinewPill(label: t),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.section),
          const SinewSectionHeader(title: 'Privacy'),
          SinewCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SinewIconTile(
                  icon: Icons.wifi_off_rounded,
                  tone: SinewTone.primary,
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'No network requests. Nothing collected.',
                        style: tt.titleMedium,
                      ),
                      const SizedBox(height: Space.xs),
                      Text(
                        'Sinew makes no network requests and collects '
                        'nothing: no analytics, no crash reports, no ads, no '
                        'accounts. The app does not even have the internet '
                        'permission, so Android would block it if it tried.',
                        style: tt.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.section),
          const SinewSectionHeader(title: 'Data sources and thanks'),
          const SinewCard(child: SinewMarkdown(kAttributionsMarkdown)),
          const SizedBox(height: Space.section),
          const SinewSectionHeader(title: 'Fonts and icons'),
          SinewCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Inter, JetBrains Mono and Instrument Serif are bundled with '
                  'the app under the SIL Open Font License 1.1. Nothing is '
                  'downloaded. Icons are Material Symbols.',
                  style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.section),
          SinewSettingsSection(
            label: 'Licences',
            bottomGap: Space.xl,
            children: <Widget>[
              SinewNavigationRow(
                icon: Icons.description_outlined,
                label: 'Open-source licences',
                subtitle: 'Libraries and fonts used by Sinew',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Sinew',
                  applicationVersion: version,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              const SinewBrandMark(size: Sizes.tile),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Sinew', style: tt.titleMedium),
                    Text(
                      version,
                      key: const ValueKey<String>('about-version'),
                      style: tt.bodyMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
