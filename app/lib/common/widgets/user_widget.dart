import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/common/widgets/circular_network_image.dart';
import 'package:tictactoe/models/user.dart';
import 'package:tictactoe/services/user_service.dart';

class UserWidget extends StatelessWidget {
  const UserWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    return userService.currentUser != null
        ? buildUser(context, userService.currentUser!)
        : const Text("undefined user");
  }

  Widget buildUser(BuildContext context, User user) {
    return user.username == null || user.profileUrl == null
        ? Container()
        : Container(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularNetworkImage(imageUrl: user.profileUrl!),
                const SizedBox(width: 8),
                Text(user.username!),
              ],
            ),
          );
  }
}
