import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Two equal columns whose rows are as tall as their taller card. Narrow
/// enough for a 360dp phone at 200% text: a card never needs a scroll or a
/// third column. An odd last child leaves its row's second half empty.
class SinewTwoColumnGrid extends StatelessWidget {
  const SinewTwoColumnGrid({
    super.key,
    required this.children,
    this.spacing = Space.md,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < children.length; i += 2) ...<Widget>[
          if (i > 0) SizedBox(height: spacing),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: children[i]),
                SizedBox(width: spacing),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
