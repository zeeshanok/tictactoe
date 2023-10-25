import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tictactoe/common/logic/player.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/common/widgets/tictactoe_game.dart';
import 'package:tictactoe/managers/multiplayer_game.dart';
import 'package:tictactoe/pages/home/online/create_game.dart';
import 'package:tictactoe/services/user_service.dart';

class OnlinePage extends StatefulWidget {
  const OnlinePage({super.key});

  @override
  State<OnlinePage> createState() => _OnlinePageState();
}

class _OnlinePageState extends State<OnlinePage> {
  TicTacToe? game;
  StreamController<Cell>? controller;

  void doCreateGame() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateGameDialog(),
    );
    if (result is MultiplayerGameManager) {
      final users = GetIt.instance<UserService>();
      final opponent = await users.fetchUserById(result.opponentUserId!);
      final currentUser = users.currentUser!;
      if (opponent != null) {
        controller = StreamController();
        final oppPlayer = WebSocketPlayer(
          user: opponent,
          channel: result.channel,
          stream: result.stream,
        );

        final localPlayer = LocalPlayer(
          moveStream: controller!.stream,
          playerType: result.currentUserSide,
          internalName: currentUser.id.toString(),
        );
        final isX = result.currentUserSide == PlayerType.X;
        setState(() => game = TicTacToe(
              playerX: isX ? localPlayer : oppPlayer,
              playerO: isX ? oppPlayer : localPlayer,
              gameType: GameType.localMultiplayer,
              onGameEnd: (game) {
                if (game.currentPlayer is WebSocketPlayer) {
                  // let websocket player get the last move
                  oppPlayer.sendMove(game.moves.last);
                } else {
                  oppPlayer.endGame();
                }
                result.endGame();
              },
            ));
        game!.startGame();
      } else {
        result.endGame();
      }
    }
  }

  Widget buildPreGame(BuildContext context) {
    return JoinOrCreateGame(
      onCreate: doCreateGame,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: game == null
              ? buildPreGame(context)
              : TicTacToeGame(
                  game: game!,
                  onPlay: (cell) {
                    if (game!.currentPlayer is LocalPlayer) {
                      controller?.sink.add(cell);
                    }
                  },
                ),
        )));
  }
}
