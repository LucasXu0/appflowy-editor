import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class TextSpanGenerator {
  static TextSpan getTextSpan({
    required BuildContext context,
    required Node node,
    required Iterable<TextInsert> textInserts,
    required TextStyleConfiguration textStyleConfiguration,
    required TextSpanDecoratorForAttribute? textSpanDecoratorForAttribute,
    required AppFlowyTextSpanDecorator? textSpanDecorator,
  }) {
    int offset = 0;
    List<InlineSpan> textSpans = [];
    for (final textInsert in textInserts) {
      TextStyle textStyle = textStyleConfiguration.text.copyWith(
        height: textStyleConfiguration.lineHeight,
      );
      final attributes = textInsert.attributes;
      if (attributes != null) {
        if (attributes.bold == true) {
          textStyle = textStyle.combine(textStyleConfiguration.bold);
        }
        if (attributes.italic == true) {
          textStyle = textStyle.combine(textStyleConfiguration.italic);
        }
        if (attributes.underline == true) {
          textStyle = textStyle.combine(textStyleConfiguration.underline);
        }
        if (attributes.strikethrough == true) {
          textStyle = textStyle.combine(textStyleConfiguration.strikethrough);
        }
        if (attributes.href != null) {
          textStyle = textStyle.combine(textStyleConfiguration.href);
        }
        if (attributes.code == true) {
          textStyle = textStyle.combine(textStyleConfiguration.code);
        }
        if (attributes.backgroundColor != null) {
          textStyle = textStyle.combine(
            TextStyle(backgroundColor: attributes.backgroundColor),
          );
        }
        if (attributes.findBackgroundColor != null) {
          textStyle = textStyle.combine(
            TextStyle(backgroundColor: attributes.findBackgroundColor),
          );
        }
        if (attributes.color != null) {
          textStyle = textStyle.combine(
            TextStyle(color: attributes.color),
          );
        }
        if (attributes.fontFamily != null) {
          textStyle = textStyle.combine(
            TextStyle(fontFamily: attributes.fontFamily),
          );
        }
        if (attributes.fontSize != null) {
          textStyle = textStyle.combine(
            TextStyle(fontSize: attributes.fontSize),
          );
        }
        if (attributes.autoComplete == true) {
          textStyle = textStyle.combine(textStyleConfiguration.autoComplete);
        }
        if (attributes.transparent == true) {
          textStyle = textStyle.combine(
            const TextStyle(color: Colors.transparent),
          );
        }
      }
      final textSpan = TextSpan(
        text: textInsert.text,
        style: textStyle,
      );
      textSpans.add(
        textSpanDecoratorForAttribute != null
            ? textSpanDecoratorForAttribute(
                context,
                node,
                offset,
                textInsert,
                textSpan,
                textSpanDecorator?.call(textSpan) ?? textSpan,
              )
            : textSpan,
      );
      offset += textInsert.length;
    }

    return TextSpan(
      children: textSpans,
    );
  }

  static List<AnimatedText> getFadeAnimatedText({
    required BuildContext context,
    required Node node,
    required Iterable<TextInsert> textInserts,
    required TextStyleConfiguration textStyleConfiguration,
    required TextSpanDecoratorForAttribute? textSpanDecoratorForAttribute,
    required AppFlowyTextSpanDecorator? textSpanDecorator,
  }) {
    final textSpan = getTextSpan(
      context: context,
      node: node,
      textInserts: textInserts,
      textStyleConfiguration: textStyleConfiguration,
      textSpanDecoratorForAttribute: textSpanDecoratorForAttribute,
      textSpanDecorator: textSpanDecorator,
    );

    final animatedTexts = <AnimatedText>[];
    final textSpans = textSpan.children;

    if (textSpans == null || textSpans.isEmpty) {
      return animatedTexts;
    }

    const colorizeColors = [
      Colors.purple,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ];

    for (final textSpan in textSpans) {
      if (textSpan is TextSpan) {
        final text = textSpan.text;
        final style = textSpan.style;
        if (text != null && style != null) {
          animatedTexts.add(
            ColorizeAnimatedText(
              text,
              textStyle: style,
              colors: colorizeColors,
            ),
          );
        }
      }
    }

    return animatedTexts;
  }
}
