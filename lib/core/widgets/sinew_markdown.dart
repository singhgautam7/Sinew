import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A small Markdown renderer for bundled, trusted text (credits, notices):
/// `#` and `##` headings, `-` bullets, `---` rules, paragraphs, and inline
/// `**bold**`, `*italic*` and `[text](url)`. Links are shown as text followed
/// by the address: Sinew has no network and opens nothing.
class SinewMarkdown extends StatelessWidget {
  const SinewMarkdown(this.data, {super.key});

  final String data;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = context.text;
    final ColorScheme cs = context.cs;
    final List<Widget> blocks = <Widget>[];
    for (final String raw in data.split('\n')) {
      final String line = raw.trimRight();
      if (line.trim().isEmpty) continue;
      if (line.trim() == '---') {
        blocks.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.md),
            child: Divider(
              height: Strokes.hairline,
              thickness: Strokes.hairline,
              color: cs.outlineVariant,
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Space.xs),
            child: Semantics(
              header: true,
              child: Text(
                line.substring(3),
                style: tt.titleMedium!.copyWith(color: cs.onSurface),
              ),
            ),
          ),
        );
      } else if (line.startsWith('# ')) {
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: Semantics(
              header: true,
              child: Text(
                line.substring(2),
                style: tt.titleLarge!.copyWith(color: cs.onSurface),
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Space.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: Space.sm),
                  child: Text(
                    '•',
                    style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: _inline(context, line.substring(2))),
                    style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: Text.rich(
              TextSpan(children: _inline(context, line)),
              style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: blocks,
    );
  }

  static final RegExp _token = RegExp(
    r'\*\*(.+?)\*\*|\*(.+?)\*|\[(.+?)\]\((.+?)\)',
  );

  List<InlineSpan> _inline(BuildContext context, String text) {
    final ColorScheme cs = context.cs;
    final List<InlineSpan> spans = <InlineSpan>[];
    int at = 0;
    for (final RegExpMatch m in _token.allMatches(text)) {
      if (m.start > at) spans.add(TextSpan(text: text.substring(at, m.start)));
      if (m.group(1) != null) {
        spans.add(
          TextSpan(
            text: m.group(1),
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
        );
      } else if (m.group(2) != null) {
        spans.add(
          TextSpan(
            text: m.group(2),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: m.group(3),
            style: TextStyle(
              color: cs.primary,
              decoration: TextDecoration.underline,
              decorationColor: cs.primary,
            ),
          ),
        );
        spans.add(TextSpan(text: ' (${m.group(4)})'));
      }
      at = m.end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return spans;
  }
}
