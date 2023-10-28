import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tictactoe/preferences/preferences.dart';
import 'package:tictactoe/services/auth/auth_service.dart';

mixin UsesAuthServiceMixin {
  late LocalPreferences preferences;
  late AuthService authService;

  bool _wasAuthed = false;

  final dio = Dio(BaseOptions(
    validateStatus: (status) => true,
  ));

  /// Starts the service by listening to changes in the `AuthService`
  /// and updating the current user as it changes its state.
  void initialise() {
    authService = GetIt.instance<AuthService>();
    preferences = GetIt.instance<LocalPreferences>();

    authService.addListener(onAuthChange);
    onAuthChange();
  }

  void onAuthChange() {
    if (authService.isAuthed) {
      dio.options.headers['authorization'] =
          "Bearer ${preferences.sessionToken}";
      if (!_wasAuthed) onIsAuthed();
      _wasAuthed = true;
    } else {
      dio.options.headers.remove('authorization');
      onIsUnauthed();
      _wasAuthed = false;
    }
  }

  void onIsAuthed() {}
  void onIsUnauthed() {}
}
