import 'package:flutter/material.dart';
import 'package:tictactoe/widgets/animated_text.dart';

class LabeledIconButton extends StatelessWidget {
  const LabeledIconButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    required this.icon,
    required this.text,
  });

  final void Function()? onPressed;
  final Color? backgroundColor;
  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(20),
          minimumSize: const Size(60, 0),
          alignment: Alignment.centerLeft,
          backgroundColor: backgroundColor,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
        ),
        icon: icon,
        label: AnimatedText(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
