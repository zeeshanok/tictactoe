import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:tictactoe/common/logic/player.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/common/utils.dart';
import 'package:tictactoe/common/widgets/ignore_mouse.dart';
import 'package:tictactoe/common/widgets/tictactoe_widget.dart';
import 'package:tictactoe/common/widgets/user_widget.dart';
import 'package:tictactoe/models/game.dart';
import 'package:tictactoe/services/user_service.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({super.key, required this.game});

  final TicTacToeGameModel game;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: IgnoreMouse(
                child: TicTacToeBoard(
                  cells: game.moves.toPlayList(),
                  fontSize: 30,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GameDetails(game: game),
          ],
        ),
      ),
    );
  }
}

class GameDetails extends StatelessWidget {
  const GameDetails({super.key, required this.game});

  final TicTacToeGameModel game;

  String getResultText() =>
      switch (getResultFromCells(game.moves.toPlayList())) {
        null => "This game did not end", // really shouldn't reach here
        DrawResult() => "Draw",
        WinResult(:final playerType) => getWinText(playerType),
        _ => throw UnimplementedError()
      };

  String getWinText(PlayerType winner) {
    final user = GetIt.instance<UserService>().currentUser!;
    if ((winner == PlayerType.X && game.playerX == user) ||
        (winner == PlayerType.X && game.playerO == user)) {
      return "You won";
    }
    return "You lost";
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('hh:mm a d MMMM');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // convert from utc time to local
        Text(
          getResultText(),
          style: const TextStyle(fontSize: 40),
        ),
        Text.rich(TextSpan(children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: PlayerNameWithType(
              name: game.playerXName,
              type: PlayerType.X,
            ),
          ),
          const TextSpan(text: " vs "),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: PlayerNameWithType(
              name: game.playerOName,
              type: PlayerType.O,
            ),
          )
        ])),
        const Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(format.format(game.createdAt.toLocal())),
        ),
      ],
    );
  }
}

class PlayerNameWithType extends StatelessWidget {
  const PlayerNameWithType({super.key, required this.name, required this.type});

  final String name;
  final PlayerType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: type.color.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(name),
    );
  }
}
