import 'package:flutter/material.dart';

class DefaultDialog extends StatelessWidget {
  const DefaultDialog({
    super.key,
    this.height,
    this.width,
    required this.child,
  });

  final double? height, width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: height,
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: child,
        ),
      ),
    );
  }
}
