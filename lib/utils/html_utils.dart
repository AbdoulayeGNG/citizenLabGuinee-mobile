import 'package:html/parser.dart' as html_parser;

/// Utility to decode HTML entities and optionally strip HTML tags.
class HtmlUtils {
  /// Strips HTML tags and decodes HTML entities (e.g. &rsquo; -> ')
  static String stripHtmlAndDecodeEntities(String? htmlString) {
    if (htmlString == null || htmlString.trim().isEmpty) return '';

    try {
      final document = html_parser.parse(htmlString);
      return document.body?.text.trim() ?? '';
    } catch (e) {
      // Fallback in case of parse error
      final RegExp exp = RegExp(
        r'<[^>]*>',
        multiLine: true,
        caseSensitive: false,
      );
      return htmlString.replaceAll(exp, '').trim();
    }
  }

  /// Decodes HTML entities without necessarily stripping tags
  /// (Using parseFragment works nicely for this, but for simple titles,
  /// parsing as document and getting text works best since titles shouldn't have tags)
  static String decodeEntities(String? input) {
    if (input == null || input.isEmpty) return '';
    try {
      final document = html_parser.parse(input);
      return document.body?.text.trim() ?? input;
    } catch (_) {
      return input;
    }
  }
}
