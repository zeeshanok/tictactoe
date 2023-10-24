import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/common/widgets/animated_text.dart';
import 'package:tictactoe/common/widgets/circular_network_image.dart';
import 'package:tictactoe/services/user_service.dart';

class HomeScaffoldWithNav extends StatelessWidget {
  const HomeScaffoldWithNav({
    super.key,
    required this.child,
    required this.state,
  });

  final Widget child;
  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: 200,
              child: NavRail(selectedPath: state.fullPath!),
            ),
            const VerticalDivider(width: 16),
            Expanded(
              child: Container(
                child: child,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NavRail extends StatelessWidget {
  const NavRail({super.key, required this.selectedPath});

  final String selectedPath;

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserService>().currentUser;

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NavItem(
          name: "Play",
          path: '/',
          icon: const Icon(Icons.gamepad_rounded),
          selectedPath: selectedPath,
        ),
        NavItem(
          name: "History",
          path: '/history',
          icon: const Icon(Icons.history),
          selectedPath: selectedPath,
        ),
        const Spacer(),
        NavItem(
          name: user?.username ?? "",
          path: '/settings',
          icon: CircularNetworkImage(
            imageUrl: user?.profileUrl,
            radius: 18,
          ),
          selectedPath: selectedPath,
        ).animate().shimmer()
      ],
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.name,
    required this.path,
    required this.icon,
    required this.selectedPath,
  });

  final String name, path, selectedPath;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextButton.icon(
        onPressed: () => context.go(path),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(20),
          minimumSize: const Size(60, 0),
          alignment: Alignment.centerLeft,
          backgroundColor: path == selectedPath
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.background,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
        ),
        icon: icon,
        label: AnimatedText(
          name,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
