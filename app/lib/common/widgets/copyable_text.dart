import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableText extends StatelessWidget {
  const CopyableText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
          text: text,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Clipboard.setData(ClipboardData(text: text));
            }),
      style: (style ?? const TextStyle())
          .copyWith(decoration: TextDecoration.underline),
    );
  }
}
