import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';

enum PlayerType { O, X }

PlayerType flipPlayerType(PlayerType p) {
  return PlayerType.values[1 - (p.index)];
}

/// Convert player number to text
String playerTypeToString(PlayerType? playerType) {
  switch (playerType) {
    case PlayerType.X:
      return "X";
    case PlayerType.O:
      return "O";
    default:
      return "";
  }
}

abstract class Player {
  String get displayName;

  /// Get player's next move given the current state of the board
  Future<Cell?> getMove(TicTacToe board);
}

class LocalPlayer implements Player {
  /// Stream of moves that the local player plays.
  /// Moves should be added to this stream from the UI.
  final Stream<Cell> _moveStream;

  final String _displayName;
  @override
  String get displayName => _displayName;

  LocalPlayer(
      {required Stream<Cell> moveStream, required PlayerType playerType})
      : _moveStream = moveStream.asBroadcastStream(),
        _displayName = playerTypeToString(playerType);

  @override
  Future<Cell?> getMove(TicTacToe board) async {
    // The `board` parameter has no use here since the ui
    // passes in the moves of the player.
    debugPrint("waiting for move");

    return await _moveStream.firstOrNull;
  }
}

class MiniMaxComputerPlayer implements Player {
  /// The player type assigned to us
  final PlayerType playerType;

  @override
  String get displayName => "Computer (${playerTypeToString(playerType)})";

  MiniMaxComputerPlayer({required this.playerType});

  (int action, int value) minimax({
    required CellList state,
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
  Iterable<int> possibleMoves(CellList cells) {
    return cells.indexed.where((p) => p.$2 == null).map((e) => e.$1);
  }

  CellList getActionResult(int action, PlayerType playerType, CellList cells) {
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
}
