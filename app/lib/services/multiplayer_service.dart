import 'package:get_it/get_it.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:tictactoe/common/consts.dart';
import 'package:tictactoe/common/logic/player.dart';
import 'package:tictactoe/services/user_service.dart';
import 'package:tictactoe/services/uses_auth_service_mixin.dart';

class MultiplayerService with UsesAuthServiceMixin {
  late UserService userService;

  WebSocketChannel? _webSocketChannel;
  WebSocketChannel? get channel => _webSocketChannel;

  @override
  void initialise() {
    dio.options.baseUrl = '${serverUrl()}/multiplayer';
    userService = GetIt.instance<UserService>();
    super.initialise();
  }

  Future<int?> createGame(PlayerType playerType) async {
    final response = await dio.post('/');
    if (response.statusCode == 200) {
      endGame();

      final int code = response.data['gameCode'];
      final message =
          '$code${playerType.name.toLowerCase()}${userService.currentUser!.id}';
      _webSocketChannel = WebSocketChannel.connect(Uri.parse(websocketUrl()));
      _webSocketChannel!.sink.add(message);
      return code;
    }
    return null;
  }

  void endGame() {
    _webSocketChannel?.sink.close();
  }
}
