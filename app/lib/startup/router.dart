import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:tictactoe/common/transitions.dart';
import 'package:tictactoe/common/utils.dart';
import 'package:tictactoe/pages/authenticate/authenticate.dart';
import 'package:tictactoe/pages/create_user/create_user.dart';
import 'package:tictactoe/pages/home/game_scaffold_with_nav.dart';
import 'package:tictactoe/pages/home/game_select.dart';
import 'package:tictactoe/pages/home/history/game_history.dart';
import 'package:tictactoe/pages/home/local_multiplayer/local_multiplayer.dart';
import 'package:tictactoe/pages/home/online/online.dart';
import 'package:tictactoe/pages/home/settings/settings.dart';
import 'package:tictactoe/pages/home/singleplayer/singleplayer.dart';
import 'package:tictactoe/pages/loading.dart';
import 'package:tictactoe/services/auth/auth_service.dart';
import 'package:tictactoe/services/user/user_service.dart';

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
                pageBuilder: (context, state) => slideLeftTransition(
                  state,
                  const SinglePlayerPage(),
                ),
              ),
              GoRoute(
                path: 'play/local-multiplayer',
                parentNavigatorKey: rootNavKey,
                pageBuilder: (context, state) => slideLeftTransition(
                  state,
                  const LocalMultiplayerPage(),
                ),
              ),
              GoRoute(
                path: 'play/online',
                parentNavigatorKey: rootNavKey,
                pageBuilder: (context, state) => slideLeftTransition(
                  state,
                  const OnlinePage(),
                ),
              ),
              GoRoute(
                path: 'settings',
                parentNavigatorKey: rootNavKey,
                pageBuilder: (context, state) =>
                    slideUpTransition(state, const SettingsPage()),
              )
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
      ),
    ],
  );
}
