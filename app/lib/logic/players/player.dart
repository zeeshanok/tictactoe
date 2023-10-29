import 'package:flutter/material.dart';
import 'package:tictactoe/logic/tictactoe.dart';

enum PlayerType { O, X }

extension PlayerTypeUtils on PlayerType {
  PlayerType get flipped => PlayerType.values[1 - (index)];
  Color get color => switch (this) {
        PlayerType.X => Colors.red.shade300,
        PlayerType.O => Colors.blue.shade300,
      };
}

abstract class Player {
  /// Name stored in the server's database
  String get internalName;

  /// The text displayed on screen when it is this `Player`'s turn
  String get turnText;

  /// The text displayed on screen when this `Player` wins.
  String get winText;

  /// Get player's next move given the current state of the board
  Future<Cell?> getMove(TicTacToe board);

  /// Method thats called when the enclosing `TicTacToe` game calls `dispose`
  void dispose();
}
