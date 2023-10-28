import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/common/utils.dart';
import 'package:tictactoe/startup/providers.dart';
import 'package:tictactoe/startup/router.dart';
import 'package:tictactoe/startup/themes.dart';

void main() async {
  await dotenv.load(fileName: '.env');

  final (providers, postRunTasks) = setupProviders();

  runApp(MultiProvider(
    providers: providers,
    builder: (context, child) => const App(),
  ));

  postRunTasks();
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: getRouter(),
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: snackbarKey,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
    );
  }
}
