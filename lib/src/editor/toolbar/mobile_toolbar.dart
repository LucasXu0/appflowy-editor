import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/infra/mobile/mobile.dart';
import 'package:flutter/material.dart';

class MobileToolbar extends StatelessWidget {
  const MobileToolbar({
    super.key,
    required this.editorState,
  });

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    List<Widget> toolbarItems = [
      IconButton(
        onPressed: () {
          editorState.selectionService.updateSelection(null);
        },
        icon: const Icon(Icons.keyboard_hide),
      ),
      // TODO(yijing): Implement features later
      ...List.generate(
          16,
          (index) => IconButton(
              onPressed: () {},
              icon: AFMobileIcon(
                afMobileIcons: AFMobileIcons.values.toList()[index],
              ))),
    ];

    return ValueListenableBuilder<Selection?>(
      valueListenable: editorState.service.selectionService.currentSelection,
      builder: (_, Selection? selection, __) {
        if (selection == null) {
          return const SizedBox.shrink();
        }
        final width = MediaQuery.of(context).size.width;
        return SizedBox(
          width: width,
          height: 50,
          child: Container(
            // TODO(yijing): expose background color in editor style
            color: const Color(0xFFF1F1F4),
            child: ListView.builder(
              itemBuilder: (context, index) => toolbarItems[index],
              itemCount: toolbarItems.length,
              scrollDirection: Axis.horizontal,
            ),
          ),
        );
      },
    );
  }
}
