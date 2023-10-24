import 'package:flutter/material.dart';

class IgnoreMouse extends StatelessWidget {
  const IgnoreMouse({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      descendantsAreFocusable: false,
      descendantsAreTraversable: false,
      child: IgnorePointer(
        child: Stack(
          children: [
            child,
            const MouseRegion(
              child: SizedBox.expand(),
            )
          ],
        ),
      ),
    );
  }
}
