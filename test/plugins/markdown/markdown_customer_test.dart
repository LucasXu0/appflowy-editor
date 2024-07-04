import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('ordered list decoder', () {
    test('customer issue - unordered list with links', () {
      const markdown = '''
- [The Straits Times](https://www.straitstimes.com/)
- [Channel News Asia](https://www.channelnewsasia.com/)
- [Today Online](https://www.todayonline.com/)
''';
      final result = markdownToDocument(markdown);
      print(result.toJson());
    });
  });
}
