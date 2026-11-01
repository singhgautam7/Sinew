import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_button.dart';

/// Asks the user to confirm an action and returns whether they did. A cancel,
/// a tap outside and the back button all return false.
///
/// With [destructive] the confirm button is a solid danger button (Delete
/// routine, Discard workout), and Cancel is the quiet one. The dialog uses the
/// theme's dialog surface (radius 28, surfaceContainerHigh).
Future<bool> showSinewConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowButtonSpacing: Space.sm,
      actions: <Widget>[
        AppButton(
          label: cancelLabel,
          type: AppButtonType.outline,
          height: Sizes.buttonSmall,
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
        AppButton(
          label: confirmLabel,
          type: destructive ? AppButtonType.danger : AppButtonType.primary,
          filled: destructive,
          height: Sizes.buttonSmall,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}
