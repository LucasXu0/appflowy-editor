import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Cmd / Ctrl + Shift + H: show highlight color menu
/// - support
///   - desktop
///   - web
final CommandShortcutEvent showHighlightColorMenuCommand = CommandShortcutEvent(
  key: 'highlight color menu',
  command: 'ctrl+shift+h',
  macOSCommand: 'cmd+shift+h',
  handler: (editorState, context) =>
      _showHighlightColorMenu(editorState, context),
);

KeyEventResult _showHighlightColorMenu(
  EditorState editorState,
  BuildContext? context,
) {
  if (PlatformExtension.isMobile) {
    assert(false, 'homeCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (selection == null || selection.isCollapsed || context == null) {
    return KeyEventResult.ignored;
  }

  String? highlightColorHex = editorState.getDeltaAttributeValueInSelection(
    BuiltInAttributeKey.highlightColor,
    selection,
  );

  showColorMenu(
    context,
    editorState,
    selection,
    currentColorHex: highlightColorHex,
    isTextColor: false,
  );
  return KeyEventResult.handled;
}
