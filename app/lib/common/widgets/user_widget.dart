import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/common/widgets/animated_text.dart';
import 'package:tictactoe/common/widgets/circular_network_image.dart';
import 'package:tictactoe/models/user.dart';
import 'package:tictactoe/services/user_service.dart';

enum UserViewMode { imageOnly, imageAndUsername }

class UserWidget extends StatelessWidget {
  const UserWidget({
    super.key,
    UserViewMode? viewMode,
    this.onPressed,
  }) : viewMode = viewMode ?? UserViewMode.imageAndUsername;

  final UserViewMode viewMode;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserService>().currentUser;
    return buildUser(context, user);
  }

  Widget buildUser(BuildContext context, User? user) {
    final icon = CircularNetworkImage(
      imageUrl: user?.profileUrl,
      radius: 15,
    );
    return viewMode == UserViewMode.imageAndUsername
        ? TextButton.icon(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
            ),
            icon: icon,
            label: AnimatedText(
              user?.username ?? "",
              style: const TextStyle(fontSize: 14),
            ),
          )
        : IconButton(onPressed: onPressed, icon: icon);
  }
}
