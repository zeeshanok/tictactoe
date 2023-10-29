import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:tictactoe/common/consts.dart';
import 'package:tictactoe/common/utils.dart';
import 'package:tictactoe/logic/tictactoe.dart';
import 'package:tictactoe/models/game.dart';
import 'package:tictactoe/models/user.dart';
import 'package:tictactoe/services/user/user_service.dart';
import 'package:tictactoe/services/user/uses_auth_service_mixin.dart';

class GameService extends ChangeNotifier with UsesAuthServiceMixin {
  late UserService userService;

  UnmodifiableSetView<int> get currentUserStarSet =>
      UnmodifiableSetView(_currentUserStarSet);
  Set<int> _currentUserStarSet = {};

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

  Future<TicTacToeGameModel> _parseGameMap(Map<String, dynamic> gameMap) async {
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
  }

  Future<List<TicTacToeGameModel>?> fetchGamesByUser(int userId) async {
    final res = await dio.get('/');
    if (res.statusCode == 200) {
      // get games
      final List<Map<String, dynamic>> games =
          (res.data['games'] as List<dynamic>).cast();
      final modelList = <TicTacToeGameModel>[];
      for (final gameMap in games) {
        modelList.add(await _parseGameMap(gameMap));
      }

      // get stars
      await _fetchAndSetCurrentUserStarSet();

      return modelList;
    }
    return null;
  }

  Future<List<TicTacToeGameModel>?> fetchGamesByCurrentUser() async {
    final user = userService.currentUser;
    if (user == null) throw Exception("No current user");
    return await fetchGamesByUser(user.id);
  }

  Future<void> _fetchAndSetCurrentUserStarSet() async {
    final response = await dio.get('/stars');
    if (response.statusCode == 200) {
      _currentUserStarSet =
          (response.data["gameIds"] as List<dynamic>).cast<int>().toSet();
    }
  }

  Future<void> toggleStar(int gameId, bool shouldStar) async {
    final sub = shouldStar ? 'star' : 'unstar';
    final response = await dio.post('/$gameId/$sub');
    if (response.statusCode == 200) {
      if (shouldStar) {
        _currentUserStarSet.add(gameId);
      } else {
        _currentUserStarSet.remove(gameId);
      }
      notifyListeners();
    } else if (response.statusCode == 400) {
      globalNotify(response.data ?? "Error");
    }
  }
}
