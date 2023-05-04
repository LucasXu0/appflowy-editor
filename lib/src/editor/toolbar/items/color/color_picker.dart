import 'package:appflowy_editor/src/editor/command/text_commands.dart';
import 'package:appflowy_editor/src/editor_state.dart';
import 'package:appflowy_editor/src/infra/flowy_svg.dart';
import 'package:appflowy_editor/src/l10n/l10n.dart';
import 'package:appflowy_editor/src/render/style/editor_style.dart';
import 'package:flutter/material.dart';

class ColorOption {
  const ColorOption({
    required this.colorHex,
    required this.name,
  });

  final String colorHex;
  final String name;
}

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.editorState,
    required this.isTextColor,
    required this.selectedColorHex,
    required this.pickerBackgroundColor,
    required this.pickerItemHoverColor,
    required this.pickerItemTextColor,
    required this.onSubmittedColorHex,
    required this.colorOptions,
    required this.onDismiss,
  });

  final bool isTextColor;
  final EditorState editorState;
  final String? selectedColorHex;
  final Color pickerBackgroundColor;
  final Color pickerItemHoverColor;
  final Color pickerItemTextColor;
  final void Function(String color) onSubmittedColorHex;
  final Function() onDismiss;

  final List<ColorOption> colorOptions;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  final TextEditingController _colorHexController = TextEditingController();
  final TextEditingController _colorOpacityController = TextEditingController();
  EditorStyle? get style => widget.editorState?.editorStyle;

  @override
  void initState() {
    super.initState();
    _colorHexController.text =
        _extractColorHex(widget.selectedColorHex) ?? 'FFFFFF';
    _colorOpacityController.text =
        _convertHexToOpacity(widget.selectedColorHex) ?? '100';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.pickerBackgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
        borderRadius: BorderRadius.circular(6.0),
      ),
      height: 250,
      width: 220,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.isTextColor
                  ? _buildHeader(AppFlowyEditorLocalizations.current.textColor)
                  : _buildHeader(
                      AppFlowyEditorLocalizations.current.highlightColor,
                    ),
              const SizedBox(height: 6),
              // if it is in hightlight color mode with a highlight color, show the clear highlight color button
              widget.isTextColor == false && widget.selectedColorHex != null
                  ? ClearHighlightColorButton(
                      editorState: widget.editorState,
                      dismissOverlay: widget.onDismiss,
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 6),
              CustomColorItem(
                colorController: _colorHexController,
                opacityController: _colorOpacityController,
                onSubmittedColorHex: widget.onSubmittedColorHex,
              ),
              _buildColorItems(
                widget.colorOptions,
                widget.selectedColorHex,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildColorItems(
    List<ColorOption> options,
    String? selectedColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: options
          .map((e) => _buildColorItem(e, e.colorHex == selectedColor))
          .toList(),
    );
  }

  Widget _buildColorItem(ColorOption option, bool isChecked) {
    return SizedBox(
      height: 36,
      child: TextButton.icon(
        onPressed: () {
          widget.onSubmittedColorHex(option.colorHex);
        },
        icon: SizedBox.square(
          dimension: 12,
          child: Container(
            decoration: BoxDecoration(
              color: Color(int.tryParse(option.colorHex) ?? 0xFFFFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return style!.popupMenuHoverColor!;
              }
              return Colors.transparent;
            },
          ),
        ),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                option.name,
                style:
                    TextStyle(fontSize: 12, color: widget.pickerItemTextColor),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
            // checkbox
            if (isChecked) const FlowySvg(name: 'checkmark'),
          ],
        ),
      ),
    );
  }

  String? _convertHexToOpacity(String? colorHex) {
    if (colorHex == null) return null;
    final opacityHex = colorHex.substring(2, 4);
    final opacity = int.parse(opacityHex, radix: 16) / 2.55;
    return opacity.toStringAsFixed(0);
  }

  String? _extractColorHex(String? colorHex) {
    if (colorHex == null) return null;
    return colorHex.substring(4);
  }
}

class ClearHighlightColorButton extends StatelessWidget {
  const ClearHighlightColorButton({
    super.key,
    required this.editorState,
    required this.dismissOverlay,
  });

  final EditorState editorState;
  final Function() dismissOverlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          final selection = editorState.selection!;
          editorState.formatDelta(selection, {'highlightColor': null});
          dismissOverlay();
        },
        icon: const FlowySvg(
          name: 'toolbar/clear_highlight_color',
          width: 16,
          height: 16,
          color: Colors.grey,
        ),
        label: Text(
          'Clear highlight color',
          style: TextStyle(
            color: Theme.of(context).hintColor,
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.grey.withOpacity(0.2);
              }
              return Colors.transparent;
            },
          ),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}

class CustomColorItem extends StatefulWidget {
  const CustomColorItem({
    super.key,
    required this.colorController,
    required this.opacityController,
    required this.onSubmittedColorHex,
  });

  final TextEditingController colorController;
  final TextEditingController opacityController;
  final void Function(String color) onSubmittedColorHex;

  @override
  State<CustomColorItem> createState() => _CustomColorItemState();
}

class _CustomColorItemState extends State<CustomColorItem> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.only(left: 8),
      title: SizedBox(
        height: 36,
        child: Row(
          children: [
            // color sample box
            SizedBox.square(
              dimension: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(
                    int.tryParse(
                          _combineColorHexAndOpacity(
                            widget.colorController.text,
                            widget.opacityController.text,
                          ),
                        ) ??
                        0xFFFFFFFF,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                AppFlowyEditorLocalizations.current.customColor,
                style: TextStyle(
                  fontSize: 12,
                  // TODO(yijing):refactor style
                  // color: widget.pickerItemTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 6),
        _customColorDetailsTextField(
          labelText: AppFlowyEditorLocalizations.current.hexValue,
          controller: widget.colorController,
          // update the color sample box when the text changes
          onChanged: (_) => setState(() {}),
          onSubmitted: _submitCustomColorHex,
        ),
        const SizedBox(height: 6),
        _customColorDetailsTextField(
          labelText: AppFlowyEditorLocalizations.current.opacity,
          controller: widget.opacityController,
          // update the color sample box when the text changes
          onChanged: (_) => setState(() {}),
          onSubmitted: _submitCustomColorHex,
        ),
      ],
    );
  }

  Widget _customColorDetailsTextField({
    required String labelText,
    required TextEditingController controller,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }

  String _combineColorHexAndOpacity(String colorHex, String opacity) {
    colorHex = _fixColorHex(colorHex);
    opacity = _fixOpacity(opacity);
    final opacityHex = (int.parse(opacity) * 2.55).round().toRadixString(16);
    return '0x$opacityHex$colorHex';
  }

  String _fixColorHex(String colorHex) {
    if (colorHex.length > 6) {
      colorHex = colorHex.substring(0, 6);
    }
    if (int.tryParse(colorHex, radix: 16) == null) {
      colorHex = 'FFFFFF';
    }
    return colorHex;
  }

  String _fixOpacity(String opacity) {
    // if opacity is 0 - 99, return it
    // otherwise return 100
    RegExp regex = RegExp('^(0|[1-9][0-9]?)');
    if (regex.hasMatch(opacity)) {
      return opacity;
    } else {
      return '100';
    }
  }

  void _submitCustomColorHex(String value) {
    final String color = _combineColorHexAndOpacity(
      widget.colorController.text,
      widget.opacityController.text,
    );
    widget.onSubmittedColorHex(color);
  }
}
