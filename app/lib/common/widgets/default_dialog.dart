import 'package:flutter/material.dart';

class DefaultDialog extends StatelessWidget {
  const DefaultDialog({
    super.key,
    this.height,
    this.width,
    this.onWillPop,
    required this.child,
  });

  final double? height, width;
  final Widget child;
  final Future<bool> Function()? onWillPop;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Dialog(
        child: SizedBox(
          height: height,
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: child,
          ),
        ),
      ),
    );
  }
}
