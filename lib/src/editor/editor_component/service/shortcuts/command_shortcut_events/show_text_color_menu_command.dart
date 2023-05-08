import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Cmd / Ctrl + Shift + T: show text color menu
/// - support
///   - desktop
///   - web
final CommandShortcutEvent showTextColorMenuCommand = CommandShortcutEvent(
  key: 'text color menu',
  command: 'ctrl+shift+t',
  macOSCommand: 'cmd+shift+t',
  handler: (editorState, context) => _showTextColorMenu(editorState, context),
);

KeyEventResult _showTextColorMenu(
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

  String? textColorHex = editorState.getDeltaAttributeValueInSelection(
    BuiltInAttributeKey.textColor,
    selection,
  );

  showColorMenu(
    context,
    editorState,
    selection,
    currentColorHex: textColorHex,
    isTextColor: true,
  );
  return KeyEventResult.handled;
}
