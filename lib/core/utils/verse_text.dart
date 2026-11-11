/// Cleans packed Bible text for calm on-screen reading across all versions.
String cleanVerseText(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return text;

  // Cross-reference / footnote dumps (common in MacQul HTML scrape): "#1 Iyo 38:4; …"
  text = text.replaceAll(RegExp(r'#\d[\w.:;\-,\s]*$'), '');
  text = text.replaceAll(RegExp(r'#\d+:\d+\s*'), '');

  // Dialogue markers from the source: <<…>> → “…”
  text = text.replaceAll('<<', '“').replaceAll('>>', '”');

  // Collapse leftover spaces and punctuation spacing.
  text = text.replaceAll(RegExp(r'\s+'), ' ');
  text = text.replaceAll(RegExp(r'\s+([,.;:!?])'), r'$1');
  return text.trim();
}
