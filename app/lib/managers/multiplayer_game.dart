import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tictactoe/common/logic/player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MultiplayerGameManager extends ChangeNotifier {
  final int gameCode;
  final WebSocketChannel channel;
  final PlayerType currentUserSide;

  int? get opponentUserId => _opponentUserId;
  int? _opponentUserId;

  bool get hasGameStarted => _opponentUserId != null;

  late StreamSubscription _sub;

  Stream<dynamic> get stream => _stream;
  late Stream<dynamic> _stream;

  WebSocketSink get sink => channel.sink;

  MultiplayerGameManager(
      {required this.currentUserSide,
      required this.gameCode,
      required this.channel}) {
    _stream = channel.stream.asBroadcastStream();
    _sub = _stream.listen((data) => _onStreamEvent(data as String));
  }

  void _onStreamEvent(String data) {
    if (data.startsWith('joined')) {
      _opponentUserId = int.parse(data.replaceFirst('joined', ''));
      notifyListeners();
    }
  }

  void endGame() {
    _sub.cancel();
  }
}
