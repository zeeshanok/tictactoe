import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tictactoe/common/logic/player.dart';
import 'package:tictactoe/common/logic/tictactoe_board.dart';
import 'package:tictactoe/common/widgets/tictactoe_widget.dart';

class LocalMultiplayerPage extends StatefulWidget {
  const LocalMultiplayerPage({super.key});

  @override
  State<LocalMultiplayerPage> createState() => _LocalMultiplayerPageState();
}

class _LocalMultiplayerPageState extends State<LocalMultiplayerPage> {
  StreamController<Cell>? controllerX, controllerO;

  late TicTacToeBoard game;

  void closeControllers() {
    controllerX?.close();
    controllerO?.close();
  }

  void createGame() {
    closeControllers();

    controllerX = StreamController();
    controllerO = StreamController();

    game = TicTacToeBoard(
      playerX: LocalPlayer(moveStream: controllerX!.stream),
      playerO: LocalPlayer(moveStream: controllerO!.stream),
    );
    game.startGame();
  }

  String buildStatusText() {
    switch (game.result) {
      case DrawResult _:
        return "Draw";
      case WinResult win:
        return "${win.player} wins";
      default:
        return "${playerNumConvert(game.currentPlayer)}'s turn";
    }
  }

  @override
  void initState() {
    createGame();
    super.initState();
  }

  @override
  void dispose() {
    closeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
          IconButton(
            onPressed: () {
              setState(() {
                createGame();
              });
            },
            icon: const Icon(Icons.replay_rounded),
            tooltip: "Restart",
          )
        ]),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 400,
                child: TicTacToeWidget(
                  cells: game.cells,
                  onPlay: (cell) => setState(() {
                    (game.currentPlayer == PlayerType.X
                            ? controllerX
                            : controllerO)
                        ?.sink
                        .add(cell);
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Text(buildStatusText())
            ],
          ),
        ));
  }
}
