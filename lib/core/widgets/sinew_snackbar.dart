import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// OverlayEntry-based snackbar.
//
// Using an OverlayEntry (instead of a route) means the snackbar never sits on
// any Navigator's stack, so the Android back button does not dismiss it. It
// stays until its timer expires, it is swiped away or the close button is
// tapped. One at a time: showing a new one replaces the old.

OverlayEntry? _currentEntry;
_SnackController? _currentController;
Timer? _currentTimer;

void _dismissCurrent() {
  _currentTimer?.cancel();
  _currentTimer = null;
  final _SnackController? controller = _currentController;
  final OverlayEntry? entry = _currentEntry;
  _currentController = null;
  _currentEntry = null;
  if (controller != null && entry != null) {
    // Bounded: with the app in the background no frames run, so the slide out
    // may never finish and the entry would be left on screen for good.
    controller
        .animateOut()
        .timeout(Motion.snackEnter * 2, onTimeout: () {})
        .then((_) {
          // Safe even if the entry never got a frame (shown and replaced in
          // one go): remove() is a no-op once it has left the overlay.
          entry.remove();
        });
  } else {
    entry?.remove();
  }
}

/// Shows a snackbar at the top of the screen: [message], an optional text
/// action ([actionLabel] + [onAction], e.g. "Undo"), a close button and a
/// 4dp timer bar. Success sits on surfaceContainerHigh with a primary accent;
/// [isError] uses errorContainer. Swipe in any direction to dismiss.
///
/// Callers that only hold a root-navigator context can pass [overlay]
/// directly. The action runs after the snackbar has closed.
void showSinewSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
  OverlayState? overlay,
}) {
  _dismissCurrent();
  final OverlayState resolved =
      overlay ??
      (context is StatefulElement && context.state is NavigatorState
          ? (context.state as NavigatorState).overlay
          : null) ??
      Overlay.of(context, rootOverlay: true);
  final _SnackController controller = _SnackController();
  final Duration life = duration ?? Motion.snackLife;
  final OverlayEntry entry = OverlayEntry(
    builder: (_) => _SnackBarWidget(
      controller: controller,
      message: message,
      isError: isError,
      actionLabel: actionLabel,
      onAction: onAction,
      onRequestClose: _dismissCurrent,
      duration: life,
    ),
  );
  _currentController = controller;
  _currentEntry = entry;
  resolved.insert(entry);
  _currentTimer = Timer(life, _dismissCurrent);
}

/// A snackbar with an "Undo" action: the standard answer to a delete.
void showSinewUndoSnackBar(
  BuildContext context,
  String message, {
  required VoidCallback onUndo,
  Duration? duration,
}) => showSinewSnackBar(
  context,
  message,
  actionLabel: 'Undo',
  onAction: onUndo,
  duration: duration,
);

/// Removes the current snackbar, if any, without animation. For tests and for
/// screens that are torn down.
void hideSinewSnackBar() {
  _currentTimer?.cancel();
  _currentTimer = null;
  final OverlayEntry? entry = _currentEntry;
  _currentEntry = null;
  _currentController = null;
  entry?.remove();
}

class _SnackController {
  _SnackBarWidgetState? _state;

  void _attach(_SnackBarWidgetState state) => _state = state;

  Future<void> animateOut() async {
    final _SnackBarWidgetState? state = _state;
    if (state == null) return;
    await state._animateOut();
  }
}

class _SnackBarWidget extends StatefulWidget {
  const _SnackBarWidget({
    required this.controller,
    required this.message,
    required this.isError,
    required this.onRequestClose,
    required this.duration,
    this.actionLabel,
    this.onAction,
  });

  final _SnackController controller;
  final String message;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onRequestClose;
  final Duration duration;

  @override
  State<_SnackBarWidget> createState() => _SnackBarWidgetState();
}

