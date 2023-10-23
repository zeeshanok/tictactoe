import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/services/auth/auth_service.dart';

class Authpage extends StatelessWidget {
  const Authpage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    return Scaffold(
      body: Center(
          child: FilledButton(
        onPressed: () async => authService.signIn(),
        child: const Text("Sign in"),
      )),
    );
  }
}
