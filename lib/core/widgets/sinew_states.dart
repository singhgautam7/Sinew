import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_button.dart';

/// An empty list or screen: a 72dp tonal circle with a glyph, a title, a
/// description and an optional action button ("New routine").
class SinewEmptyState extends StatelessWidget {
  const SinewEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionIcon = Icons.add_rounded,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;

  /// Both [actionLabel] and [onAction] are needed to show the button.
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.xxl,
          vertical: Space.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ExcludeSemantics(
              child: Container(
                width: Sizes.emptyIcon,
                height: Sizes.emptyIcon,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: cs.onSecondaryContainer,
                  size: Sizes.emptyGlyph,
                ),
              ),
            ),
            const SizedBox(height: Space.md),
            Text(
              title,
              style: tt.titleMedium!.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Space.xs),
            Text(
              description,
              style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: Space.lg),
              AppButton(
                label: actionLabel!,
                icon: actionIcon,
                type: AppButtonType.primary,
                height: Sizes.buttonSmall,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A muted rounded rectangle that pulses opacity (no shimmer sweep): the one
/// loading primitive. Under reduced motion it holds still at full opacity.
class SinewSkeleton extends StatefulWidget {
  const SinewSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = Radii.medium,
  });

  /// Null fills the available width.
  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SinewSkeleton> createState() => _SinewSkeletonState();
}

class _SinewSkeletonState extends State<SinewSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Motion.skeletonPulse);
    _opacity = Tween<double>(
      begin: 1,
      end: Opacities.skeletonLow,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Motion.standard));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _ctrl.stop();
      _ctrl.value = 0;
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (BuildContext context, Widget? _) => Opacity(
          opacity: _opacity.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        ),
      ),
    );
  }
}

/// A loading list row: a thumbnail block and two text bars, matching the
/// exercise list row (min 72, thumbnail 48).
class SinewSkeletonRow extends StatelessWidget {
  const SinewSkeletonRow({super.key, this.thumbnail = true});

  final bool thumbnail;

  /// Text bar sizes as a fraction of the available width.
  static const double _titleBar = 0.6;
  static const double _metaBar = 0.4;
  static const double _titleHeight = 14;
  static const double _metaHeight = 12;
  static const double _thumb = 48;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: Space.listItem2),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.row,
      ),
      child: Row(
        children: <Widget>[
          if (thumbnail) ...<Widget>[
            const SinewSkeleton(
              width: _thumb,
              height: _thumb,
              borderRadius: Radii.thumb,
            ),
            const SizedBox(width: Space.md),
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FractionallySizedBox(
                  widthFactor: _titleBar,
                  child: SinewSkeleton(
                    height: _titleHeight,
                    borderRadius: Radii.extraSmall,
                  ),
                ),
                SizedBox(height: Space.sm),
                FractionallySizedBox(
                  widthFactor: _metaBar,
                  child: SinewSkeleton(
                    height: _metaHeight,
                    borderRadius: Radii.extraSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A loading card: a bordered card holding [lines] bars of decreasing width.
class SinewSkeletonCard extends StatelessWidget {
  const SinewSkeletonCard({super.key, this.lines = 3, this.height});

  final int lines;

  /// Overrides the intrinsic height.
  final double? height;

  static const double _bar = 14;
  static const double _step = 0.2;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Container(
      height: height,
      padding: const EdgeInsets.all(Space.cardPadding),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: Radii.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < lines; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: Space.md),
            FractionallySizedBox(
              widthFactor: 1 - i * _step,
              child: const SinewSkeleton(height: _bar),
            ),
          ],
        ],
      ),
    );
  }
}

/// A modal loader: a spinner and a label in a bordered card. Show it with
/// `showDialog` for work the user must wait for.
class SinewLoader extends StatelessWidget {
  const SinewLoader({super.key, this.label = 'Loading'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    return Dialog(
      elevation: Elevations.none,
      child: Semantics(
        liveRegion: true,
        label: label,
        child: Container(
          padding: const EdgeInsets.all(Space.xl),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: Radii.cardR,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: Sizes.loaderSpinner,
                height: Sizes.loaderSpinner,
                child: CircularProgressIndicator(
                  color: cs.primary,
                  strokeWidth: Strokes.spinnerLarge,
                ),
              ),
              const SizedBox(height: Space.lg),
              Text(
                label,
                textAlign: TextAlign.center,
                style: context.text.titleSmall!.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders nothing for [delay] (250 ms by default) and then [child]. Wrap a
/// loading indicator in it so a load that finishes quickly never flashes one.
class Delayed extends StatefulWidget {
  const Delayed({
    super.key,
    required this.child,
    this.delay = Motion.loadDelay,
  });

  final Widget child;
  final Duration delay;

  @override
  State<Delayed> createState() => _DelayedState();
}

class _DelayedState extends State<Delayed> {
  Timer? _timer;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _show ? widget.child : const SizedBox.shrink();
}
