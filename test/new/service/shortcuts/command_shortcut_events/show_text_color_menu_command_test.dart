import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('show_text_color_menu_command.dart', () {
    testWidgets('Presses Command + Shift + T to trigger text color menu',
        (tester) async {
      await _testTextColorMenuInSingleTextSelection(tester);
    });
  });
}

Future<void> _testTextColorMenuInSingleTextSelection(
  WidgetTester tester,
) async {
  const text = 'Welcome to Appflowy 😁';

  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();

  final selection =
      Selection.single(path: [1], startOffset: 0, endOffset: text.length);
  await editor.updateSelection(selection);

  // trigger the text color menu
  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressKey(
      key: LogicalKeyboardKey.keyT,
      isControlPressed: true,
      isShiftPressed: true,
    );
  } else {
    await editor.pressKey(
      key: LogicalKeyboardKey.keyT,
      isMetaPressed: true,
      isShiftPressed: true,
    );
  }
  expect(find.byType(ColorPicker), findsOneWidget);
  expect(
      find.text(AppFlowyEditorLocalizations.current.textColor), findsOneWidget);

//// Set a custom text color
  const colorHex = '2DA2F6';
  const colorOpacity = 20;
  // Cover the opacity to hex value
  final opacityHex = (colorOpacity * 255 / 100)
      .round()
      .toRadixString(16)
      .padLeft(2, '0')
      .toString();
  final finalColor = '0x$opacityHex$colorHex';

  await tester.tap(find.byType(ExpansionTile));
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  await tester.enterText(find.byType(TextField).first, colorHex);
  await tester.enterText(find.byType(TextField).last, colorOpacity.toString());
  await tester.testTextInput.receiveAction(TextInputAction.send);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // After text color is changed, the text color menu should be dismissed
  expect(find.byType(ColorPicker), findsNothing);

  // Check if the text color is changed
  final nodes = editor.editorState.getNodesInSelection(selection);
  expect(
    nodes.allSatisfyInSelection(selection, (delta) {
      return delta.whereType<TextInsert>().every((element) {
        return element.attributes?[BuiltInAttributeKey.textColor] == finalColor;
      });
    }),
    true,
  );

  // Trigger the text color menu again
  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressKey(
      key: LogicalKeyboardKey.keyT,
      isControlPressed: true,
      isShiftPressed: true,
    );
  } else {
    await editor.pressKey(
      key: LogicalKeyboardKey.keyT,
      isMetaPressed: true,
      isShiftPressed: true,
    );
  }

  // Check if the text color menu is shown
  expect(find.byType(ColorPicker), findsOneWidget);
  expect(
      find.text(AppFlowyEditorLocalizations.current.textColor), findsOneWidget);
}
