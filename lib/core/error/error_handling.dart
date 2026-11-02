import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Installs the app-wide error handlers. Errors are logged to the device log
/// only: there is no crash reporting, ever (offline guarantee).
///
/// - Framework errors keep Flutter's default presentation in debug.
/// - Uncaught async errors are logged and marked handled so the process
///   does not die on, for example, a failed platform call.
/// - In release, a widget that throws while building is replaced by
///   [ErrorFallback] instead of a grey box.
void installErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Sinew: uncaught error: $error\n$stack');
    return true;
  };
  if (kReleaseMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) =>
        const ErrorFallback();
  }
}

/// What a broken widget shows in release: a quiet, readable notice in place
/// of the part that failed, never a crash of the whole screen.
class ErrorFallback extends StatelessWidget {
  const ErrorFallback({super.key, this.message});

  final String? message;

  static const String defaultMessage =
      'Something went wrong showing this part. Your data is safe.';

  @override
  Widget build(BuildContext context) {
    // May render outside a MaterialApp (a failure above it), so the colours
    // come from whatever theme is reachable, else Material defaults.
    final ThemeData theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: IconSpec.size,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: Space.sm),
              Flexible(
                child: Text(
                  message ?? defaultMessage,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown instead of the app when the user database cannot be opened at
/// startup (corrupt file, a database from a newer build). A dead end with an
/// explanation beats a blank window; nothing is deleted automatically.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sinew could not open your data',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: Space.md),
                const Text(
                  'Nothing has been deleted. Updating Sinew usually fixes '
                  'this. If it keeps happening, take a screenshot of the '
                  'details below.',
                ),
                const SizedBox(height: Space.lg),
                SelectableText(
                  '$error',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
