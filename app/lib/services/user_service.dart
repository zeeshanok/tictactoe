import 'package:flutter/foundation.dart';
import 'package:tictactoe/common/consts.dart';
import 'package:tictactoe/models/user.dart';
import 'package:tictactoe/services/uses_auth_service_mixin.dart';

/// Service that manages everything user related in the app.
class UserService extends ChangeNotifier with UsesAuthServiceMixin {
  User? get currentUser => _currentUser;
  User? _currentUser;

  @override
  void initialise() {
    dio.options.baseUrl = '$serverUrl/users';
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

  /// Fetches the currently signed in user from the server
  /// or null if not signed in.
  Future<User?> fetchCurrentUser() async {
    final res = await dio.get('/me');
    if (res.statusCode == 200) {
      _currentUser = User.fromMap(res.data);
      notifyListeners();
      return _currentUser;
    }
    return null;
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
