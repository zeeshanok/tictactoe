import 'package:flutter/material.dart';
import 'package:tictactoe/common/logic/player.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';

class TicTacToeBoard extends StatelessWidget {
  const TicTacToeBoard({
    super.key,
    required this.cells,
    required this.onPlay,
  });

  final CellList cells;
  final void Function(Cell cell)? onPlay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int j = 0; j < 3; j++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++)
                  TicTacToeCell(
                    size: constraints.biggest.shortestSide / 3,
                    playerType: cells[Cell.fromCoord(i, j).index],
                    onPressed: () => onPlay?.call(Cell.fromCoord(i, j)),
                  ),
              ],
            )
        ],
      ),
    );
  }
}

class TicTacToeCell extends StatelessWidget {
  const TicTacToeCell({
    super.key,
    required this.playerType,
    required this.size,
    required this.onPressed,
  });

  final double size;
  final PlayerType? playerType;
  final void Function() onPressed;

  Color getBackgroundColor() {
    switch (playerType) {
      case null:
        return Colors.grey.shade600;
      case PlayerType.X:
        return Colors.red.shade300;
      case PlayerType.O:
        return Colors.blue.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Container(
        margin: const EdgeInsets.all(2),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            fixedSize: Size.square(size),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 80, fontWeight: FontWeight.w600),
            backgroundColor: getBackgroundColor().withOpacity(0.7),
            foregroundColor: Colors.white70,
          ),
          child: Text(playerTypeToString(playerType)),
        ),
      ),
    );
  }
}
