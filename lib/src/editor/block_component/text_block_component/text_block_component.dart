import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextBlockComponentBuilder extends NodeWidgetBuilder<Node> {
  TextBlockComponentBuilder({
    this.padding = const EdgeInsets.all(0.0),
    this.textStyle = const TextStyle(),
  });

  final EdgeInsets padding;
  final TextStyle textStyle;

  @override
  Widget build(NodeWidgetContext<Node> context) {
    return TextBlockComponentWidget(
      key: context.node.key,
      node: context.node,
      padding: padding,
      textStyle: textStyle,
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => (node) => node.delta != null;
}

class TextBlockComponentWidget extends StatefulWidget {
  const TextBlockComponentWidget({
    super.key,
    required this.node,
    this.padding = const EdgeInsets.all(0.0),
    this.textStyle = const TextStyle(),
  });

  final Node node;
  final EdgeInsets padding;
  final TextStyle textStyle;

  @override
  State<TextBlockComponentWidget> createState() =>
      _TextBlockComponentWidgetState();
}

class _TextBlockComponentWidgetState extends State<TextBlockComponentWidget>
    with SelectableMixin, DefaultSelectable {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');
  late final editorState = Provider.of<EditorState>(context, listen: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: FlowyRichText(
        key: forwardKey,
        node: widget.node,
        editorState: editorState,
      ),
    );
  }
}