import 'package:tictactoe/common/logic/tictactoe_board.dart';

enum PlayerType { O, X }

/// Convert player number to text
String playerNumConvert(PlayerType? player) {
  switch (player) {
    case PlayerType.X:
      return "X";
    case PlayerType.O:
      return "O";
    default:
      return "";
  }
}

abstract class Player {
  /// Get player's next move given the current state of the board
  Future<Cell> getMove(TicTacToeBoard board);
}

class LocalPlayer implements Player {
  /// Stream of moves that the local player plays.
  /// Moves should be added to this stream from the UI.
  final Stream<Cell> _moveStream;

  LocalPlayer({required Stream<Cell> moveStream})
      : _moveStream = moveStream.asBroadcastStream();

  @override
  Future<Cell> getMove(TicTacToeBoard board) async {
    // The `board` parameter has no use here since the ui
    // passes in the moves of the player.
    return await _moveStream.first;
  }
}

