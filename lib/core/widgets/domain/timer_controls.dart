import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

/// The control row under a running timer: lock, +10s, the big pause / play,
/// skip and optionally previous and stop.
///
/// Colours come from the phase ([phase]'s on colour for the controls and its
/// field colour for the glyph on the primary), so they work on any field,
/// AMOLED included. The primary is a 96dp squircle that morphs to a full
/// circle when [paused]; secondaries are 64dp.
///
/// While [locked] everything is disabled except the lock, which unlocks
/// only after a one-second hold (a ring fills under the finger). A screen
/// reader gets a plain "Unlock" action instead of the hold.
class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
    required this.phase,
    required this.paused,
    required this.onPlayPause,
    this.locked = false,
    this.onLock,
    this.onUnlock,
    this.onAddTime,
    this.addSeconds = 10,
    this.onSkip,
    this.onPrevious,
    this.onStop,
    this.showLabels = false,
    this.haptics = true,
  });

  final SinewPhase phase;
  final bool paused;
  final VoidCallback onPlayPause;
  final bool locked;

  /// Shows the lock button when either lock callback is given.
  final VoidCallback? onLock;
  final VoidCallback? onUnlock;

  /// "+10s". Null hides the button.
  final VoidCallback? onAddTime;
  final int addSeconds;
  final VoidCallback? onSkip;
  final VoidCallback? onPrevious;
  final VoidCallback? onStop;

  /// Small captions under the controls (the Components frame).
  final bool showLabels;
  final bool haptics;

  @override
  Widget build(BuildContext context) {
    final PhaseColor colors = context.accents.phase(phase);
    final bool hasLock = onLock != null || onUnlock != null;

    final List<Widget> items = <Widget>[
      if (hasLock)
        _Labelled(
          label: locked ? 'Locked' : 'Lock',
          show: showLabels,
          color: colors.on,
          child: _LockButton(
            colors: colors,
            locked: locked,
            onLock: onLock,
            onUnlock: onUnlock,
            haptics: haptics,
          ),
        ),
      if (onPrevious != null)
        _Labelled(
          label: 'Previous',
          show: showLabels,
          color: colors.on,
          child: _RoundControl(
            semanticLabel: 'Previous',
            colors: colors,
            enabled: !locked,
            onTap: onPrevious,
            child: const Icon(
              Icons.skip_previous_rounded,
              size: TimerSpec.secondaryIcon,
            ),
          ),
        ),
      if (onAddTime != null)
        _Labelled(
          label: 'Add',
          show: showLabels,
          color: colors.on,
          child: _RoundControl(
            semanticLabel: 'Add $addSeconds seconds',
            colors: colors,
            enabled: !locked,
            onTap: onAddTime,
            child: Text(
              '+${addSeconds}s',
              maxLines: 1,
              style: context.text.titleMedium!.copyWith(
                fontSize: TimerSpec.addFont,
                fontWeight: FontWeight.w700,
                color: colors.on,
              ),
            ),
          ),
        ),
      _Labelled(
        label: paused ? 'Resume' : 'Pause',
        show: showLabels,
        color: colors.on,
        child: _PrimaryControl(
          colors: colors,
          paused: paused,
          enabled: !locked,
          onTap: onPlayPause,
          haptics: haptics,
        ),
      ),
      if (onSkip != null)
        _Labelled(
          label: 'Skip',
          show: showLabels,
          color: colors.on,
          child: _RoundControl(
            semanticLabel: 'Skip',
            colors: colors,
            enabled: !locked,
            onTap: onSkip,
            child: const Icon(
              Icons.skip_next_rounded,
              size: TimerSpec.secondaryIcon,
            ),
          ),
        ),
      if (onStop != null)
        _Labelled(
          label: 'Stop',
          show: showLabels,
          color: colors.on,
          child: _RoundControl(
            semanticLabel: 'Stop',
            colors: colors,
            enabled: !locked,
            onTap: onStop,
            child: const Icon(
              Icons.stop_rounded,
              size: TimerSpec.secondaryIcon,
            ),
          ),
        ),
    ];

    return Wrap(
      alignment: WrapAlignment.spaceAround,
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: Space.xs,
      runSpacing: TimerSpec.controlsGap,
      children: items,
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({
    required this.label,
    required this.show,
    required this.color,
    required this.child,
  });

  final String label;
  final bool show;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!show) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        child,
        const SizedBox(height: TimerSpec.labelGap),
        ExcludeSemantics(
          child: Text(
            label,
            maxLines: 1,
            style: context.text.labelMedium!.copyWith(
              fontSize: TimerSpec.labelFont,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// A 64dp circle in the phase's on colour at 12%.
class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.semanticLabel,
    required this.colors,
    required this.enabled,
    required this.onTap,
    required this.child,
  });

  final String semanticLabel;
  final PhaseColor colors;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool live = enabled && onTap != null;
    return Semantics(
      button: true,
      enabled: live,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: live ? onTap : null,
      child: Opacity(
        opacity: live ? 1 : Opacities.disabled,
        child: Material(
          color: colors.on.withValues(alpha: TimerSpec.secondaryFillOpacity),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkResponse(
            onTap: live ? onTap : null,
            containedInkWell: true,
            highlightShape: BoxShape.circle,
            child: SizedBox(
              width: SinewSpace.gloveTarget,
              height: SinewSpace.gloveTarget,
              child: IconTheme.merge(
                data: IconThemeData(color: colors.on),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The 96dp pause / play: a squircle that becomes a circle when paused.
class _PrimaryControl extends StatelessWidget {
  const _PrimaryControl({
    required this.colors,
    required this.paused,
    required this.enabled,
    required this.onTap,
    required this.haptics,
  });

  final PhaseColor colors;
  final bool paused;
  final bool enabled;
  final VoidCallback onTap;
  final bool haptics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: paused ? 'Resume' : 'Pause',
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : Opacities.disabled,
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.navIndicator),
          curve: Motion.curveOf(context, Motion.spring),
          width: SinewSpace.timerControl,
          height: SinewSpace.timerControl,
          decoration: BoxDecoration(
            color: colors.on,
            borderRadius: BorderRadius.circular(
              paused ? SinewSpace.timerControl / 2 : SinewShape.timerPrimary,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            type: MaterialType.transparency,
            child: InkResponse(
              onTap: enabled
                  ? () {
                      if (haptics) HapticFeedback.mediumImpact();
                      onTap();
                    }
                  : null,
              containedInkWell: true,
              highlightShape: BoxShape.rectangle,
              child: Center(
                child: AnimatedSwitcher(
                  duration: Motion.of(context, Motion.fast),
                  child: Icon(
                    paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    key: ValueKey<bool>(paused),
                    size: TimerSpec.primaryIcon,
                    color: colors.field,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lock / unlock. Unlocked: a tap locks. Locked: hold for a second.
class _LockButton extends StatefulWidget {
  const _LockButton({
    required this.colors,
    required this.locked,
    required this.onLock,
    required this.onUnlock,
    required this.haptics,
  });

  final PhaseColor colors;
  final bool locked;
  final VoidCallback? onLock;
  final VoidCallback? onUnlock;
  final bool haptics;

  @override
  State<_LockButton> createState() => _LockButtonState();
}

class _LockButtonState extends State<_LockButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hold;

  @override
  void initState() {
    super.initState();
    _hold = AnimationController(vsync: this, duration: TimerSpec.holdToUnlock)
      ..addStatusListener((AnimationStatus s) {
        if (s == AnimationStatus.completed) {
          if (widget.haptics) HapticFeedback.lightImpact();
          widget.onUnlock?.call();
          _hold.value = 0;
        }
      });
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_LockButton old) {
    super.didUpdateWidget(old);
    if (!widget.locked) _hold.value = 0;
  }

  void _down(PointerDownEvent _) {
    if (widget.locked && widget.onUnlock != null) _hold.forward();
  }

  void _up(PointerEvent _) {
    if (_hold.status != AnimationStatus.completed) _hold.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final PhaseColor c = widget.colors;
    final bool locked = widget.locked;
    final bool live = locked ? widget.onUnlock != null : widget.onLock != null;
    return Semantics(
      button: true,
      enabled: live,
      label: locked ? 'Unlock' : 'Lock',
      hint: locked ? 'Hold for one second to unlock' : null,
      excludeSemantics: true,
      onTap: !locked && live
          ? () {
              if (widget.haptics) HapticFeedback.lightImpact();
              widget.onLock!();
            }
          : null,
      onLongPress: locked && live ? widget.onUnlock : null,
      child: Listener(
        onPointerDown: _down,
        onPointerUp: _up,
        onPointerCancel: _up,
        child: Padding(
          padding: const EdgeInsets.all(TimerSpec.lockHalo),
          child: AnimatedBuilder(
            animation: _hold,
            builder: (BuildContext context, Widget? _) {
              return CustomPaint(
                foregroundPainter: _HoldPainter(
                  progress: _hold.value,
                  color: c.field,
                  stroke: TimerSpec.lockHoldStroke,
                ),
                child: Container(
                  width: SinewSpace.gloveTarget,
                  height: SinewSpace.gloveTarget,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: locked
                        ? c.on
                        : c.on.withValues(
                            alpha: TimerSpec.secondaryFillOpacity,
                          ),
                    boxShadow: locked
                        ? <BoxShadow>[
                            BoxShadow(
                              color: c.on.withValues(
                                alpha: TimerSpec.lockHaloOpacity,
                              ),
                              spreadRadius: TimerSpec.lockHalo,
                            ),
                          ]
                        : null,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: !locked && live
                        ? () {
                            if (widget.haptics) HapticFeedback.lightImpact();
                            widget.onLock!();
                          }
                        : null,
                    child: Icon(
                      locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                      size: TimerSpec.secondaryIcon,
                      color: locked ? c.field : c.on,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HoldPainter extends CustomPainter {
  const _HoldPainter({
    required this.progress,
    required this.color,
    required this.stroke,
  });

  final double progress;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final Rect rect = (Offset.zero & size).deflate(stroke);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_HoldPainter old) =>
      old.progress != progress || old.color != color;
}

/// The AMRAP round counter: a big tonal surface that adds a round wherever
/// it is tapped, with an Undo pill. [phase] picks the colours.
class AmrapCounter extends StatelessWidget {
  const AmrapCounter({
    super.key,
    required this.phase,
    required this.rounds,
    required this.onAdd,
    required this.onUndo,
    this.haptics = true,
  });

  final SinewPhase phase;
  final int rounds;
  final VoidCallback onAdd;

  /// Takes a round back. Disabled at zero.
  final VoidCallback onUndo;
  final bool haptics;

  @override
  Widget build(BuildContext context) {
    final PhaseColor c = context.accents.phase(phase);
    final TextTheme tt = context.text;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          button: true,
          label: 'Add a round',
          value: '$rounds ${rounds == 1 ? 'round' : 'rounds'}',
          excludeSemantics: true,
          onTap: onAdd,
          child: Material(
            color: c.on,
            borderRadius: BorderRadius.circular(TimerSpec.amrapRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                if (haptics) HapticFeedback.lightImpact();
                onAdd();
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: TimerSpec.amrapMinHeight,
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(Space.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Rounds',
                            style: tt.titleLarge!.copyWith(color: c.field),
                          ),
                          Text(
                            '$rounds',
                            style: context.timerNumeral.copyWith(
                              fontSize: TimerSpec.amrapFont,
                              letterSpacing: TimerSpec.amrapTracking,
                              color: c.field,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.touch_app_rounded,
                                size: IconSpec.size,
                                color: c.field,
                              ),
                              const SizedBox(width: Space.xs),
                              Text(
                                'Tap anywhere here',
                                style: tt.titleMedium!.copyWith(
                                  fontSize: TimerSpec.nextFont,
                                  color: c.field,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            button: true,
            enabled: rounds > 0,
            label: 'Undo last round',
            excludeSemantics: true,
            onTap: rounds > 0 ? onUndo : null,
            child: Opacity(
              opacity: rounds > 0 ? 1 : Opacities.disabled,
              child: Material(
                color: c.on.withValues(alpha: TimerSpec.secondaryFillOpacity),
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: rounds > 0 ? onUndo : null,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: SinewSpace.gloveTarget,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.xl),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.undo_rounded,
                            size: IconSpec.size,
                            color: c.on,
                          ),
                          const SizedBox(width: Space.sm),
                          Text(
                            'Undo',
                            style: tt.titleMedium!.copyWith(color: c.on),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
