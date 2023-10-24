import 'package:get_it/get_it.dart';
import 'package:tictactoe/common/consts.dart';
import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/models/game.dart';
import 'package:tictactoe/models/user.dart';
import 'package:tictactoe/services/user_service.dart';
import 'package:tictactoe/services/uses_auth_service_mixin.dart';

class GameService with UsesAuthServiceMixin {
  late UserService userService;

  @override
  void initialise() {
    dio.options.baseUrl = '${serverUrl()}/games';
    userService = GetIt.instance<UserService>();
    super.initialise();
  }

  Future<void> addGame(TicTacToe game) async {
    await dio.post('/', data: game.toMap());
  }

  Future<User?> _getUserIfId(String playerText) async {
    final id = int.tryParse(playerText);
    if (id == null) return null;

    return await userService.fetchUserById(id);
  }

  Future<List<TicTacToeGameModel>?> fetchGamesByUser(int userId) async {
    final res = await dio.get('/');
    if (res.statusCode == 200) {
      final List<Map<String, dynamic>> games =
          (res.data['games'] as List<dynamic>).cast();
      final futures = games.map((gameMap) async {
        final pX = gameMap['playerX'];
        final pO = gameMap['playerO'];
        var playerX = await _getUserIfId(pX);
        var playerO = await _getUserIfId(pO);
        return TicTacToeGameModel(
          id: gameMap['id'],
          playerXName: playerX?.username ?? pX,
          playerOName: playerO?.username ?? pO,
          playerX: playerX,
          playerO: playerO,
          moves: Cell.cellListfromNotation(gameMap['moves']),
          type: gameTypeFromName(gameMap['type']),
          timePlayed: Duration(seconds: gameMap['timePlayed']),
          createdAt: DateTime.parse(gameMap['createdAt']),
        );
      }).toList();
      final modeList = await Future.wait(futures);
      return modeList;
    }
    return null;
  }

  Future<List<TicTacToeGameModel>?> fetchGamesByCurrentUser() async {
    final user = userService.currentUser;
    if (user == null) throw Exception("No current user");
    return await fetchGamesByUser(user.id);
  }
}
