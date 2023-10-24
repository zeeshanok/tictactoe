import 'package:flutter/material.dart';

class AnimatedText extends StatelessWidget {
  const AnimatedText(this.data, {super.key, this.style});

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
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
