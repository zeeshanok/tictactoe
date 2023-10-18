import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameSelectPage extends StatelessWidget {
  const GameSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () => context.go('/singleplayer'),
            child: const Text("Play with the computer"),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => context.go('/local-multiplayer'),
            child: const Text("Play locally with your friend"),
          )
        ],
      )),
    );
  }
}
