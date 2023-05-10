import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/utils/tooltip_util.dart';
import 'package:flutter/material.dart';

final textColorItem = ToolbarItem(
  id: 'editor.textColor',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    String? textColorHex;

    final selection = editorState.selection!;
    final nodes = editorState.getNodesInSelection(selection);
    final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) {
          textColorHex = attributes['textColor'];
          return (textColorHex != null);
        },
      );
    });
    return IconItemWidget(
      key: const Key('toolbar_item_text_color'),
      iconName: 'toolbar/text_color',
      isHighlight: isHighlight,
      tooltip:
          '${AppFlowyEditorLocalizations.current.textColor}${shortcutTooltips("⌘ + SHIFT + T", "CTRL + SHIFT + T", "CTRL + SHIFT + T")}',
      onPressed: () {
        showColorMenu(
          context,
          editorState,
          selection,
          currentColorHex: textColorHex,
          isTextColor: true,
        );
      },
    );
  },
);
