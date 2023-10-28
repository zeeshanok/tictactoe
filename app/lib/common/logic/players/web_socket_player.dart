import 'dart:async';

import 'package:tictactoe/common/logic/players/player.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/models/user.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketPlayer implements Player {
  final User _user;

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

  @override
  String get turnText => "$displayName's turn";

  @override
  String get winText => "$displayName wins";
}
