import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:markdown/markdown.dart' as md;

final HtmlUnescape appflowyEditorHtmlUnescape = HtmlUnescape();

abstract class CustomMarkdownParser {
  const CustomMarkdownParser();

  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  });
}
