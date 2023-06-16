import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/renderer/block_component_action.dart';
import 'package:appflowy_editor/src/flutter/overlay.dart';
import 'package:appflowy_editor/src/render/selection/mobile_selection_widget.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;

import 'package:appflowy_editor/src/render/selection/cursor_widget.dart';
import 'package:appflowy_editor/src/render/selection/selection_widget.dart';
import 'package:appflowy_editor/src/service/selection/selection_gesture.dart';
import 'package:provider/provider.dart';

enum MobileSelectionDragMode {
  none,
  selection,
  cursor,
}

class MobileSelectionServiceWidget extends StatefulWidget {
  const MobileSelectionServiceWidget({
    Key? key,
    this.cursorColor = const Color(0xFF00BCF0),
    this.selectionColor = const Color.fromARGB(53, 111, 201, 231),
    required this.child,
  }) : super(key: key);

  final Widget child;
  final Color cursorColor;
  final Color selectionColor;

  @override
  State<MobileSelectionServiceWidget> createState() =>
      _MobileSelectionServiceWidgetState();
}

class _MobileSelectionServiceWidgetState
    extends State<MobileSelectionServiceWidget>
    with WidgetsBindingObserver
    implements AppFlowySelectionService {
  final _cursorKey = GlobalKey(debugLabel: 'cursor');

  @override
  final List<Rect> selectionRects = [];
  final List<OverlayEntry> _selectionAreas = [];
  final List<OverlayEntry> _cursorAreas = [];

  @override
  ValueNotifier<Selection?> currentSelection = ValueNotifier(null);

  @override
  List<Node> currentSelectedNodes = [];

  final List<SelectionGestureInterceptor> _interceptors = [];

  /// Pan
  Offset? _panStartOffset;
  double? _panStartScrollDy;

  MobileSelectionDragMode dragMode = MobileSelectionDragMode.none;

  late EditorState editorState = Provider.of<EditorState>(
    context,
    listen: false,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    editorState.selectionNotifier.addListener(_updateSelection);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // Need to refresh the selection when the metrics changed.
    if (currentSelection.value != null) {
      Debounce.debounce(
        'didChangeMetrics - update selection ',
        const Duration(milliseconds: 100),
        () => updateSelection(currentSelection.value!),
      );
    }
  }

  @override
  void dispose() {
    clearSelection();
    WidgetsBinding.instance.removeObserver(this);
    editorState.selectionNotifier.removeListener(_updateSelection);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionGestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTapDown: _onTapDown,
      onDoubleTapDown: _onDoubleTapDown,
      onTripleTapDown: _onTripleTapDown,
      child: widget.child,
    );
  }

  @override
  void updateSelection(Selection? selection) {
    if (currentSelection.value == selection) {
      return;
    }

    selectionRects.clear();
    _clearSelection();

    if (selection != null) {
      if (selection.isCollapsed) {
        // updates cursor area.
        Log.selection.debug('update cursor area, $selection');
        _forceShowCursor();
        _updateCursorAreas(selection.start);
      } else {
        // updates selection area.
        Log.selection.debug('update cursor area, $selection');
        _updateSelectionAreas(selection);
      }
    }

    currentSelection.value = selection;
    editorState.selection = selection;
  }

  @override
  void clearSelection() {
    currentSelectedNodes = [];
    currentSelection.value = null;

    _clearSelection();
  }

  void _clearSelection() {
    clearCursor();
    // clear selection areas
    _selectionAreas
      ..forEach((overlay) => overlay.remove())
      ..clear();
    // clear cursor areas
  }

  @override
  void clearCursor() {
    // clear cursor areas
    _cursorAreas
      ..forEach((overlay) => overlay.remove())
      ..clear();
  }

  @override
  Node? getNodeInOffset(Offset offset) {
    final sortedNodes =
        editorState.document.root.children.toList(growable: false);
    return _getNodeInOffset(
      sortedNodes,
      offset,
      0,
      sortedNodes.length - 1,
    );
  }

  @override
  Position? getPositionInOffset(Offset offset) {
    final node = getNodeInOffset(offset);
    final selectable = node?.selectable;
    if (selectable == null) {
      clearSelection();
      return null;
    }
    return selectable.getPositionInOffset(offset);
  }

  @override
  void registerGestureInterceptor(SelectionGestureInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  @override
  void unregisterGestureInterceptor(String key) {
    _interceptors.removeWhere((element) => element.key == key);
  }

  void _updateSelection() {
    final selection = editorState.selection;
    // TODO: why do we need to check this?
    if (currentSelection.value == selection &&
        editorState.selectionUpdateReason == SelectionUpdateReason.uiEvent &&
        editorState.selectionType != SelectionType.block) {
      return;
    }

    currentSelection.value = selection;

    void updateSelection() {
      selectionRects.clear();
      _clearSelection();

      if (selection != null) {
        if (editorState.selectionType == SelectionType.block) {
          // updates selection area.
          Log.selection.debug('update block selection area, $selection');
          _updateBlockSelectionAreas(selection);
        } else if (selection.isCollapsed) {
          // updates cursor area.
          Log.selection.debug('update cursor area, $selection');
          _updateCursorAreas(selection.start);
        } else {
          // updates selection area.
          Log.selection.debug('update selection area, $selection');
          _updateSelectionAreas(selection);
        }
      }
    }

    if (editorState.selectionUpdateReason == SelectionUpdateReason.uiEvent) {
      updateSelection();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        updateSelection();
      });
    }
  }

  void _onTapDown(TapDownDetails details) {
    final canTap = _interceptors.every(
      (element) => element.canTap?.call(details) ?? true,
    );
    if (!canTap) return;

    // clear old state.
    _panStartOffset = null;

    final position = getPositionInOffset(details.globalPosition);
    if (position == null) {
      return;
    }

    // updateSelection(selection);
    editorState.selection = Selection.collapsed(position);
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final offset = details.globalPosition;
    final node = getNodeInOffset(offset);
    final selection = node?.selectable?.getWordBoundaryInOffset(offset);
    if (selection == null) {
      clearSelection();
      return;
    }
    updateSelection(selection);
  }

  void _onTripleTapDown(TapDownDetails details) {
    final offset = details.globalPosition;
    final node = getNodeInOffset(offset);
    final selectable = node?.selectable;
    if (selectable == null) {
      clearSelection();
      return;
    }
    Selection selection = Selection(
      start: selectable.start(),
      end: selectable.end(),
    );
    updateSelection(selection);
  }

  void _onPanStart(DragStartDetails details) {
    clearSelection();

    _panStartOffset = details.globalPosition.translate(-3.0, 0);
    _panStartScrollDy = editorState.service.scrollService?.dy;

    final selection = editorState.selection;
    if (selection == null) {
      dragMode = MobileSelectionDragMode.none;
    } else {
      if (selection.isCollapsed) {
        dragMode = MobileSelectionDragMode.cursor;
      } else {
        dragMode = MobileSelectionDragMode.selection;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStartOffset == null || _panStartScrollDy == null) {
      return;
    }

    // only support selection mode now.
    if (dragMode != MobileSelectionDragMode.selection) {
      return;
    }

    // check if the offset of details is over the handler of the selection area.

    final panEndOffset = details.globalPosition;
    final dy = editorState.service.scrollService?.dy;
    final panStartOffset = dy == null
        ? _panStartOffset!
        : _panStartOffset!.translate(0, _panStartScrollDy! - dy);

    final first = getNodeInOffset(panStartOffset)?.selectable;
    final last = getNodeInOffset(panEndOffset)?.selectable;

    // compute the selection in range.
    if (first != null && last != null) {
      // Log.selection.debug('first = $first, last = $last');
      final start =
          first.getSelectionInRange(panStartOffset, panEndOffset).start;
      final end = last.getSelectionInRange(panStartOffset, panEndOffset).end;
      final selection = Selection(start: start, end: end);
      updateSelection(selection);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    // do nothing
  }

  void _updateBlockSelectionAreas(Selection selection) {
    assert(editorState.selectionType == SelectionType.block);
    final nodes = editorState.getNodesInSelection(selection).normalized;

    currentSelectedNodes = nodes;

    final node = nodes.first;
    var offset = Offset.zero;
    var size = node.rect.size;
    final builder = editorState.renderer.blockComponentBuilder(node.type);
    if (builder != null && builder.showActions(node)) {
      offset = offset.translate(blockComponentActionContainerWidth, 0);
      size = Size(size.width - blockComponentActionContainerWidth, size.height);
    }
    final rect = offset & size;

    final overlay = OverlayEntry(
      builder: (context) => MobileSelectionWidget(
        color: widget.selectionColor,
        layerLink: node.layerLink,
        rect: rect,
        decoration: BoxDecoration(
          color: widget.selectionColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
    _selectionAreas.add(overlay);

    Overlay.of(context)?.insertAll(_selectionAreas);
  }

  void _updateSelectionAreas(Selection selection) {
    final nodes = editorState.getNodesInSelection(selection);

    currentSelectedNodes = nodes;

    final backwardNodes =
        selection.isBackward ? nodes : nodes.reversed.toList(growable: false);
    final normalizedSelection = selection.normalized;
    assert(normalizedSelection.isBackward);

    Log.selection.debug('update selection areas, $normalizedSelection');

    if (editorState.selectionType == SelectionType.block) {
      final node = backwardNodes.first;
      final rect = Offset.zero & node.rect.size;
      final overlay = OverlayEntry(
        builder: (context) => SelectionWidget(
          color: widget.selectionColor,
          layerLink: node.layerLink,
          rect: rect,
        ),
      );
      _selectionAreas.add(overlay);
    } else {
      for (var i = 0; i < backwardNodes.length; i++) {
        final node = backwardNodes[i];

        final selectable = node.selectable;
        if (selectable == null) {
          continue;
        }

        var newSelection = normalizedSelection.copyWith();

        /// In the case of multiple selections,
        ///  we need to return a new selection for each selected node individually.
        ///
        /// < > means selected.
        /// text: abcd<ef
        /// text: ghijkl
        /// text: mn>opqr
        ///
        if (!normalizedSelection.isSingle) {
          if (i == 0) {
            newSelection = newSelection.copyWith(end: selectable.end());
          } else if (i == nodes.length - 1) {
            newSelection = newSelection.copyWith(start: selectable.start());
          } else {
            newSelection = Selection(
              start: selectable.start(),
              end: selectable.end(),
            );
          }
        }

        final rects = selectable.getRectsInSelection(newSelection);
        for (final (j, rect) in rects.indexed) {
          final selectionRect = selectable.transformRectToGlobal(rect);
          selectionRects.add(selectionRect);
          print('i = $i, i = $j rect = $rect, selectionRect = $selectionRect');
          final overlay = OverlayEntry(
            builder: (context) => MobileSelectionWidget(
              color: widget.selectionColor,
              layerLink: node.layerLink,
              rect: rect,
              showLeftHandler: i == 0 && j == 0,
              showRightHandler:
                  i == backwardNodes.length - 1 && j == rects.length - 1,
            ),
          );
          _selectionAreas.add(overlay);
        }
      }
    }

    Overlay.of(context)?.insertAll(_selectionAreas);
  }

  void _updateCursorAreas(Position position) {
    final node = editorState.document.root.childAtPath(position.path);

    if (node == null) {
      assert(false);
      return;
    }

    currentSelectedNodes = [node];

    _showCursor(node, position);
  }

  void _showCursor(Node node, Position position) {
    final selectable = node.selectable;
    final cursorRect = selectable?.getCursorRectInPosition(position);
    if (selectable != null && cursorRect != null) {
      final cursorArea = OverlayEntry(
        builder: (context) => CursorWidget(
          key: _cursorKey,
          rect: cursorRect,
          color: widget.cursorColor,
          layerLink: node.layerLink,
          shouldBlink: selectable.shouldCursorBlink,
          cursorStyle: selectable.cursorStyle,
        ),
      );

      _cursorAreas.add(cursorArea);
      selectionRects.add(selectable.transformRectToGlobal(cursorRect));
      Overlay.of(context)?.insertAll(_cursorAreas);

      _forceShowCursor();
    }
  }

  void _forceShowCursor() {
    _cursorKey.currentState?.unwrapOrNull<CursorWidgetState>()?.show();
  }

  Node? _getNodeInOffset(
    List<Node> sortedNodes,
    Offset offset,
    int start,
    int end,
  ) {
    if (start < 0 && end >= sortedNodes.length) {
      return null;
    }
    var min = start;
    var max = end;
    while (min <= max) {
      final mid = min + ((max - min) >> 1);
      final rect = sortedNodes[mid].rect;
      if (rect.bottom <= offset.dy) {
        min = mid + 1;
      } else {
        max = mid - 1;
      }
    }
    min = min.clamp(start, end);
    final node = sortedNodes[min];
    if (node.children.isNotEmpty && node.children.first.rect.top <= offset.dy) {
      final children = node.children.toList(growable: false);
      return _getNodeInOffset(
        children,
        offset,
        0,
        children.length - 1,
      );
    }
    return node;
  }
}
