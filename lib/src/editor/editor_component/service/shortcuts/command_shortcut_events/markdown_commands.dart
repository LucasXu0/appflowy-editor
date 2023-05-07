import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> toggleMarkdownCommands = [
  toggleBoldCommand,
  toggleItalicCommand,
  toggleUnderlineCommand,
  toggleStrikethroughCommand,
  toggleCodeCommand,
  showLinkMenuCommand,
];

/// Markdown key event.
///
/// Cmd / Ctrl + B: toggle bold
/// Cmd / Ctrl + I: toggle italic
/// Cmd / Ctrl + U: toggle underline
/// Cmd / Ctrl + Shift + S: toggle strikethrough
/// Cmd / Ctrl + Shift + H: toggle highlight
/// Cmd / Ctrl + E: code
/// Cmd / Ctrl + K: show link menu
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent toggleBoldCommand = CommandShortcutEvent(
  key: 'toggle bold',
  command: 'ctrl+b',
  macOSCommand: 'cmd+b',
  handler: (editorState, _) => _toggleAttribute(editorState, 'bold'),
);

final CommandShortcutEvent toggleItalicCommand = CommandShortcutEvent(
  key: 'toggle italic',
  command: 'ctrl+i',
  macOSCommand: 'cmd+i',
  handler: (editorState, _) => _toggleAttribute(editorState, 'italic'),
);

final CommandShortcutEvent toggleUnderlineCommand = CommandShortcutEvent(
  key: 'toggle underline',
  command: 'ctrl+u',
  macOSCommand: 'cmd+u',
  handler: (editorState, _) => _toggleAttribute(editorState, 'underline'),
);

final CommandShortcutEvent toggleStrikethroughCommand = CommandShortcutEvent(
  key: 'toggle strikethrough',
  command: 'ctrl+shift+s',
  macOSCommand: 'cmd+shift+s',
  handler: (editorState, _) => _toggleAttribute(editorState, 'strikethrough'),
);

final CommandShortcutEvent toggleCodeCommand = CommandShortcutEvent(
  key: 'toggle code',
  command: 'ctrl+e',
  macOSCommand: 'cmd+e',
  handler: (editorState, _) => _toggleAttribute(editorState, 'code'),
);

final CommandShortcutEvent showLinkMenuCommand = CommandShortcutEvent(
  key: 'link menu',
  command: 'ctrl+k',
  macOSCommand: 'cmd+k',
  handler: (editorState, context) => _showLinkMenu(editorState, context),
);

KeyEventResult _showLinkMenu(
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
  final nodes = editorState.getNodesInSelection(selection);
  final isHref = nodes.allSatisfyInSelection(selection, (delta) {
    return delta.everyAttributes(
      (attributes) => attributes['href'] != null,
    );
  });

  showLinkMenu(
    context,
    editorState,
    selection,
    isHref,
  );

  return KeyEventResult.handled;
}

KeyEventResult _toggleAttribute(
  EditorState editorState,
  String key,
) {
  if (PlatformExtension.isMobile) {
    assert(false, 'homeCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  editorState.toggleAttribute(key);

  return KeyEventResult.handled;
}
