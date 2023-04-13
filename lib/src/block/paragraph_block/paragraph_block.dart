import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/block/base_component/selectable/text_selectable_state_mixin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParagraphBlock extends StatefulWidget {
  const ParagraphBlock({
    super.key,
    required this.node,
  });

  final Node node;

  @override
  State<ParagraphBlock> createState() => _ParagraphBlockState();
}

class _ParagraphBlockState extends State<ParagraphBlock>
    with TextBlockSelectableStateMixin<ParagraphBlock> {
  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);
    final node = widget.node;
    final delta = node.delta!;

    return TextBlock(key: textBlockKey, delta: delta, path: node.path);

    // return PaddingNestedList(
    //   nestedChildren:
    //       editorState.service.renderPluginService.buildPluginWidgets(
    //     context,
    //     nodes,
    //     editorState,
    //   ),
    //   child: TextBlock(
    //     key: textBlockKey,
    //     path: node.path,
    //     delta: delta,
    //     shortcuts: textBlockShortcuts,
    //   ),
    // );
  }
}
