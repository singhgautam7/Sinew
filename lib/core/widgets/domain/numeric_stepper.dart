import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../units/units.dart';

/// A minus / value / plus control for weight, reps and seconds.
///
/// Tap a button to step by [step]; hold it to repeat (slow, then fast). Tap
/// the value to type it with the keyboard. The value is clamped to
/// [min]..[max]. [glove] makes the targets 64dp for the active workout.
///
/// For a screen reader the whole control is one adjustable node: the
/// increase and decrease actions step the value and a tap edits it.
class NumericStepper extends StatefulWidget {
  const NumericStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    this.step = 1,
    this.min = 0,
    this.max = double.infinity,
    this.unit,
    this.maxDecimals = 2,
    this.glove = false,
    this.haptics = true,
    this.format,
  });

  final double value;
  final ValueChanged<double> onChanged;

  /// What this value is, for TalkBack ("Weight", "Reps").
  final String semanticLabel;

  /// The increment: 2.5 (kg), 5 (lb), 1 (rep).
  final double step;
  final double min;
  final double max;

  /// Small label under the value ("kg").
  final String? unit;

  /// Decimals shown (and accepted when typing).
  final int maxDecimals;

  /// 64dp targets and a bigger value, for the active workout.
  final bool glove;

  /// A selection click on every step.
  final bool haptics;

  /// Custom value text (for example `mm:ss`). Defaults to a trimmed number.
  final String Function(double value)? format;

  @override
  State<NumericStepper> createState() => _NumericStepperState();
}

class _NumericStepperState extends State<NumericStepper> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _editing = false;
  Timer? _repeat;
  int _repeats = 0;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _repeat?.cancel();
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  String _text(double v) =>
      widget.format?.call(v) ?? Units.trim(v, maxDecimals: widget.maxDecimals);

  double _clamp(double v) {
    final double rounded = double.parse(
      v.toStringAsFixed(StepperSpec.precision),
    );
    return rounded.clamp(widget.min, widget.max);
  }

  bool get _canDecrease => widget.value > widget.min;
  bool get _canIncrease => widget.value < widget.max;

  void _bump(int direction) {
    final double next = _clamp(widget.value + direction * widget.step);
    if (next == widget.value) {
      _repeat?.cancel();
      return;
    }
    if (widget.haptics) HapticFeedback.selectionClick();
    widget.onChanged(next);
  }

  void _startRepeat(int direction) {
    _repeats = 0;
    _bump(direction);
    void tick() {
      _repeats++;
      final Duration d = _repeats > StepperSpec.accelerateAfter
          ? StepperSpec.repeatFast
          : StepperSpec.repeatSlow;
      _repeat = Timer(d, () {
        _bump(direction);
        tick();
      });
    }

    tick();
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  void _startEditing() {
    if (_editing) return;
    _controller.text = _text(widget.value);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    setState(() => _editing = true);
    _focus.requestFocus();
  }

  void _onFocus() {
    if (!_focus.hasFocus && _editing) _commit();
  }

  void _commit() {
    final double? parsed = double.tryParse(
      _controller.text.replaceAll(',', '.'),
    );
    setState(() => _editing = false);
    if (parsed != null) {
      final double next = _clamp(parsed);
      if (next != widget.value) widget.onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double target = widget.glove
        ? StepperSpec.buttonGlove
        : StepperSpec.button;
    final TextStyle valueStyle = widget.glove
        ? context.text.headlineSmall!
        : context.text.titleLarge!;
    final String valueText = _text(widget.value);

    final Widget value = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: widget.glove
            ? StepperSpec.valueMinWidthGlove
            : StepperSpec.valueMinWidth,
        minHeight: target,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _startEditing,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_editing)
              IntrinsicWidth(
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  textAlign: TextAlign.center,
                  style: valueStyle,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: widget.maxDecimals > 0,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _commit(),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              )
            else
              Text(
                valueText,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: valueStyle,
              ),
            if (widget.unit != null)
              Text(
                widget.unit!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall,
              ),
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      value: widget.unit == null ? valueText : '$valueText ${widget.unit}',
      increasedValue: _text(_clamp(widget.value + widget.step)),
      decreasedValue: _text(_clamp(widget.value - widget.step)),
      onIncrease: _canIncrease ? () => _bump(1) : null,
      onDecrease: _canDecrease ? () => _bump(-1) : null,
      onTap: _startEditing,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ExcludeSemantics(
            child: _StepButton(
              key: const ValueKey<String>('stepper-minus'),
              icon: Icons.remove_rounded,
              size: target,
              enabled: _canDecrease,
              primary: false,
              glove: widget.glove,
              onStart: () => _startRepeat(-1),
              onStop: _stopRepeat,
              onTap: () => _bump(-1),
            ),
          ),
          Flexible(child: value),
          ExcludeSemantics(
            child: _StepButton(
              key: const ValueKey<String>('stepper-plus'),
              icon: Icons.add_rounded,
              size: target,
              enabled: _canIncrease,
              primary: true,
              glove: widget.glove,
              onStart: () => _startRepeat(1),
              onStop: _stopRepeat,
              onTap: () => _bump(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatefulWidget {
  const _StepButton({
    super.key,
    required this.icon,
    required this.size,
    required this.enabled,
    required this.primary,
    required this.glove,
    required this.onStart,
    required this.onStop,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final bool enabled;
  final bool primary;
  final bool glove;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onTap;

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final Color bg = widget.primary ? cs.primary : cs.surfaceContainerHigh;
    final Color fg = widget.primary ? cs.onPrimary : cs.onSurface;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => _set(true) : null,
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.enabled ? widget.onTap : null,
      onLongPressStart: widget.enabled
          ? (_) {
              _set(true);
              widget.onStart();
            }
          : null,
      onLongPressEnd: (_) {
        _set(false);
        widget.onStop();
      },
      onLongPressCancel: () {
        _set(false);
        widget.onStop();
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: AnimatedOpacity(
            duration: Motion.of(context, Motion.instant),
            opacity: !widget.enabled
                ? Opacities.disabled
                : (_pressed ? Opacities.muted : 1),
            child: DecoratedBox(
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: SizedBox(
                width: widget.size - Space.sm,
                height: widget.size - Space.sm,
                child: Icon(
                  widget.icon,
                  size: widget.glove
                      ? StepperSpec.glyphGlove
                      : StepperSpec.glyph,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
