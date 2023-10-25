import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/models/user.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum PlayerType { O, X }

extension PlayerTypeUtils on PlayerType {
  PlayerType get flipped => PlayerType.values[1 - (index)];
  Color get color => switch (this) {
        PlayerType.X => Colors.red.shade300,
        PlayerType.O => Colors.blue.shade300,
      };
}

abstract class Player {
  String get displayName;
  String get internalName;

  /// Get player's next move given the current state of the board
  Future<Cell?> getMove(TicTacToe board);
}

class LocalPlayer implements Player {
  /// Stream of moves that the local player plays.
  /// Moves should be added to this stream from the UI.
  final Stream<Cell> _moveStream;
  @override
  String get displayName => _displayName;
  final String _displayName;

  @override
  String get internalName => _internalName;
  final String _internalName;

  LocalPlayer({
    required Stream<Cell> moveStream,
    required PlayerType playerType,
    required String internalName,
  })  : _moveStream = moveStream.asBroadcastStream(),
        _displayName = playerType.name,
        _internalName = internalName;

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
  String get displayName => "Computer (${playerType.name})";

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
}

class WebSocketPlayer implements Player {
  final User _user;

  @override
  String get displayName => _user.username ?? "unknown username";

  @override
  String get internalName => _user.id.toString();

  final Stream<dynamic> _websocketStream;
  final WebSocketChannel _websocketChannel;

  final StreamController<Cell> _moveStreamController;

  WebSocketPlayer(
      {required User user,
      required WebSocketChannel channel,
      required Stream<dynamic> stream})
      : _user = user,
        _websocketStream = stream,
        _websocketChannel = channel,
        _moveStreamController = StreamController.broadcast() {
    _websocketStream.listen((data) => _handleStreamEvent(data));
  }

  void sendMove(Cell move) {
    _websocketChannel.sink.add(move.toString());
  }

  void endGame() {
    _websocketChannel.sink.add('end');
  }

  @override
  Future<Cell?> getMove(TicTacToe board) async {
    // not closed yet
    if (_websocketChannel.closeCode == null) {
      if (board.moveCount > 0) {
        final move = board.moves.last;
        sendMove(move);
      }

      return await _moveStreamController.stream.first;
    }
    return null;
  }

  void _handleStreamEvent(String data) {
    if (data.length == 2 && int.tryParse(data) != null) {
      _moveStreamController.sink.add(Cell(data));
    }
  }
}