class _SnackBarWidgetState extends State<_SnackBarWidget>
    with TickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final Animation<double> _slideAnim;
  late final AnimationController _timerCtrl;
  bool _actionFired = false;

  // Drag-to-dismiss state in logical pixels. Vertical only upward, since the
  // snackbar lives at the top of the screen.
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(vsync: this, duration: Motion.snackEnter);
    _slideAnim = CurvedAnimation(parent: _slideCtrl, curve: Motion.decelerate);
    _timerCtrl = AnimationController(vsync: this, duration: widget.duration);
    widget.controller._attach(this);
    _slideCtrl.forward();
    _timerCtrl.forward();
  }

  Future<void> _animateOut() async {
    if (!mounted) return;
    _timerCtrl.stop();
    await _slideCtrl.reverse();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _timerCtrl.dispose();
    super.dispose();
  }

  void _handleAction(VoidCallback? cb) {
    if (_actionFired) return;
    _actionFired = true;
    widget.onRequestClose();
    cb?.call();
  }

  void _onDragStart(DragStartDetails _) {
    // Pause the auto-dismiss timer once a drag begins, or the snackbar can
    // disappear mid-swipe.
    _timerCtrl.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      final double dx = _dragOffset.dx + details.delta.dx;
      final double dy = (_dragOffset.dy + details.delta.dy).clamp(
        -Sizes.snackDragFade,
        0.0,
      );
      _dragOffset = Offset(dx, dy);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final Offset v = details.velocity.pixelsPerSecond;
    final bool distanceMet =
        _dragOffset.dx.abs() >= Sizes.snackSwipeDistance ||
        _dragOffset.dy <= -Sizes.snackSwipeDistance;
    final bool velocityMet =
        v.dx.abs() >= Sizes.snackSwipeVelocity ||
        v.dy <= -Sizes.snackSwipeVelocity;
    if (distanceMet || velocityMet) {
      widget.onRequestClose();
      return;
    }
    setState(() => _dragOffset = Offset.zero);
    _timerCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final Color bg = widget.isError
        ? cs.errorContainer
        : cs.surfaceContainerHigh;
    final Color fg = widget.isError ? cs.onErrorContainer : cs.onSurface;
    final Color accent = widget.isError ? cs.error : cs.primary;
    final double topPadding = MediaQuery.of(context).padding.top;
    final bool reduced = Motion.reduced(context);

    return Positioned(
      top: topPadding + Space.sm,
      left: Space.screen,
      right: Space.screen,
      child: AnimatedBuilder(
        animation: _slideAnim,
        builder: (BuildContext context, Widget? child) {
          final double t = _slideAnim.value;
          final Offset entryOffset = reduced
              ? Offset.zero
              : Offset(0, (1 - t) * -Sizes.snackEnterTravel);
          final double dragFade = (_dragOffset.distance / Sizes.snackDragFade)
              .clamp(0.0, 0.5);
          return Transform.translate(
            offset: entryOffset + _dragOffset,
            child: Opacity(
              opacity: (t * (1 - dragFade)).clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onVerticalDragStart: _onDragStart,
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          child: _body(context, bg, fg, accent),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, Color bg, Color fg, Color accent) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Semantics(
      liveRegion: true,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.largeR,
          side: BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: Sizes.snackMinHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.xs,
                  Space.xs,
                  Space.xs,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      widget.isError
                          ? Icons.error_rounded
                          : Icons.check_circle_rounded,
                      color: accent,
                      size: IconSpec.glyph,
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Space.row,
                        ),
                        child: Text(
                          widget.message,
                          style: tt.bodyMedium!.copyWith(color: fg),
                        ),
                      ),
                    ),
                    if (widget.actionLabel != null)
                      TextButton(
                        onPressed: () => _handleAction(widget.onAction),
                        style: TextButton.styleFrom(
                          foregroundColor: accent,
                          minimumSize: const Size(
                            IconSpec.tapTarget,
                            IconSpec.tapTarget,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.sm,
                          ),
                        ),
                        child: Text(widget.actionLabel!),
                      ),
                    SizedBox(
                      width: IconSpec.tapTarget,
                      height: IconSpec.tapTarget,
                      child: IconButton(
                        tooltip: 'Dismiss',
                        icon: const Icon(
                          Icons.close_rounded,
                          size: IconSpec.glyph,
                        ),
                        color: fg,
                        onPressed: widget.onRequestClose,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                0,
                Space.lg,
                Space.row,
              ),
              child: AnimatedBuilder(
                animation: _timerCtrl,
                builder: (BuildContext context, Widget? _) {
                  return SizedBox(
                    height: Sizes.snackTimer,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _TimerPainter(
                        value: 1.0 - _timerCtrl.value,
                        indicator: accent,
                        track: fg.withValues(alpha: Opacities.track),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The snackbar timer: flat 4dp indicator and track with a 4dp gap and round
/// ends (M3 2024 linear, without the stop dot).
class _TimerPainter extends CustomPainter {
  _TimerPainter({
    required this.value,
    required this.indicator,
    required this.track,
  });

  final double value;
  final Color indicator;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final Radius r = Radius.circular(h / 2);
    final double v = value.clamp(0.0, 1.0);
    final double gap = h / 2;
    final double indW = v * size.width - (v < 1 ? gap : 0);
    if (indW > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, indW, h), r),
        Paint()..color = indicator,
      );
    }
    final double trackX = indW > 0 ? indW + h : 0.0;
    if (trackX < size.width) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(trackX, 0, size.width - trackX, h),
          r,
        ),
        Paint()..color = track,
      );
    }
  }

  @override
  bool shouldRepaint(_TimerPainter o) =>
      o.value != value || o.indicator != indicator || o.track != track;
}
