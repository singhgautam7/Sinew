import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/sinew_app_bar.dart';
import '../../core/widgets/sinew_list.dart';

/// What Sinew can and cannot do on the phone. The list mirrors the manifest:
/// if a permission is added there, it is explained here.
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  static const List<(IconData, String, String, String)> used =
      <(IconData, String, String, String)>[
        (
          Icons.notifications_outlined,
          'Notifications',
          'Shows the running timer and its controls, so you can pause it from '
              'the lock screen. Asked the first time you start a timer.',
          'You decide',
        ),
        (
          Icons.hourglass_top_rounded,
          'Foreground service',
          'Keeps a running timer alive when you switch apps or the screen '
              'turns off. It runs only while a timer does.',
          'While a timer runs',
        ),
        (
          Icons.vibration_rounded,
          'Vibration',
          'Haptics when a set is done and for timer cues.',
          'Allowed',
        ),
        (
          Icons.screen_lock_portrait_rounded,
          'Keep screen awake',
          'Stops the screen sleeping during a workout or a timer, if you '
              'leave that setting on.',
          'Allowed',
        ),
        (
          Icons.folder_open_rounded,
          'Files you pick',
          'Only when you export or import a backup. Android shows its own '
              'file picker, and Sinew sees just the file you choose.',
          'Ask each time',
        ),
      ];

  static const String never =
      'Internet, location, contacts, camera, microphone, health data, '
      'accounts, and your other files.';

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Scaffold(
      appBar: const SinewAppBar(
        title: 'Permissions',
        subtitle: 'What Sinew can and cannot do',
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          Space.xs,
          Space.screen,
          Space.bottomSafe,
        ),
        children: <Widget>[
          SinewCard(
            color: cs.primaryContainer,
            borderColor: cs.primaryContainer,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.wifi_off_rounded, color: cs.onPrimaryContainer),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'No internet permission',
                        style: tt.titleMedium!.copyWith(
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'Android will not let Sinew go online at all, so your '
                        'data cannot leave the phone.',
                        style: tt.bodyMedium!.copyWith(
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.section),
          const SinewSectionHeader(title: 'Used'),
          SinewGroup(
            children: <Widget>[
              for (final (IconData icon, String title, String body, String tag)
                  in used)
                SinewListRow(
                  leading: SinewIconTile(icon: icon),
                  title: title,
                  subtitle: body,
                  subtitleLines: 5,
                  below: Padding(
                    padding: const EdgeInsets.only(top: Space.xs),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SinewPill(label: tag, tone: SinewTone.neutral),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.section),
          const SinewSectionHeader(title: 'Never asked for'),
          Text(
            never,
            style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
