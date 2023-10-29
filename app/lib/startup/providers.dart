import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tictactoe/preferences/preferences.dart';
import 'package:tictactoe/services/auth/auth_service.dart';
import 'package:tictactoe/services/game_service.dart';
import 'package:tictactoe/services/multiplayer_service.dart';
import 'package:tictactoe/services/server_status_service.dart';
import 'package:tictactoe/services/user/user_service.dart';

(List<SingleChildWidget>, void Function()) setupProviders() {
  final prefs = LocalPreferences();
  final auth = getAuthService();
  final user = UserService();
  final game = GameService();
  final multiplayer = MultiplayerService();
  final serverStatus = ServerStatusService();

  GetIt.instance.registerSingleton<LocalPreferences>(prefs);
  GetIt.instance.registerSingleton<AuthService>(auth);
  GetIt.instance.registerSingleton<UserService>(user);
  GetIt.instance.registerSingleton<GameService>(game);
  GetIt.instance.registerSingleton<MultiplayerService>(multiplayer);
  GetIt.instance.registerSingleton<ServerStatusService>(serverStatus);
  return (
    [
      Provider<LocalPreferences>(create: (context) => prefs),
      ChangeNotifierProvider<ServerStatusService>(
          create: (context) => serverStatus),
      ChangeNotifierProvider<AuthService>(create: (context) => auth),
      ChangeNotifierProvider<UserService>(create: (context) => user),
      ChangeNotifierProvider<GameService>(create: (context) => game),
      Provider<MultiplayerService>(create: (context) => multiplayer),
    ],
    () async {
      serverStatus.initialise();
      await prefs.initialise();
      await auth.initialise();
      user.initialise();
      game.initialise();
      multiplayer.initialise();
    }
  );
}
