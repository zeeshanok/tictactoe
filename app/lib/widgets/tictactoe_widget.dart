import 'package:flutter/material.dart';
import 'package:tictactoe/logic/players/player.dart';
import 'package:tictactoe/logic/tictactoe.dart';
import 'package:tictactoe/common/utils.dart';

class TicTacToeBoard extends StatelessWidget {
  const TicTacToeBoard({
    super.key,
    required this.cells,
    this.onPlay,
    this.fontSize,
  });

  final PlayList cells;
  final void Function(Cell cell)? onPlay;
  final double? fontSize;

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
                    fontSize: fontSize,
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
    this.fontSize,
  });

  final double size;
  final double? fontSize;
  final PlayerType? playerType;
  final void Function() onPressed;

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
            shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
            alignment: Alignment.center,
            padding: EdgeInsets.zero,
            textStyle: TextStyle(
              fontSize: fontSize ?? 80,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor:
                (playerType?.color ?? Colors.grey.shade600).withOpacity(0.7),
            foregroundColor: Colors.white70,
          ),
          child: Text(playerType?.name ?? ""),
        ),
      ),
    );
  }
}
