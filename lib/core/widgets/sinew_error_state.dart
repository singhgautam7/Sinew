import 'package:flutter/material.dart';

import 'sinew_states.dart';

/// A screen or list that could not load: the same shape as an empty state,
/// with a retry. The message is plain words, never an exception dump.
class SinewErrorState extends StatelessWidget {
  const SinewErrorState({
    super.key,
    this.title = 'Could not load this',
    this.description = 'Something went wrong reading your data on this device.',
    this.onRetry,
  });

  final String title;
  final String description;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => SinewEmptyState(
    icon: Icons.error_outline_rounded,
    title: title,
    description: description,
    actionLabel: onRetry == null ? null : 'Try again',
    actionIcon: Icons.refresh_rounded,
    onAction: onRetry,
  );
}
