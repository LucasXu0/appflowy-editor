import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scroller.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/material.dart';

class AutoScrollableWidget extends StatefulWidget {
  const AutoScrollableWidget({
    super.key,
    this.shrinkWrap = false,
    required this.scrollController,
    required this.builder,
  });

  final bool shrinkWrap;
  final ScrollController scrollController;
  final Widget Function(
    BuildContext context,
    AutoScroller autoScroller,
  ) builder;

  @override
  State<AutoScrollableWidget> createState() => _AutoScrollableWidgetState();
}

class _AutoScrollableWidgetState extends State<AutoScrollableWidget> {
  late AutoScroller _autoScroller;
  late ScrollableState _scrollableState;

  @override
  void dispose() {
    _scrollableState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget builder(context) {
      return widget.builder(context, _autoScroller);
    }

    _scrollableState = ScrollableState();
    _initAutoScroller();

    if (widget.shrinkWrap) {
      return widget.builder(context, _autoScroller);
    } else {
      return Builder(
        builder: builder,
      );
    }
  }

  void _initAutoScroller() {
    final bool isDesktopOrWeb = PlatformExtension.isDesktopOrWeb;
    _autoScroller = AutoScroller(
      _scrollableState,
      velocityScalar: isDesktopOrWeb ? 32 : 18,
      minAutoScrollDelta: isDesktopOrWeb ? 0.5 : 0.5,
      maxAutoScrollDelta: isDesktopOrWeb ? 22 : 20,
      onScrollViewScrolled: () {
        if (!isDesktopOrWeb) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _autoScroller.continueToAutoScroll();
            }
          });
        }
      },
    );
  }
}
