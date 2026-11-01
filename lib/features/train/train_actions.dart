import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/training.dart';
import '../../core/routing/router.dart';
import '../../core/widgets/sinew_snackbar.dart';
import 'workout_controller.dart';

/// Starts a workout (empty, or from [routine]) and opens it. When one is
/// already running it is resumed instead, with a note when a routine was
/// asked for.
Future<void> startWorkoutAndOpen(
  BuildContext context,
  WidgetRef ref, {
  Routine? routine,
}) async {
  final ({String id, bool resumed}) r = await ref
      .read(workoutLauncherProvider)
      .start(routine: routine);
  if (!context.mounted) return;
  if (r.resumed && routine != null) {
    showSinewSnackBar(
      context,
      'A workout is already in progress. Finish it to start another.',
    );
  }
  unawaited(context.push(Routes.workout));
}
