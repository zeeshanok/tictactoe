import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
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
            tooltip: 'Sign out',
          )
        ],
      ),
      body: Center(
          child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameTypeWidget(
            gameType: GameType.computer,
            onPressed: () => context.go('/game/singleplayer'),
          ),
          const SizedBox(width: 14),
          GameTypeWidget(
            gameType: GameType.localMultiplayer,
            onPressed: () => context.go('/game/local-multiplayer'),
          ),
          const SizedBox(width: 14),
          GameTypeWidget(
            gameType: GameType.online,
            onPressed: () => context.go('/game/multiplayer'),
          )
        ],
      )),
    );
  }
}

class GameTypeWidget extends StatelessWidget {
  const GameTypeWidget(
      {super.key, required this.gameType, required this.onPressed});

  final GameType gameType;
  final void Function() onPressed;

  String buildText() => switch (gameType) {
        GameType.computer => "Play with the computer",
        GameType.localMultiplayer => "Play locally with a friend",
        GameType.online => "Play online"
      };

  IconData buildIcon() => switch (gameType) {
        GameType.computer => Icons.monitor_rounded,
        GameType.localMultiplayer => Icons.people_alt_rounded,
        GameType.online => Icons.language_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(minimumSize: const Size(200, 0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              buildIcon(),
              size: 60,
            ),
            const SizedBox(height: 8),
            Text(
              buildText(),
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
