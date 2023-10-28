import 'package:async/async.dart';
import 'package:tictactoe/logic/players/player.dart';
import 'package:tictactoe/logic/tictactoe.dart';

class LocalPlayer implements Player {
  /// Stream of moves that the local player plays.
  /// Moves should be added to this stream from the UI.
  final Stream<Cell> _moveStream;

  @override
  String get internalName => _internalName;
  final String _internalName;

  @override
  String get turnText => gameType == GameType.localMultiplayer
      ? "${playerType.name}'s turn"
      : "Your turn";

  @override
  String get winText => gameType == GameType.localMultiplayer
      ? "${playerType.name} wins"
      : "You win";

  final PlayerType playerType;
  final GameType gameType;

  LocalPlayer({
    required Stream<Cell> moveStream,
    required String internalName,
    required this.playerType,
    required this.gameType,
    String? displayName,
  })  : _moveStream = moveStream.asBroadcastStream(),
        _internalName = internalName;

  @override
  Future<Cell?> getMove(TicTacToe board) async {
    // The `board` parameter has no use here since the ui
    // passes in the moves of the player.

    return await _moveStream.firstOrNull;
  }

  @override
  void dispose() {}
}
