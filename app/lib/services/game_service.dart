import 'package:flutter/foundation.dart';
import 'package:tictactoe/common/consts.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/services/uses_auth_service_mixin.dart';

class GameService with UsesAuthServiceMixin {
  @override
  void initialise() {
    dio.options.baseUrl = '$serverUrl/games';
    super.initialise();
  }

  Future<void> addGame(TicTacToe game) async {
    debugPrint("adding game");
    await dio.post('/', data: game.toMap());
  }
}
