import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tictactoe/common/logic/player.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/common/widgets/tictactoe_game.dart';

class LocalMultiplayerPage extends StatefulWidget {
  const LocalMultiplayerPage({super.key});

  @override
  State<LocalMultiplayerPage> createState() => _LocalMultiplayerPageState();
}

class _LocalMultiplayerPageState extends State<LocalMultiplayerPage> {
  StreamController<Cell>? controllerX, controllerO;

  late TicTacToe game;

  void closeControllers() {
    controllerX?.close();
    controllerO?.close();
  }

  void createGame() {
    closeControllers();

    controllerX = StreamController();
    controllerO = StreamController();

    game = TicTacToe(
      playerX: LocalPlayer(
        moveStream: controllerX!.stream,
        playerType: PlayerType.X,
      ),
      playerO: LocalPlayer(
        moveStream: controllerO!.stream,
        playerType: PlayerType.O,
      ),
    );
    game.startGame();
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
            child: TicTacToeGame(
          game: game,
          onPlay: (cell) => (game.currentPlayerType == PlayerType.X
                  ? controllerX
                  : controllerO)
              ?.sink
              .add(cell),
        )));
  }
}
