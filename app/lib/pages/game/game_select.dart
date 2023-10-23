import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/services/auth/auth_service.dart';
import 'package:tictactoe/common/widgets/user_widget.dart';

class GameSelectPage extends StatelessWidget {
  const GameSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    return Scaffold(
      appBar: AppBar(
        actions: [
          const UserWidget(),
          IconButton(
            onPressed: () async => authService.signOut(),
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () => context.go('/game/singleplayer'),
            child: const Text("Play with the computer"),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => context.go('/game/local-multiplayer'),
            child: const Text("Play locally with your friend"),
          )
        ],
      )),
    );
  }
}
