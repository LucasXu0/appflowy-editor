import 'package:appflowy_editor/appflowy_editor.dart';

final ToolbarItem bulletedListItem = ToolbarItem(
  id: 'editor.bulleted_list',
  group: 3,
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == BulletedListBlockKeys.type;
    return IconItemWidget(
      iconName: 'toolbar/bulleted_list',
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.bulletedList,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight
              ? ParagraphBlockKeys.type
              : BulletedListBlockKeys.type,
        ),
      ),
    );
  },
);
