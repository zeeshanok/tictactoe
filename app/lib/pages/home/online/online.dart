import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:tictactoe/common/utils.dart';
import 'package:tictactoe/logic/players/local_player.dart';
import 'package:tictactoe/logic/players/player.dart';
import 'package:tictactoe/logic/players/web_socket_player.dart';
import 'package:tictactoe/logic/tictactoe.dart';
import 'package:tictactoe/widgets/responsive_builder.dart';
import 'package:tictactoe/widgets/labeled_outlined_button.dart';
import 'package:tictactoe/widgets/tictactoe_game.dart';
import 'package:tictactoe/managers/multiplayer_game.dart';
import 'package:tictactoe/pages/home/online/create_game.dart';
import 'package:tictactoe/pages/home/online/join_game.dart';
import 'package:tictactoe/services/user/user_service.dart';

class OnlinePage extends StatefulWidget {
  const OnlinePage({super.key});

  @override
  State<OnlinePage> createState() => _OnlinePageState();
}

class _OnlinePageState extends State<OnlinePage> {
  TicTacToe? game;
  StreamController<Cell>? controller;

  void onWebSocketPlayerDisconnect() {
    context.pop();
    globalNotify("Your opponent disconnected");
  }

  void createGame(MultiplayerGameManager manager) async {
    final users = GetIt.instance<UserService>();
    final opponent = await users.fetchUserById(manager.opponentUserId!);
    final currentUser = users.currentUser!;

    if (opponent != null) {
      controller = StreamController();
      final oppPlayer = WebSocketPlayer(
        user: opponent,
        channel: manager.channel,
        stream: manager.stream,
        onDisconnect: onWebSocketPlayerDisconnect,
      );

      final localPlayer = LocalPlayer(
        moveStream: controller!.stream,
        playerType: manager.currentUserSide,
        gameType: GameType.online,
        internalName: currentUser.id.toString(),
      );

      final isX = manager.currentUserSide == PlayerType.X;

      void onGameEnd(TicTacToe game) {
        if (game.currentPlayer is WebSocketPlayer) {
          // let websocket player get the last move
          oppPlayer.sendMove(game.moves.last);
        } else {
          oppPlayer.endGame(game.moves);
        }
      }

      setState(() => game = TicTacToe(
            playerX: isX ? localPlayer : oppPlayer,
            playerO: isX ? oppPlayer : localPlayer,
            gameType: GameType.localMultiplayer,
            onGameEnd: onGameEnd,
          ));

      game!.startGame();
    }
    // we don't need this anymore
    manager.stopListening();
  }

  void doCreateGame() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateGameDialog(),
    );
    if (result is MultiplayerGameManager) {
      createGame(result);
    }
  }

  void doJoinGame() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const JoinGameDialog(),
    );
    if (result is MultiplayerGameManager) {
      createGame(result);
    }
  }

  void Function() createGameWrapper(Widget child) => () async {
        final result = await showDialog(
          context: context,
          builder: (context) => child,
        );
        if (result is MultiplayerGameManager) {
          createGame(result);
        }
      };

  Widget buildPreGame(BuildContext context) {
    return JoinOrCreateGame(
      onCreate: createGameWrapper(const CreateGameDialog()),
      onJoin: createGameWrapper(const JoinGameDialog()),
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

  @override
  void dispose() {
    controller?.close();
    game?.dispose();
    super.dispose();
  }
}

class JoinOrCreateGame extends StatelessWidget {
  const JoinOrCreateGame({
    super.key,
    required this.onCreate,
    required this.onJoin,
  });

  final void Function() onCreate, onJoin;

  @override
  Widget build(BuildContext context) {
    final children = [
      LabeledOutlinedButton(
        label: "Join game",
        icon: Icons.language_rounded,
        onPressed: onJoin,
      ),
      const SizedBox.square(dimension: 8),
      LabeledOutlinedButton(
        label: "Create game",
        icon: Icons.add_rounded,
        onPressed: onCreate,
      ),
    ];

    return ResponsiveBuilder(
      mobileBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
      desktopBuilder: (context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
