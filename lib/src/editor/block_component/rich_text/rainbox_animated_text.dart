import 'package:flutter/material.dart';

class RainbowRichText extends StatefulWidget {
  final List<InlineSpan> children;
  final TextAlign textAlign;

  const RainbowRichText({
    super.key,
    required this.children,
    this.textAlign = TextAlign.start,
  });

  @override
  State<RainbowRichText> createState() => _RainbowRichTextState();
}

class _RainbowRichTextState extends State<RainbowRichText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _rainbowColor(double value) {
    // Creates a color from HSV where:
    // - Hue cycles through the rainbow (0-360)
    // - Saturation is at max (1.0)
    // - Value/brightness is at max (1.0)
    final hue = (value * 360) % 360;
    return HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return RichText(
          textAlign: widget.textAlign,
          text: TextSpan(
            children: widget.children.map((span) {
              if (span is TextSpan) {
                return TextSpan(
                  text: span.text,
                  style: (span.style ?? const TextStyle()).copyWith(
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          for (double i = 0; i < 1; i += 0.1)
                            _rainbowColor((i + _controller.value) % 1.0),
                        ],
                      ).createShader(
                        const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                      ),
                  ),
                );
              }
              return span;
            }).toList(),
          ),
        );
      },
    );
  }
}
