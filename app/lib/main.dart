import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/common/transitions.dart';
import 'package:tictactoe/pages/home/history/game_history.dart';
import 'package:tictactoe/pages/home/game_scaffold_with_nav.dart';
import 'package:tictactoe/services/auth/auth_service.dart';
import 'package:tictactoe/common/utils.dart';
import 'package:tictactoe/pages/create_user/create_user.dart';
import 'package:tictactoe/preferences/preferences.dart';
import 'package:tictactoe/services/game_service.dart';
import 'package:tictactoe/services/user_service.dart';
import 'package:tictactoe/pages/authenticate/authenticate.dart';
import 'package:tictactoe/pages/home/game_select.dart';
import 'package:tictactoe/pages/home/local_multiplayer/local_multiplayer.dart';
import 'package:tictactoe/pages/home/singleplayer/singleplayer.dart';
import 'package:tictactoe/pages/loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

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
  final rootNavKey = GlobalKey<NavigatorState>();
  final gamesNavKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavKey,
    refreshListenable: CombineChangeNotifiers([
      GetIt.instance<UserService>(),
      GetIt.instance<AuthService>(),
    ]),
    redirectLimit: 12,
    redirect: (context, state) {
      final auth = GetIt.instance<AuthService>();
      final currentUser = GetIt.instance<UserService>().currentUser;

      if (!auth.isInitialised) return '/loading';
      if (!auth.isAuthed) return '/authenticate';
      if (currentUser != null && currentUser.username == null) {
        return '/create-user';
      }
      if ({"/authenticate", "/loading", '/create-user'}
          .contains(state.matchedLocation)) {
        return '/';
      }
      return null;
    },
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/authenticate',
        builder: (context, state) => const Authpage(),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingPage(),
      ),
      ShellRoute(
        navigatorKey: gamesNavKey,
        pageBuilder: (context, state, child) => slideLeftTransition(
          state,
          HomeScaffoldWithNav(state: state, child: child),
        ),
        routes: [
          GoRoute(
            path: '/',
            parentNavigatorKey: gamesNavKey,
            pageBuilder: (context, state) =>
                slideUpTransition(state, const GameSelectPage()),
            routes: [
              GoRoute(
                path: 'play/singleplayer',
                parentNavigatorKey: rootNavKey,
                pageBuilder: (context, state) =>
                    slideLeftTransition(state, const SinglePlayerPage()),
              ),
              GoRoute(
                path: 'play/local-multiplayer',
                parentNavigatorKey: rootNavKey,
                pageBuilder: (context, state) => slideLeftTransition(
                  state,
                  const LocalMultiplayerPage(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/history',
            parentNavigatorKey: gamesNavKey,
            pageBuilder: (context, state) =>
                slideUpTransition(state, const GameHistoryPage()),
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
      ColorScheme.fromSeed(seedColor: Colors.pink, brightness: brightness);
  return ThemeData.from(colorScheme: scheme, useMaterial3: true).copyWith(
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
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
      enabledBorder: OutlineInputBorder(
        borderRadius: defaultBorderRadius,
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: defaultBorderRadius,
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: defaultBorderRadius,
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: defaultBorderRadius,
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
