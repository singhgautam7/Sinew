import 'package:flutter/widgets.dart';

/// The overflow menu a screen hands to `SinewAppBar`: its items, in order.
/// Destructive items are listed last by the bar, after a divider.
class SinewOverflowConfig {
  const SinewOverflowConfig({required this.items});

  final List<SinewOverflowItem> items;
}

/// One row of an overflow menu.
class SinewOverflowItem {
  const SinewOverflowItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.selected = false,
    this.dividerBefore = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  /// Shows a check (radio-style choices such as "Sort: Modified").
  final bool selected;

  /// Starts a new group in the menu (a divider above this item).
  final bool dividerBefore;
}

/// Content of a "How it works" info sheet (`showSinewInfoSheet`): a title, a
/// description, optional icon + text items and an optional example block.
class SinewInfoConfig {
  const SinewInfoConfig({
    required this.title,
    required this.description,
    this.items = const <SinewInfoItem>[],
    this.customChild,
    this.exampleBlock,
    this.actionLabel,
  });

  final String title;
  final String description;
  final List<SinewInfoItem> items;
  final Widget? customChild;

  /// An "Example" block with real, computed numbers (a stat's formula).
  final SinewInfoExampleBlock? exampleBlock;

  /// Overrides the pinned button label ("Got it"); the button is then tonal.
  final String? actionLabel;
}

/// Example block: an optional sentence, label / value rows (one may be
/// highlighted) and an optional closing line.
class SinewInfoExampleBlock {
  const SinewInfoExampleBlock({
    required this.label,
    this.sentence,
    this.rows = const <SinewInfoExampleRow>[],
    this.after,
  });

  final String label;
  final String? sentence;
  final List<SinewInfoExampleRow> rows;
  final String? after;
}

class SinewInfoExampleRow {
  const SinewInfoExampleRow(this.label, this.value, {this.highlight = false});

  final String label;
  final String value;
  final bool highlight;
}

class SinewInfoItem {
  const SinewInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
