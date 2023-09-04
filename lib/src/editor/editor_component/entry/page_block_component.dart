import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

EdgeDraggingAutoScroller? kAutoScroller;

class PageBlockKeys {
  static const String type = 'page';
}

Node pageNode({
  required Iterable<Node> children,
  Attributes attributes = const {},
}) {
  return Node(
    type: PageBlockKeys.type,
    children: children,
    attributes: attributes,
  );
}

class PageBlockComponentBuilder extends BlockComponentBuilder {
  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    return PageBlockComponent(
      key: blockComponentContext.node.key,
      node: blockComponentContext.node,
    );
  }
}

class PageBlockComponent extends BlockComponentStatefulWidget {
  const PageBlockComponent({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<PageBlockComponent> createState() => _PageBlockComponentState();
}

class _PageBlockComponentState extends State<PageBlockComponent> {
  late ScrollableState _scrollable;

  @override
  Widget build(BuildContext context) {
    final editorState = context.read<EditorState>();
    final scrollController = context.read<EditorScrollController>();

    final items = widget.node.children.toList(growable: false);

    return ScrollablePositionedList.builder(
      shrinkWrap: false,
      itemCount: items.length,
      itemBuilder: (context, index) {
        _scrollable = Scrollable.of(context);
        if (kAutoScroller?.scrollable != _scrollable) {
          kAutoScroller?.stopAutoScroll();
          kAutoScroller = EdgeDraggingAutoScroller(
            _scrollable,
            onScrollViewScrolled: () {
              print('here');
            },
          );
        }
        return editorState.renderer.build(
          context,
          items[index],
        );
      },
      itemScrollController: scrollController.itemScrollController,
      scrollOffsetController: scrollController.scrollOffsetController,
      itemPositionsListener: scrollController.itemPositionsListener,
      scrollOffsetListener: scrollController.scrollOffsetListener,
    );
  }
}
