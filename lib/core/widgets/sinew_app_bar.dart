import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icon_button.dart';
import 'configs.dart';
import 'sinew_bottom_sheet.dart';
import 'sinew_menu.dart';

/// The header search button: a search glyph beside the overflow that turns the
/// header row into an inline search pill. The screen keeps owning the query:
/// [controller] holds the text and [onChanged] fires on every edit, including
/// the clear when search is closed.
class SinewHeaderSearch {
  const SinewHeaderSearch({
    required this.controller,
    required this.onChanged,
    this.hint = 'Search',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
}

/// The one header. Padding L(back|home ? 16 : 20) T14 R(actions ? 16 : 20)
/// B12, a 6dp gap after the leading buttons, titleLarge, a one-line
/// bodyMedium subtitle. Slots: back (or close), home, search, actions, info
/// and overflow.
///
/// "How it works" ([infoConfig]) always lives in the overflow menu, first;
/// the screen's own [overflowConfig] items follow, destructive ones last after
/// a divider. Use as `Scaffold.appBar` (it is a [PreferredSizeWidget]).
class SinewAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SinewAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    this.showBack = false,
    this.closeIcon = false,
    this.onHome,
    this.horizontalPadding,
    this.infoConfig,
    this.overflowConfig,
    this.onBack,
    this.showBrand = true,
    this.background,
    this.search,
  });

  /// Title (titleLarge). Null shows the brand name when [showBrand].
  final String? title;

  /// One line under the title (bodyMedium, onSurfaceVariant).
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;

  /// Draws the back button as a close glyph (full-screen forms).
  final bool closeIcon;

  /// Non-null shows a home button that calls it.
  final VoidCallback? onHome;
  final double? horizontalPadding;
  final SinewInfoConfig? infoConfig;
  final SinewOverflowConfig? overflowConfig;

  /// Overrides the default back behaviour (pop). Used e.g. to clear a
  /// multi-select instead of leaving the screen.
  final VoidCallback? onBack;

  /// When false and [title] is null, renders no brand name.
  final bool showBrand;

  /// Fill behind the header (a contextual header uses surfaceContainer).
  /// Transparent by default.
  final Color? background;

  /// Adds the search button; see [SinewHeaderSearch].
  final SinewHeaderSearch? search;

  static const double _height = Sizes.headerTop + Sizes.headerRow + Space.md;

  @override
  Size get preferredSize => Size.fromHeight(
    subtitle == null ? _height : _height + Sizes.headerSubtitle,
  );

  @override
  State<SinewAppBar> createState() => _SinewAppBarState();
}

class _SinewAppBarState extends State<SinewAppBar> {
  // Starts open when the screen comes back with a query still applied.
  late bool _searching = widget.search?.controller.text.isNotEmpty ?? false;

