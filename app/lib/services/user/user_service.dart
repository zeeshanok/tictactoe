import 'package:flutter/foundation.dart';
import 'package:tictactoe/common/consts.dart';
import 'package:tictactoe/models/user.dart';
import 'package:tictactoe/services/user/uses_auth_service_mixin.dart';

/// Service that manages everything user related in the app.
class UserService extends ChangeNotifier with UsesAuthServiceMixin {
  User? get currentUser => _currentUser;
  User? _currentUser;

  Map<int, User> userMap = {};

  @override
  void initialise() {
    dio.options.baseUrl = '${serverUrl()}/users';
    super.initialise();
  }

  @override
  void onAuthChange() {
    super.onAuthChange();
    notifyListeners();
  }

  @override
  void onIsAuthed() {
    fetchCurrentUser();
  }

  Future<User?> _fetchUserFromServerPath(String path) async {
    final res = await dio.get(path);
    if (res.statusCode == 200) {
      return User.fromMap(res.data);
    }
    return null;
  }

  /// Fetches the currently signed in user from the server
  /// or null if not signed in.
  Future<User?> fetchCurrentUser() async {
    _currentUser = await _fetchUserFromServerPath('/me');
    notifyListeners();
    return _currentUser;
  }

  Future<User?> fetchUserById(int id) async {
    var user = userMap[id];
    if (user != null) return user;
    user = await _fetchUserFromServerPath('/$id');
    if (user != null) userMap[user.id] = user;
    return user;
  }

  Future<bool> doesUsernameExist(String username) async {
    final res = await dio.get('/exists', queryParameters: {
      'username': username,
    });

    return res.data['exists'];
  }

  Future<String?> updateCurrentUserInfo({String? username, String? bio}) async {
    final res = await dio.patch('/me', data: {
      if (username != null) "username": username,
      if (bio != null) "bio": bio,
    });

    if (res.statusCode != 200) {
      return res.statusMessage;
    }

    _currentUser = User.fromMap(res.data);
    notifyListeners();
    return null;
  }
}
