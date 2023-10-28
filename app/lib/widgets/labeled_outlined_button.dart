import 'package:flutter/material.dart';

class LabeledOutlinedButton extends StatelessWidget {
  const LabeledOutlinedButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(200, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 60,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                height: 1,
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ));
  }
}