  void _closeSearch() {
    final SinewHeaderSearch s = widget.search!;
    FocusScope.of(context).unfocus();
    if (s.controller.text.isNotEmpty) {
      s.controller.clear();
      s.onChanged('');
    }
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    final SinewAppBar w = widget;
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final bool hasLeading = w.showBack || w.onHome != null;

    final List<SinewOverflowItem> configItems =
        w.overflowConfig?.items ?? const <SinewOverflowItem>[];
    final SinewInfoConfig? info = w.infoConfig;
    final List<SinewOverflowItem> overflowItems = <SinewOverflowItem>[
      if (info != null)
        SinewOverflowItem(
          icon: Icons.help_outline_rounded,
          label: 'How it works',
          onTap: () => showSinewInfoSheet(context, info),
        ),
      ...configItems.where((SinewOverflowItem i) => !i.isDestructive),
      ...configItems.where((SinewOverflowItem i) => i.isDestructive),
    ];

    final List<Widget> trailing = <Widget>[
      if (w.search != null)
        AppIconButton(
          icon: Icons.search_rounded,
          semanticLabel: w.search!.hint,
          onPressed: () => setState(() => _searching = true),
        ),
      ...?w.actions,
      if (overflowItems.isNotEmpty) SinewOverflowButton(items: overflowItems),
    ];

    Widget? titleWidget;
    if (w.title != null) {
      titleWidget = Semantics(
        header: true,
        child: Text(
          w.title!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tt.titleLarge!.copyWith(color: cs.onSurface),
        ),
      );
    } else if (w.showBrand) {
      titleWidget = Text(
        'Sinew',
        style: tt.titleLarge!.copyWith(color: cs.primary),
      );
    }

    final double left =
        w.horizontalPadding ?? (hasLeading ? Space.lg : Space.screen);
    final double right =
        w.horizontalPadding ?? (trailing.isNotEmpty ? Space.lg : Space.screen);

    final bool searchOpen = _searching && w.search != null;
    return ColoredBox(
      color: w.background ?? Colors.transparent,
      child: SafeArea(
        bottom: false,
        // The bar is laid out at its preferred size, which is for 100% text.
        // At a larger text size the subtitle may need more; it then overlaps
        // the page by a few dp instead of raising an overflow error.
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: 0,
          maxHeight: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              left,
              Sizes.headerTop,
              right,
              w.subtitle == null ? Space.md : Space.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: Sizes.headerRow,
                  child: AnimatedSwitcher(
                    duration: Motion.of(context, Motion.headerSwap),
                    switchInCurve: Motion.decelerate,
                    switchOutCurve: Motion.accelerate,
                    transitionBuilder: (Widget child, Animation<double> a) =>
                        FadeTransition(opacity: a, child: child),
                    child: searchOpen
                        ? _SearchPill(
                            key: const ValueKey<String>('search'),
                            search: w.search!,
                            onClose: _closeSearch,
                          )
                        : Row(
                            key: const ValueKey<String>('bar'),
                            children: <Widget>[
                              if (w.showBack)
                                AppIconButton(
                                  icon: w.closeIcon
                                      ? Icons.close_rounded
                                      : Icons.arrow_back_rounded,
                                  semanticLabel: w.closeIcon ? 'Close' : 'Back',
                                  onPressed:
                                      w.onBack ??
                                      () => Navigator.of(context).maybePop(),
                                ),
                              if (w.onHome != null)
                                AppIconButton(
                                  icon: Icons.home_outlined,
                                  semanticLabel: 'Home',
                                  onPressed: w.onHome,
                                ),
                              if (hasLeading)
                                const SizedBox(width: Sizes.headerGap),
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: titleWidget ?? const SizedBox.shrink(),
                                ),
                              ),
                              ...trailing,
                            ],
                          ),
                  ),
                ),
                if (w.subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(left: hasLeading ? Space.xs : 0),
                    child: Transform.translate(
                      offset: const Offset(0, -Sizes.headerSubtitleLift),
                      child: Text(
                        w.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A large page header for a tab's root screen: a headlineMedium title (28/36
/// w700) with an optional bodyMedium subtitle and trailing actions, in the
/// 20dp screen margin. Scrolls away with the content (put it first in the
/// list). Slots match [SinewAppBar]: [actions], [infoConfig], [overflowConfig].
class SinewPageHeader extends StatelessWidget {
  const SinewPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.infoConfig,
    this.overflowConfig,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final SinewInfoConfig? infoConfig;
  final SinewOverflowConfig? overflowConfig;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final List<SinewOverflowItem> configItems =
        overflowConfig?.items ?? const <SinewOverflowItem>[];
    final SinewInfoConfig? info = infoConfig;
    final List<SinewOverflowItem> overflowItems = <SinewOverflowItem>[
      if (info != null)
        SinewOverflowItem(
          icon: Icons.help_outline_rounded,
          label: 'How it works',
          onTap: () => showSinewInfoSheet(context, info),
        ),
      ...configItems.where((SinewOverflowItem i) => !i.isDestructive),
      ...configItems.where((SinewOverflowItem i) => i.isDestructive),
    ];
    final bool hasTrailing =
        (actions?.isNotEmpty ?? false) || overflowItems.isNotEmpty;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Space.screen,
          Sizes.headerTop,
          hasTrailing ? Space.lg : Space.screen,
          Space.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: tt.headlineMedium!.copyWith(color: cs.onSurface),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: tt.bodyMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            ...?actions,
            if (overflowItems.isNotEmpty)
              SinewOverflowButton(items: overflowItems),
          ],
        ),
      ),
    );
  }
}

