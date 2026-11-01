import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'app_icon_button.dart';

/// One labelled section of a form: a caps heading (and an optional sublabel
/// and trailing widget) over its children, joined by a 12dp gap. With [tinted]
/// the section sits inside a bordered card.
class SinewFormSection extends StatelessWidget {
  const SinewFormSection({
    super.key,
    required this.label,
    this.sublabel,
    this.trailing,
    this.tinted = false,
    this.topGap = Space.xl,
    required this.children,
  });

  final String label;
  final String? sublabel;
  final Widget? trailing;
  final bool tinted;
  final double topGap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: Space.sectionHeaderGap),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: Text(
                        label.toUpperCase(),
                        style: context.sectionHeader,
                      ),
                    ),
                    if (sublabel != null) ...<Widget>[
                      const SizedBox(height: Space.xxs),
                      Text(
                        sublabel!,
                        style: context.text.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: Space.md),
          children[i],
        ],
      ],
    );

    final Widget wrapped = tinted
        ? Container(
            padding: const EdgeInsets.all(Space.cardPadding),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: Radii.cardR,
              border: Border.all(color: cs.outlineVariant),
            ),
            child: body,
          )
        : body;

    return Padding(
      padding: EdgeInsets.only(top: topGap),
      child: wrapped,
    );
  }
}

/// Small label that sits 6dp above a field. [optional] appends " · optional"
/// in muted weight.
class SinewFieldLabel extends StatelessWidget {
  const SinewFieldLabel(this.text, {super.key, this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Padding(
      padding: const EdgeInsets.only(
        left: Space.xxs,
        bottom: Space.xs + Space.xxs,
        top: Space.xxs,
      ),
      child: Text.rich(
        TextSpan(
          text: text,
          children: optional
              ? <InlineSpan>[
                  TextSpan(
                    text: '  · optional',
                    style: tt.labelSmall!.copyWith(
                      color: cs.onSurfaceVariant.withValues(
                        alpha: Opacities.muted,
                      ),
                    ),
                  ),
                ]
              : null,
          style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// The "i" after a label: an outlined info glyph that opens an explainer, with
/// a 48dp touch target.
class SinewInfoGlyph extends StatelessWidget {
  const SinewInfoGlyph({super.key, required this.onTap, this.color});

  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: Icons.info_outline_rounded,
      kind: AppIconButtonKind.plain,
      semanticLabel: 'More information',
      glyphSize: Sizes.infoGlyph,
      tint: color ?? context.cs.onSurfaceVariant,
      onPressed: onTap,
    );
  }
}

/// A labelled text field in the app's filled style (the theme's input
/// decoration): a label row above (with an optional info glyph), then the
/// field. Use [SinewTextField.number] for decimals and integers.
class SinewTextField extends StatelessWidget {
  const SinewTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixText,
    this.suffixText,
    this.suffix,
    this.errorText,
    this.helperText,
    this.optional = false,
    this.onInfo,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.enabled = true,
    this.showLabel = true,
    this.maxLines = 1,
  });

  /// A numeric field (weight, reps, a measurement): digits and one decimal
  /// point when [decimal], digits only otherwise. [suffixText] is the unit.
  factory SinewTextField.number({
    Key? key,
    required String label,
    required TextEditingController controller,
    String? hint,
    String? suffixText,
    String? errorText,
    String? helperText,
    VoidCallback? onInfo,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    bool decimal = true,
    bool optional = false,
    bool showLabel = true,
    bool enabled = true,
    TextInputAction? textInputAction,
  }) => SinewTextField(
    key: key,
    label: label,
    controller: controller,
    hint: hint,
    suffixText: suffixText,
    errorText: errorText,
    helperText: helperText,
    onInfo: onInfo,
    onChanged: onChanged,
    focusNode: focusNode,
    optional: optional,
    showLabel: showLabel,
    enabled: enabled,
    textInputAction: textInputAction,
    keyboardType: TextInputType.numberWithOptions(decimal: decimal),
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.]' : r'[0-9]')),
    ],
  );

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? prefixText;
  final String? suffixText;
  final Widget? suffix;
  final String? errorText;
  final String? helperText;
  final bool optional;
  final VoidCallback? onInfo;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final bool enabled;

  /// False draws the field alone (the label is then the field's hint).
  final bool showLabel;
  final int maxLines;

