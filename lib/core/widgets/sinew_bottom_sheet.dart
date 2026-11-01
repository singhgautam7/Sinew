import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_button.dart';
import 'app_icon_button.dart';
import 'configs.dart';

/// Shows [builder] as a modal bottom sheet the way every Sinew sheet is shown:
/// scroll controlled, root navigator, transparent so [SinewBottomSheet] draws
/// its own surface, keyboard aware.
Future<T?> showSinewBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool useSafeArea = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: useSafeArea,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    builder: builder,
  );
}

/// The shell for every bottom sheet: surfaceContainerLow, top radius 28, a
/// 32x4 drag handle in a 24 band; header with an optional 48 leading, a caps
/// overline ([subtitle]), the titleLarge [title], a bodyMedium [description]
/// and a close button; a scrolling body with a divider under the header once
/// it scrolls; and pinned [actions] below.
class SinewBottomSheet extends StatefulWidget {
  const SinewBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.leadingIcon,
    required this.child,
    this.actions,
  });

  /// Primary title (titleLarge).
  final String title;

  /// Optional caps overline above the title.
  final String? subtitle;

  /// Optional text under the title (bodyMedium).
  final String? description;

  /// Optional leading widget in the header (a 48 tile).
  final Widget? leadingIcon;

  /// Body content, inside the scrollable area.
  final Widget child;

  /// Optional actions widget pinned at the bottom.
  final Widget? actions;

  @override
  State<SinewBottomSheet> createState() => _SinewBottomSheetState();
}

class _SinewBottomSheetState extends State<SinewBottomSheet> {
  final ValueNotifier<bool> _scrolled = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _scrolled.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
      _scrolled.value = n.metrics.pixels > 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: Radii.sheetR,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: Sizes.handleBand,
              child: Center(
                child: Semantics(
                  label: 'Drag handle',
                  child: Container(
                    width: Sizes.handleWidth,
                    height: Sizes.handleHeight,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(
                        alpha: Opacities.handle,
                      ),
                      borderRadius: Radii.fullR,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.xs,
                Space.lg,
                Space.md,
              ),
              child: Row(
                children: <Widget>[
                  if (widget.leadingIcon != null) ...<Widget>[
                    widget.leadingIcon!,
                    const SizedBox(width: Space.lg),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.sectionHeader,
                          ),
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleLarge!.copyWith(color: cs.onSurface),
                        ),
                        if (widget.description != null)
                          Text(
                            widget.description!,
                            style: tt.bodyMedium!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  AppIconButton(
                    icon: Icons.close_rounded,
                    semanticLabel: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _scrolled,
              builder: (BuildContext context, bool scrolled, Widget? _) =>
                  Divider(
                    height: Strokes.hairline,
                    thickness: Strokes.hairline,
                    color: scrolled ? cs.outlineVariant : Colors.transparent,
                  ),
            ),
            Flexible(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    Space.screen,
                    Space.xs,
                    Space.screen,
                    Space.lg,
                  ),
                  child: widget.child,
                ),
              ),
            ),
            if (widget.actions != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  Space.lg,
                  Space.screen,
                  Space.xl,
                ),
                child: widget.actions,
              ),
          ],
        ),
      ),
    );
  }
}

/// Opens the "How it works" info sheet for [config].
Future<void> showSinewInfoSheet(BuildContext context, SinewInfoConfig config) {
  return showSinewBottomSheet<void>(
    context: context,
    builder: (_) => SinewInfoSheet(config: config),
  );
}

/// The info sheet: description, icon + text items, an optional example block
/// and a pinned "Done" (or [SinewInfoConfig.actionLabel]) button.
class SinewInfoSheet extends StatelessWidget {
  const SinewInfoSheet({super.key, required this.config});

  final SinewInfoConfig config;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return SinewBottomSheet(
      title: config.title,
      actions: AppButton(
        label: config.actionLabel ?? 'Done',
        type: config.actionLabel != null
            ? AppButtonType.normal
            : AppButtonType.primary,
        fullWidth: true,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (config.description.trim().isNotEmpty) ...<Widget>[
            Text(
              config.description,
              style: tt.bodyLarge!.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: Space.xl),
          ],
          for (final SinewInfoItem item in config.items)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: Sizes.tile,
                    height: Sizes.tile,
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: Radii.mediumR,
                    ),
                    child: Icon(
                      item.icon,
                      size: IconSpec.glyph,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: Space.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.title,
                          style: tt.titleMedium!.copyWith(color: cs.onSurface),
                        ),
                        Text(
                          item.description,
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
          if (config.exampleBlock != null) ...<Widget>[
            _ExampleBlock(block: config.exampleBlock!),
            const SizedBox(height: Space.sm),
          ],
          if (config.customChild != null) ...<Widget>[
            config.customChild!,
            const SizedBox(height: Space.lg),
          ],
          const SizedBox(height: Space.lg),
        ],
      ),
    );
  }
}

/// Example block: surfaceContainerHigh r16 pad 16 gap 12, caps label,
/// sentence, label / value rows (highlight in primary), closing line.
class _ExampleBlock extends StatelessWidget {
  const _ExampleBlock({required this.block});

  final SinewInfoExampleBlock block;

  /// Values longer than this go under their label instead of beside it.
  static const int _inlineValueMax = 18;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final List<Widget> gap = <Widget>[];
    void add(Widget w) {
      if (gap.isNotEmpty) gap.add(const SizedBox(height: Space.md));
      gap.add(w);
    }

    add(Text(block.label.toUpperCase(), style: context.sectionHeader));
    if (block.sentence != null) {
      add(
        Text(
          block.sentence!,
          style: tt.bodyMedium!.copyWith(color: cs.onSurface),
        ),
      );
    }
    for (final SinewInfoExampleRow r in block.rows) {
      final Text labelText = Text(
        r.label,
        style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
      );
      final TextStyle valueStyle = tt.titleSmall!.copyWith(
        color: r.highlight ? cs.primary : cs.onSurface,
      );
      add(
        r.value.length > _inlineValueMax
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  labelText,
                  const SizedBox(height: Space.xxs),
                  Text(r.value, style: valueStyle),
                ],
              )
            : Row(
                children: <Widget>[
                  Expanded(child: labelText),
                  const SizedBox(width: Space.md),
                  Flexible(
                    child: Text(
                      r.value,
                      textAlign: TextAlign.end,
                      style: valueStyle,
                    ),
                  ),
                ],
              ),
      );
    }
    if (block.after != null) {
      add(
        Text(block.after!, style: tt.bodyMedium!.copyWith(color: cs.onSurface)),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: Radii.largeR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: gap,
      ),
    );
  }
}
