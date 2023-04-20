import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';

abstract class TextInputService {
  TextInputService({
    required this.onInsert,
    required this.onDelete,
    required this.onReplace,
    required this.onNonTextUpdate,
    required this.onPerformAction,
  });

  Future<void> Function(TextEditingDeltaInsertion insertion) onInsert;
  Future<void> Function(TextEditingDeltaDeletion deletion) onDelete;
  Future<void> Function(TextEditingDeltaReplacement replacement) onReplace;
  Future<void> Function(TextEditingDeltaNonTextUpdate nonTextUpdate)
      onNonTextUpdate;
  Future<void> Function(TextInputAction action) onPerformAction;

  TextRange? composingTextRange;
  bool get attached;

  void updateCaretPosition(Size size, Matrix4 transform, Rect rect);

  /// Updates the [TextEditingValue] of the text currently being edited.
  ///
  /// Note that if there are IME-related requirements,
  ///   please config `composing` value within [TextEditingValue]
  void attach(TextEditingValue textEditingValue);

  /// Applies insertion, deletion and replacement
  ///   to the text currently being edited.
  ///
  /// For more information, please check [TextEditingDelta].
  Future<void> apply(List<TextEditingDelta> deltas);

  /// Closes the editing state of the text currently being edited.
  void close();
}

class DeltaTextInputService extends TextInputService with DeltaTextInputClient {
  DeltaTextInputService({
    required super.onInsert,
    required super.onDelete,
    required super.onReplace,
    required super.onNonTextUpdate,
    required super.onPerformAction,
  });

  TextInputConnection? textInputConnection;

  @override
  TextRange? composingTextRange;

  @override
  bool get attached => textInputConnection?.attached ?? false;

  @override
  AutofillScope? get currentAutofillScope => throw UnimplementedError();

  @override
  TextEditingValue? get currentTextEditingValue => throw UnimplementedError();

  @override
  Future<void> apply(List<TextEditingDelta> deltas) async {
    for (final delta in deltas) {
      _updateComposing(delta);

      if (delta is TextEditingDeltaInsertion) {
        await onInsert(delta);
      } else if (delta is TextEditingDeltaDeletion) {
        await onDelete(delta);
      } else if (delta is TextEditingDeltaReplacement) {
        await onReplace(delta);
      } else if (delta is TextEditingDeltaNonTextUpdate) {
        await onNonTextUpdate(delta);
      }
    }
  }

  @override
  void attach(TextEditingValue textEditingValue) {
    if (textInputConnection == null || textInputConnection!.attached == false) {
      textInputConnection = TextInput.attach(
        this,
        const TextInputConfiguration(
          enableDeltaModel: true,
          inputType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          inputAction: TextInputAction.newline,
        ),
      );
    }

    textInputConnection!
      ..setEditingState(textEditingValue)
      ..show();
  }

  @override
  void close() {
    textInputConnection?.close();
    textInputConnection = null;
  }

  @override
  void updateEditingValueWithDeltas(List<TextEditingDelta> textEditingDeltas) {
    Log.input.debug(
      textEditingDeltas.map((delta) => delta.toString()).toString(),
    );
    apply(textEditingDeltas);
  }

  // TODO: support IME in linux / windows / ios / android
  // Only support macOS now.
  @override
  void updateCaretPosition(Size size, Matrix4 transform, Rect rect) {
    textInputConnection
      ?..setEditableSizeAndTransform(size, transform)
      ..setCaretRect(rect);
  }

  @override
  void connectionClosed() {}

  @override
  void insertTextPlaceholder(Size size) {}

  @override
  Future<void> performAction(TextInputAction action) async {
    return onPerformAction(action);
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void removeTextPlaceholder() {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void showToolbar() {}

  @override
  void updateEditingValue(TextEditingValue value) {}

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void didChangeInputControl(
    TextInputControl? oldControl,
    TextInputControl? newControl,
  ) {}

  @override
  void performSelector(String selectorName) {}

  void _updateComposing(TextEditingDelta delta) {
    if (delta is! TextEditingDeltaNonTextUpdate) {
      if (composingTextRange != null &&
          composingTextRange!.start != -1 &&
          delta.composing.end != -1) {
        composingTextRange = TextRange(
          start: composingTextRange!.start,
          end: delta.composing.end,
        );
      } else {
        composingTextRange = delta.composing;
      }
    }
  }
}