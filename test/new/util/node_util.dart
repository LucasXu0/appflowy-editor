import 'package:appflowy_editor/appflowy_editor.dart';

import 'delta_builder_util.dart';

extension NodeExtension on Node {
  void appendParagraphs(
    int count, {
    DeltaBuilder? builder,
  }) {
    final builder0 = builder ??
        (index) => Delta()
          ..insert(
            '🔥 $index. Welcome to AppFlowy Editor!',
          );
    for (var element in List.generate(
      count,
      (index) => Node(type: 'paragraph')
        ..updateAttributes({
          'delta': builder0(index).toJson(),
        }),
    )) {
      insert(element);
    }
  }
}