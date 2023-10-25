import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tictactoe/common/logic/player.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/common/widgets/tictactoe_game.dart';
import 'package:tictactoe/pages/home/online/create_game.dart';

class OnlinePage extends StatefulWidget {
  const OnlinePage({super.key});

  @override
  State<OnlinePage> createState() => _OnlinePageState();
}

class _OnlinePageState extends State<OnlinePage> {
  PlayerType? side;
  TicTacToe? game;
  StreamController<Cell>? controller;

  Widget buildPreGame(BuildContext context) {
    return JoinOrCreateGame(
      onCreate: () => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CreateGameDialog(),
      ),
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
                  onPlay: (cell) => controller?.sink.add(cell),
                ),
        )));
  }
}
