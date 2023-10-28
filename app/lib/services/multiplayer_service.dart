import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:tictactoe/logic/players/player.dart';
import 'package:tictactoe/managers/multiplayer_game.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:tictactoe/common/consts.dart';
import 'package:tictactoe/services/user/user_service.dart';
import 'package:tictactoe/services/user/uses_auth_service_mixin.dart';

class MultiplayerService with UsesAuthServiceMixin {
  late UserService userService;

  @override
  void initialise() {
    dio.options.baseUrl = '${serverUrl()}/multiplayer';
    userService = GetIt.instance<UserService>();
    super.initialise();
  }

  Future<MultiplayerGameManager?> createGame(PlayerType playerType) async {
    final response = await dio.post('/');
    if (response.statusCode == 200) {
      final int code = response.data['gameCode'];
      final message = '$code${playerType.name}${userService.currentUser!.id}';
      final channel = WebSocketChannel.connect(Uri.parse(websocketUrl()));
      channel.sink.add(message);
      return MultiplayerGameManager(
        channel: channel,
        gameCode: code,
      );
    }
    return null;
  }

  Future<MultiplayerGameManager> joinGame(int gameCode) async {
    final channel = WebSocketChannel.connect(Uri.parse(websocketUrl()));
    channel.sink.add("$gameCode${userService.currentUser!.id}");
    return MultiplayerGameManager(gameCode: gameCode, channel: channel);
  }
}
