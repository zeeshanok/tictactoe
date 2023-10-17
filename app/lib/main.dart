import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tictactoe/pages/game_select/game_select.dart';
import 'package:tictactoe/pages/local_multiplayer/local_multiplayer.dart';

void main() {
  runApp(const App());
}

final _router = GoRouter(routes: [
  GoRoute(
    path: '/login',
    builder: (context, state) => const Placeholder(),
  ),
  GoRoute(
      path: '/',
      builder: (context, state) => const GameSelectPage(),
      routes: [
        GoRoute(
          path: 'local-multiplayer',
          builder: (context, state) => const LocalMultiplayerPage(),
        ),
      ])
]);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ).copyWith(splashFactory: NoSplash.splashFactory),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ).copyWith(splashFactory: NoSplash.splashFactory),
    );
  }
}
