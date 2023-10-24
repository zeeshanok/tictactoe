import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/common/responsive_builder.dart';

class GameSelectPage extends StatelessWidget {
  const GameSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final children = [
      GameTypeWidget(
        gameType: GameType.computer,
        onPressed: () => context.go('/play/singleplayer'),
      ),
      const SizedBox(width: 14, height: 14),
      GameTypeWidget(
        gameType: GameType.localMultiplayer,
        onPressed: () => context.go('/play/local-multiplayer'),
      ),
      const SizedBox(width: 14, height: 14),
      GameTypeWidget(
        gameType: GameType.online,
        onPressed: () => context.go('/play/multiplayer'),
      )
    ];
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Center(
        child: ResponsiveBuilder(
          mobileBuilder: (context) => FractionallySizedBox(
            widthFactor: 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
          desktopBuilder: (context) => Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
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
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(200, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
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
