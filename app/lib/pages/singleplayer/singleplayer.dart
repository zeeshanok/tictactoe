import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tictactoe/common/logic/player.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/common/widgets/tictactoe_game.dart';
import 'package:tictactoe/common/widgets/tictactoe_widget.dart';

class SinglePlayerPage extends StatefulWidget {
  const SinglePlayerPage({super.key});

  @override
  State<SinglePlayerPage> createState() => _SinglePlayerPageState();
}

class _SinglePlayerPageState extends State<SinglePlayerPage> {
  StreamController<Cell>? controller;
  TicTacToe? game;

  void createGame(PlayerType localPlayer) {
    controller = StreamController();
    final isX = localPlayer == PlayerType.X;
    final l =
        LocalPlayer(moveStream: controller!.stream, playerType: localPlayer);
    final m = MiniMaxComputerPlayer(playerType: flipPlayerType(localPlayer));
    game = TicTacToe(
      playerX: isX ? l : m,
      playerO: isX ? m : l,
    );
    game!.startGame();
  }

  @override
  void dispose() {
    controller?.close();
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
              controller = null;
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
                  onPlay: (cell) => controller?.sink.add(cell),
                ),
        ),
      ),
    );
  }
}

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
              size: 150,
              onPressed: () => onChoose(PlayerType.X),
            ),
            TicTacToeCell(
              playerType: PlayerType.O,
              size: 150,
              onPressed: () => onChoose(PlayerType.O),
            ),
          ],
        )
      ],
    );
  }
}
