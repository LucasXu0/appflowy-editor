import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final ValueNotifier<bool> showKeyboardMenu = ValueNotifier(false);

class MobileToolbarV4 extends StatelessWidget {
  const MobileToolbarV4({
    super.key,
    required this.editorState,
  });

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: editorState.selectionNotifier,
        builder: (_, selection, __) {
          if (selection == null) {
            return const SizedBox.square();
          }

          return SizedBox(
            height: 48.0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    showKeyboardMenu.value = !showKeyboardMenu.value;
                  },
                ),
                const VerticalDivider(),
                IconButton(
                  icon: const Icon(Icons.format_list_numbered),
                  onPressed: () {
                    final transaction = editorState.transaction;
                    transaction.insertNode(
                      selection.start.path.next,
                      numberedListNode(),
                    );
                    transaction.afterSelection = Selection.collapsed(
                      Position(
                        path: selection.start.path.next,
                        offset: 0,
                      ),
                    );
                    editorState.apply(transaction);
                  },
                ),
                const VerticalDivider(),
                IconButton(
                  icon: const Icon(Icons.keyboard_hide_rounded),
                  onPressed: () {
                    editorState.selection = null;
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
