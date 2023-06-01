import 'package:appflowy_editor/appflowy_editor.dart';

class NumberedListNodeParser extends NodeParser {
  const NumberedListNodeParser();

  @override
  String get id => NumberedListBlockKeys.type;

  @override
  String transform(Node node) {
    assert(node.type == NumberedListBlockKeys.type);

    final delta = node.delta;
    if (delta == null) {
      throw Exception('Delta is null');
    }
    final markdown = DeltaMarkdownEncoder().convert(delta);
    final result = '1. $markdown'; // FIXME: support parse the number
    final suffix = node.next == null ? '' : '\n';

    return '$result$suffix';
  }
}
