import 'package:flutter/material.dart';
import 'package:tictactoe/logic/players/player.dart';
import 'package:tictactoe/widgets/tictactoe_widget.dart';

class ChooseSide extends StatelessWidget {
  const ChooseSide({super.key, required this.onChoose});

  final void Function(PlayerType playerType) onChoose;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Choose a side",
          style: TextStyle(fontSize: 30),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TicTacToeCell(
              playerType: PlayerType.X,
              size: 100,
              fontSize: 34,
              onPressed: () => onChoose(PlayerType.X),
            ),
            TicTacToeCell(
              playerType: PlayerType.O,
              size: 100,
              fontSize: 34,
              onPressed: () => onChoose(PlayerType.O),
            ),
          ],
        )
      ],
    );
  }
}
