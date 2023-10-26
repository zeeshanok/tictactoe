import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tictactoe/common/logic/player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final _joinedPattern = RegExp(r'^youare(\d+)(x|o)$');

class MultiplayerGameManager extends ChangeNotifier {
  final int gameCode;
  final WebSocketChannel channel;

  PlayerType get currentUserSide => _currentUserSide;
  late PlayerType _currentUserSide;

  int? get opponentUserId => _opponentUserId;
  int? _opponentUserId;

  bool get hasGameStarted => _opponentUserId != null;

  Future<bool> get ready => _completer.future;
  final _completer = Completer<bool>();

  late StreamSubscription _sub;

  Stream<dynamic> get stream => _stream;
  late Stream<dynamic> _stream;

  WebSocketSink get sink => channel.sink;

  MultiplayerGameManager({
    required this.gameCode,
    required this.channel,
  }) {
    _stream = channel.stream.asBroadcastStream();
    _sub = _stream.listen((data) => _onStreamEvent(data as String));
  }

  void _onStreamEvent(String data) {
    if (data == 'DNE') {
      _completer.complete(false);
    }
    final joinedMatches = _joinedPattern.firstMatch(data.toLowerCase());
    if (joinedMatches != null) {
      _opponentUserId = int.parse(joinedMatches.group(1)!);
      _currentUserSide = switch (joinedMatches.group(2)) {
        "x" => PlayerType.X,
        "o" => PlayerType.O,
        _ => throw UnimplementedError() // unreachable
      };
      _completer.complete(true);
      notifyListeners();
    } else {
      debugPrint("couldn't match: $data");
    }
  }

  void stopListening() {
    _sub.cancel();
  }
}

class GameDoesNotExistException implements Exception {}
