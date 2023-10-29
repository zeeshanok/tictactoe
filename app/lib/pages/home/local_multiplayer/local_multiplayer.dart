import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tictactoe/logic/players/local_player.dart';
import 'package:tictactoe/logic/players/player.dart';
import 'package:tictactoe/logic/tictactoe.dart';
import 'package:tictactoe/widgets/choose_side.dart';
import 'package:tictactoe/widgets/tictactoe_game.dart';
import 'package:tictactoe/services/game_service.dart';
import 'package:tictactoe/services/user/user_service.dart';

const _otherPlayer = 'Player 2';

class LocalMultiplayerPage extends StatefulWidget {
  const LocalMultiplayerPage({super.key});

  @override
  State<LocalMultiplayerPage> createState() => _LocalMultiplayerPageState();
}

class _LocalMultiplayerPageState extends State<LocalMultiplayerPage> {
  StreamController<Cell>? controllerX, controllerO;

  TicTacToe? game;

  void closeControllers() {
    controllerX?.close();
    controllerO?.close();
  }

  void createGame(PlayerType playerType) {
    closeControllers();

    final id = GetIt.instance<UserService>().currentUser!.id;

    controllerX = StreamController();
    controllerO = StreamController();

    final isX = playerType == PlayerType.X;

    game = TicTacToe(
      playerX: LocalPlayer(
        moveStream: controllerX!.stream,
        playerType: PlayerType.X,
        gameType: GameType.localMultiplayer,
        internalName: isX ? id.toString() : _otherPlayer,
      ),
      playerO: LocalPlayer(
        moveStream: controllerO!.stream,
        playerType: PlayerType.O,
        gameType: GameType.localMultiplayer,
        internalName: !isX ? id.toString() : _otherPlayer,
      ),
      gameType: GameType.localMultiplayer,
      onGameEnd: (game) async =>
          await GetIt.instance<GameService>().addGame(game),
    );
    game!.startGame();
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
                game = null;
              });
            },
            icon: const Icon(Icons.replay_rounded),
            tooltip: "Restart",
          )
        ]),
        body: Center(
            child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: game == null
              ? ChooseSide(
                  onChoose: (playerType) => setState(() {
                    createGame(playerType);
                  }),
                )
              : TicTacToeGame(
                  game: game!,
                  onPlay: (cell) => (game!.currentPlayerType == PlayerType.X
                          ? controllerX
                          : controllerO)
                      ?.sink
                      .add(cell),
                ),
        )));
  }
}
