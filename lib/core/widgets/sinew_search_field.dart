import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The pill search field of the library and the exercise picker: a search
/// glyph, the hint, and a clear button while there is text. 48dp tall.
///
/// The screen owns [controller] and debounces [onChanged].
class SinewSearchField extends StatelessWidget {
  const SinewSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Search',
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = context.cs;
    final TextTheme tt = context.text;
    return Container(
      height: LibrarySpec.searchFieldHeight,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: Radii.fullR,
      ),
      padding: const EdgeInsets.only(left: Space.lg),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search_rounded,
            size: IconSpec.size,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: tt.bodyLarge!.copyWith(color: cs.onSurface),
              cursorColor: cs.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintText: hint,
                hintStyle: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (BuildContext context, TextEditingValue v, Widget? _) {
              if (v.text.isEmpty) return const SizedBox(width: Space.lg);
              return IconButton(
                tooltip: 'Clear search',
                constraints: const BoxConstraints.tightFor(
                  width: IconSpec.tapTarget,
                  height: IconSpec.tapTarget,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: Icon(
                  Icons.close_rounded,
                  size: IconSpec.size,
                  color: cs.onSurfaceVariant,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
