import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Cmd / Ctrl + K: show link menu
/// - support
///   - desktop
///   - web
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