  /// Error / helper text may wrap to this many lines.
  static const int _supportLines = 3;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    final Widget field = TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      maxLines: maxLines,
      onChanged: onChanged,
      onTapOutside: (PointerDownEvent _) =>
          FocusManager.instance.primaryFocus?.unfocus(),
      style: tt.bodyLarge!.copyWith(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hint ?? (showLabel ? null : label),
        prefixText: prefixText,
        prefixStyle: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
        suffixText: suffixText,
        suffixStyle: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
        suffixIcon: suffix,
        errorText: errorText,
        errorMaxLines: _supportLines,
        helperText: helperText,
        helperMaxLines: _supportLines,
      ),
    );
    if (!showLabel) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(child: SinewFieldLabel(label, optional: optional)),
            if (onInfo != null) SinewInfoGlyph(onTap: onInfo!),
          ],
        ),
        field,
      ],
    );
  }
}

/// A "tap to open a sheet" row: a 40 leading slot, the current value as
/// titleMedium and the label under it, a chevron (or a clear button when
/// [clearable]). A 72 high bordered card.
class SinewPickerRow extends StatelessWidget {
  const SinewPickerRow({
    super.key,
    required this.leading,
    required this.label,
    required this.value,
    required this.onTap,
    this.valueIsPlaceholder = false,
    this.clearable = false,
    this.onClear,
  });

  final Widget leading;
  final String label;
  final String value;
  final bool valueIsPlaceholder;
  final VoidCallback onTap;
  final bool clearable;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Semantics(
      button: true,
      label: '$label, $value',
      excludeSemantics: !(clearable && onClear != null),
      onTap: onTap,
      child: Material(
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardR,
          side: BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            onTap();
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: Space.listItem2),
            padding: const EdgeInsets.fromLTRB(
              Space.lg,
              Space.sm,
              Space.md,
              Space.sm,
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: Sizes.pickerRowLeading,
                  height: Sizes.pickerRowLeading,
                  child: leading,
                ),
                const SizedBox(width: Space.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium!.copyWith(
                          color: valueIsPlaceholder
                              ? cs.onSurfaceVariant
                              : cs.onSurface,
                        ),
                      ),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (clearable && onClear != null)
                  AppIconButton(
                    icon: Icons.cancel_rounded,
                    kind: AppIconButtonKind.plain,
                    semanticLabel: 'Clear $label',
                    onPressed: onClear,
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant,
                    size: IconSpec.glyph,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum SinewCalloutTone { info, warning, error, success }

/// Notice block: info = secondaryContainer, warning = warningContainer,
/// error = errorContainer, success = successContainer. An optional trailing
/// "i" opens an explainer.
class SinewCallout extends StatelessWidget {
  const SinewCallout({
    super.key,
    required this.child,
    this.tone = SinewCalloutTone.warning,
    this.icon,
    this.onInfo,
  });

  /// Plain text notice.
  factory SinewCallout.text(
    String text, {
    Key? key,
    SinewCalloutTone tone = SinewCalloutTone.info,
    IconData? icon,
    VoidCallback? onInfo,
  }) => SinewCallout(
    key: key,
    tone: tone,
    icon: icon,
    onInfo: onInfo,
    child: Text(text),
  );

  final Widget child;
  final SinewCalloutTone tone;
  final IconData? icon;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    final SinewColors c = context.colors;
    final ColorScheme cs = context.cs;
    final (Color bg, Color fg, IconData glyph) = switch (tone) {
      SinewCalloutTone.info => (
        cs.secondaryContainer,
        cs.onSecondaryContainer,
        Icons.info_rounded,
      ),
      SinewCalloutTone.warning => (
        c.warningContainer,
        c.onWarningContainer,
        Icons.error_outline_rounded,
      ),
      SinewCalloutTone.error => (
        cs.errorContainer,
        cs.onErrorContainer,
        Icons.block_rounded,
      ),
      SinewCalloutTone.success => (
        c.successContainer,
        c.onSuccessContainer,
        Icons.check_circle_rounded,
      ),
    };
    return Container(
      padding: EdgeInsets.fromLTRB(
        Space.lg,
        Space.md,
        onInfo != null ? Space.xs : Space.lg,
        Space.md,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: Radii.largeR),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: Space.xxs / 2, right: Space.md),
            child: ExcludeSemantics(
              child: Icon(icon ?? glyph, size: IconSpec.glyph, color: fg),
            ),
          ),
          Expanded(
            child: DefaultTextStyle.merge(
              style: context.text.bodyMedium!.copyWith(color: fg),
              child: child,
            ),
          ),
          if (onInfo != null) SinewInfoGlyph(onTap: onInfo!, color: fg),
        ],
      ),
    );
  }
}
