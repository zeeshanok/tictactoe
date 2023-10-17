import 'package:flutter/material.dart';
import 'package:tictactoe/common/logic/player.dart';
import 'package:tictactoe/common/logic/tictactoe_board.dart';

class TicTacToeWidget extends StatelessWidget {
  const TicTacToeWidget({
    super.key,
    required this.cells,
    required this.onPlay,
  });

  final CellList cells;
  final void Function(Cell cell) onPlay;

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
                    cell: Cell.fromCoord(i, j),
                    text: playerNumConvert(
                      cells[Cell.fromCoord(i, j).index],
                    ),
                    onPressed: () => onPlay(Cell.fromCoord(i, j)),
                  ),
              ],
            )
        ],
      ),
    );
  }
}

class TicTacToeCell extends StatelessWidget {
  TicTacToeCell({
    required this.text,
    required this.size,
    required this.onPressed,
    required Cell cell, // this is for use as a key
  }) : super(key: ValueKey("$cell$text"));

  final double size;
  final String text;
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            textStyle:
                const TextStyle(fontSize: 50, fontWeight: FontWeight.w600),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
