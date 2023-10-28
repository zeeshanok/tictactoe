import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/common/widgets/responsive_builder.dart';
import 'package:tictactoe/common/utils.dart';
import 'package:tictactoe/common/widgets/circular_network_image.dart';
import 'package:tictactoe/pages/create_user.dart';
import 'package:tictactoe/services/auth/auth_service.dart';
import 'package:tictactoe/services/user/user_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserService>().currentUser;
    final auth = context.read<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: OutlinedButton.icon(
              onPressed: () => auth.signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text("Sign out"),
            ),
          )
        ],
      ),
      body: Center(
          child: FractionallySizedBox(
        widthFactor: responsiveValue(
          context,
          mobileValue: 0.9,
          desktopValue: 0.4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 26),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularNetworkImage(
                  imageUrl: user?.profileUrl,
                  radius: 38,
                ),
                const SizedBox(width: 16),
                Text(
                  'Edit profile',
                  style: Theme.of(context).textTheme.displaySmall,
                )
              ],
            ),
            const SizedBox(height: 26),
            CreateUserForm(
              username: user?.username,
              bio: user?.bio,
              onSuccess: () => globalNotify("Updated profile"),
            ),
          ],
        ),
      )),
    );
  }
}
