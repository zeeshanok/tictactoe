import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:tictactoe/logic/players/player.dart';
import 'package:tictactoe/logic/tictactoe.dart';

class MiniMaxComputerPlayer implements Player {
  /// The player type assigned to us
  final PlayerType playerType;

  @override
  final String internalName;

  MiniMaxComputerPlayer({required this.playerType}) : internalName = 'Computer';

  (int action, int value) minimax({
    required PlayList state,
    int? action,
  }) {
    final stateResult = getResultFromCells(state);
    final currentPlayer = getCurrentPlayerType(state);
    final moves = possibleMoves(state);
    if (moves.length == 9) {
      return (Random().nextInt(9), 0);
    }
    if (stateResult != null) {
      return (action!, valueOfResult(stateResult) * (moves.length + 1));
    }

    var best = (0, -12);
    for (final a in possibleMoves(state)) {
      state[a] = currentPlayer;
      final r = minimax(state: state, action: a);
      if (r.$2 > best.$2) {
        best = r;
      }
      // undo
      state[a] = null;
    }
    return best;
  }

  int valueOfResult(GameResult result) {
    switch (result) {
      case WinResult win:
        return win.playerType == playerType ? -1 : 1;
      default:
        return 0;
    }
  }

  /// Returns indexes of possible moves
  Iterable<int> possibleMoves(PlayList cells) {
    return cells.indexed.where((p) => p.$2 == null).map((e) => e.$1);
  }

  PlayList getActionResult(int action, PlayerType playerType, PlayList cells) {
    return cells.indexed
        .map((e) => e.$1 == action ? playerType : e.$2)
        .toList();
  }

  @override
  Future<Cell> getMove(TicTacToe board) async {
    final result = (await Future.wait([
      compute((state) => minimax(state: state), board.cells),
      Future.delayed(const Duration(seconds: 1))
    ]))[0] as (int, int);
    return Cell.fromIndex(result.$1);
  }

  @override
  String get turnText => "Computer's turn (${playerType.name})";

  @override
  String get winText => "Computer wins(${playerType.name})";

  @override
  void dispose() {}
}
