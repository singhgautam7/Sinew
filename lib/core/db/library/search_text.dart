// PURE DART: shared by `tool/build_library_db.dart` (which fills `name_norm`
// and the FTS index) and by the library search (which normalises the query),
// so both sides always agree on what "the same text" means.

/// Base letter to the accented forms folded onto it.
const Map<String, String> _folds = <String, String>{
  'a': 'àáâãäåāăą',
  'c': 'çćĉċč',
  'd': 'ďđ',
  'e': 'èéêëēĕėęě',
  'g': 'ĝğġģ',
  'h': 'ĥħ',
  'i': 'ìíîïĩīĭįı',
  'j': 'ĵ',
  'k': 'ķ',
  'l': 'ĺļľł',
  'n': 'ñńņň',
  'o': 'òóôõöøōŏő',
  'r': 'ŕŗř',
  's': 'śŝşš',
  't': 'ţťŧ',
  'u': 'ùúûüũūŭůűų',
  'w': 'ŵ',
  'y': 'ýÿŷ',
  'z': 'źżž',
  'ss': 'ß',
};

final Map<int, String> _fold = <int, String>{
  for (final MapEntry<String, String> e in _folds.entries)
    for (final int rune in e.value.runes) rune: e.key,
};

/// Lowercase, diacritics stripped, every run of non letters and digits
/// replaced by one space, trimmed: "Cat-Cow (Marjaryasana)" becomes
/// "cat cow marjaryasana". This is the stored `name_norm`.
String normalizeSearchText(String input) {
  final StringBuffer out = StringBuffer();
  bool pendingSpace = false;
  for (final int rune in input.toLowerCase().runes) {
    final String piece = rune < 0x80
        ? String.fromCharCode(rune)
        : (_fold[rune] ?? String.fromCharCode(rune));
    for (final int c in piece.runes) {
      final bool alnum = (c >= 0x30 && c <= 0x39) || (c >= 0x61 && c <= 0x7a);
      // Letters outside Latin (for example Devanagari) are kept as they are;
      // Latin-1 symbols (degree sign) and the punctuation and symbol blocks
      // are separators.
      final bool other = c >= 0x100 && !(c >= 0x2000 && c <= 0x2bff);
      if (alnum || other) {
        if (pendingSpace && out.isNotEmpty) out.write(' ');
        pendingSpace = false;
        out.writeCharCode(c);
      } else {
        pendingSpace = true;
      }
    }
  }
  return out.toString();
}

/// `hipFlexors` becomes `hip flexors`.
String humanizeCamel(String camel) => camel
    .replaceAllMapped(RegExp('(?<=[a-z0-9])(?=[A-Z])'), (Match m) => ' ')
    .toLowerCase();

/// The query as FTS5 `MATCH` text: every token a quoted prefix term, ANDed
/// (`"hip"* "flex"*`). Null when nothing searchable is left.
String? ftsMatchQuery(String query) {
  final List<String> tokens = normalizeSearchText(query)
      .split(' ')
      .where((String t) => t.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return null;
  return tokens.map((String t) => '"${t.replaceAll('"', '""')}"*').join(' ');
}