/// The open header search: a pill with back (closes search and clears the
/// query), the field, and a clear button while there is text.
class _SearchPill extends StatelessWidget {
  const _SearchPill({super.key, required this.search, required this.onClose});

  final SinewHeaderSearch search;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) onClose();
      },
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: Radii.fullR,
          border: Border.all(color: cs.primary, width: Strokes.focus),
        ),
        child: Row(
          children: <Widget>[
            AppIconButton(
              icon: Icons.arrow_back_rounded,
              kind: AppIconButtonKind.plain,
              semanticLabel: 'Close search',
              onPressed: onClose,
            ),
            Expanded(
              child: TextField(
                controller: search.controller,
                autofocus: search.controller.text.isEmpty,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.search,
                onChanged: search.onChanged,
                style: tt.bodyLarge!.copyWith(color: cs.onSurface),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintText: search.hint,
                  hintStyle: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: search.controller,
              builder: (BuildContext context, TextEditingValue v, Widget? _) =>
                  AnimatedSwitcher(
                    duration: Motion.of(context, Motion.fast),
                    transitionBuilder: (Widget c, Animation<double> a) =>
                        ScaleTransition(scale: a, child: c),
                    child: v.text.isEmpty
                        ? const SizedBox(
                            width: Space.sm,
                            key: ValueKey<String>('none'),
                          )
                        : AppIconButton(
                            key: const ValueKey<String>('clear'),
                            icon: Icons.close_rounded,
                            kind: AppIconButtonKind.plain,
                            semanticLabel: 'Clear',
                            onPressed: () {
                              search.controller.clear();
                              search.onChanged('');
                            },
                          ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The overflow (more_vert) button: tonal while its menu is open. Opens a
/// [showSinewMenu] of [items], with a divider before the first destructive
/// item (or before any item with `dividerBefore`).
class SinewOverflowButton extends StatefulWidget {
  const SinewOverflowButton({super.key, required this.items});

  final List<SinewOverflowItem> items;

  @override
  State<SinewOverflowButton> createState() => _SinewOverflowButtonState();
}

class _SinewOverflowButtonState extends State<SinewOverflowButton> {
  bool _open = false;

  Future<void> _show(BuildContext anchor) async {
    setState(() => _open = true);
    final SinewOverflowItem? picked = await showSinewMenu<SinewOverflowItem>(
      context: anchor,
      entries: <SinewMenuEntry<SinewOverflowItem>>[
        for (
          int i = 0;
          i < widget.items.length;
          i++
        ) ...<SinewMenuEntry<SinewOverflowItem>>[
          // Divider before the first destructive item, if anything precedes it.
          if (i > 0 &&
              (widget.items[i].dividerBefore ||
                  (widget.items[i].isDestructive &&
                      !widget.items[i - 1].isDestructive)))
            const SinewMenuEntry<SinewOverflowItem>.divider(),
          SinewMenuEntry<SinewOverflowItem>(
            value: widget.items[i],
            label: widget.items[i].label,
            icon: widget.items[i].icon,
            destructive: widget.items[i].isDestructive,
            selected: widget.items[i].selected,
          ),
        ],
      ],
    );
    if (mounted) setState(() => _open = false);
    picked?.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext anchor) => AppIconButton(
        icon: Icons.more_vert_rounded,
        semanticLabel: 'More options',
        kind: _open ? AppIconButtonKind.tonal : AppIconButtonKind.standard,
        onPressed: () => _show(anchor),
      ),
    );
  }
}

/// A page whose [header] scrolls away with its content (no sticky headers).
/// Put it in `Scaffold.body` instead of passing the header as `appBar`. The
/// [body]'s scrollable must use the primary scroll controller (no explicit
/// `controller`) so the header and content scroll together.
class SinewScrollAwayHeader extends StatelessWidget {
  const SinewScrollAwayHeader({
    super.key,
    required this.header,
    required this.body,
  });

  final Widget header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext _, bool _) => <Widget>[
        SliverToBoxAdapter(child: header),
      ],
      // The header already consumed the status-bar inset.
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: body,
      ),
    );
  }
}
