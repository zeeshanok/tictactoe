import 'package:flutter/material.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/common/widgets/tictactoe_widget.dart';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key, required this.game, required this.onPlay});

  final TicTacToe game;
  final void Function(Cell)? onPlay;

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  String buildStatusText(TicTacToe game) {
    switch (game.result) {
      case DrawResult _:
        return "Draw";
      case WinResult win:
        return "${win.player} wins";
      default:
        return "${game.currentPlayer.displayName}'s turn";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.game,
      builder: (context, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 400,
            child: TicTacToeBoard(
              cells: widget.game.cells,
              onPlay: widget.onPlay,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            buildStatusText(widget.game),
            style: const TextStyle(fontSize: 40),
          )
        ],
      ),
    );
  }
}
