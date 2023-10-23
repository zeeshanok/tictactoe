import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/services/auth/auth_service.dart';
import 'package:tictactoe/common/utils.dart';
import 'package:tictactoe/pages/create_user/create_user.dart';
import 'package:tictactoe/preferences/preferences.dart';
import 'package:tictactoe/services/game_service.dart';
import 'package:tictactoe/services/user_service.dart';
import 'package:tictactoe/pages/authenticate/authenticate.dart';
import 'package:tictactoe/pages/game/game_select.dart';
import 'package:tictactoe/pages/game/local_multiplayer/local_multiplayer.dart';
import 'package:tictactoe/pages/game/singleplayer/singleplayer.dart';
import 'package:tictactoe/pages/loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = LocalPreferences();
  final auth = getAuthService();
  final user = UserService();
  final game = GameService();

  GetIt.instance.registerSingleton<LocalPreferences>(prefs);
  GetIt.instance.registerSingleton<AuthService>(auth);
  GetIt.instance.registerSingleton<UserService>(user);
  GetIt.instance.registerSingleton<GameService>(game);

  runApp(MultiProvider(
    providers: [
      Provider<LocalPreferences>(create: (context) => prefs),
      ChangeNotifierProvider<AuthService>(create: (context) => auth),
      ChangeNotifierProvider<UserService>(create: (context) => user),
      Provider<GameService>(create: (context) => game),
    ],
    builder: (context, child) => const App(),
  ));

  await prefs.initialise();
  await auth.start();
  user.initialise();
  game.initialise();
}

GoRouter getRouter() {
  return GoRouter(
    refreshListenable: CombineChangeNotifiers([
      GetIt.instance<UserService>(),
      GetIt.instance<AuthService>(),
    ]),
    redirectLimit: 12,
    redirect: (context, state) {
      final auth = GetIt.instance<AuthService>();
      final currentUser = GetIt.instance<UserService>().currentUser;

      debugPrint(state.matchedLocation);

      if (!auth.isInitialised) return '/loading';
      if (!auth.isAuthed) return '/authenticate';
      if (currentUser != null && currentUser.username == null) {
        return '/create-user';
      }
      if ({"/authenticate", "/loading", '/create-user'}
          .contains(state.matchedLocation)) {
        return '/game';
      }
      return null;
    },
    initialLocation: '/game',
    routes: [
      GoRoute(
        path: '/authenticate',
        builder: (context, state) => const Authpage(),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingPage(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameSelectPage(),
        routes: [
          GoRoute(
            path: 'singleplayer',
            builder: (context, state) => const SinglePlayerPage(),
          ),
          GoRoute(
            path: 'local-multiplayer',
            builder: (context, state) => const LocalMultiplayerPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/create-user',
        builder: (context, state) => const CreateUser(),
      )
    ],
  );
}

ThemeData buildTheme(Brightness brightness) {
  final scheme =
      ColorScheme.fromSeed(seedColor: Colors.green, brightness: brightness);
  return ThemeData.from(colorScheme: scheme, useMaterial3: true).copyWith(
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      isDense: true,
      alignLabelWithHint: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: scheme.outline.withOpacity(0.1),
      focusColor: scheme.outline.withOpacity(0.1),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: scheme.error,
        ),
      ),
    ),
    splashFactory: NoSplash.splashFactory,
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: getRouter(),
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
    );
  }
}
