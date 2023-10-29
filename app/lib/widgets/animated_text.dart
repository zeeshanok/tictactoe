import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedText extends StatelessWidget {
  const AnimatedText(this.data, {super.key, this.style});

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: 200.ms,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: Text(
        data,
        key: ValueKey(data),
        style: style,
      ),
    );
  }
}

class AnimatedTextRich extends StatelessWidget {
  const AnimatedTextRich(this.textSpan, {super.key});

  final InlineSpan textSpan;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: 200.ms,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: Text.rich(textSpan, key: ValueKey(textSpan.toPlainText())),
    );
  }
}
