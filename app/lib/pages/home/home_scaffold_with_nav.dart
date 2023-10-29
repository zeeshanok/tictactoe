import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/widgets/labeled_icon_button.dart';
import 'package:tictactoe/widgets/responsive_builder.dart';
import 'package:tictactoe/widgets/circular_network_image.dart';
import 'package:tictactoe/widgets/user_widget.dart';
import 'package:tictactoe/services/user/user_service.dart';

class HomeScaffoldWithNav extends StatelessWidget {
  HomeScaffoldWithNav({
    super.key,
    required this.state,
    required this.child,
  });

  final Widget child;
  final GoRouterState state;

  Widget buildDesktopLayout(BuildContext context) => Scaffold(
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

  Widget buildMobileLayout(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('TicTacToe'),
          centerTitle: true,
          backgroundColor:
              Theme.of(context).colorScheme.background.withOpacity(0.9),
          surfaceTintColor: Colors.transparent,
          actions: [
            UserWidget(
              viewMode: UserViewMode.imageOnly,
              onPressed: () => context.push('/settings'),
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.gamepad_rounded),
              label: 'Play',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Stats',
            )
          ],
          currentIndex: _getIndex(state.fullPath!),
          onTap: (index) => _onTap(context, index),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobileBuilder: buildMobileLayout,
      desktopBuilder: buildDesktopLayout,
    );
  }

  final Map<String, int> indexMap = {'/': 0, '/stats': 1};

  void _onTap(BuildContext context, int index) =>
      context.go({for (final e in indexMap.entries) e.value: e.key}[index]!);

  // I'm aware StatefulShellRoute exists but I am doing this so that
  // the page is rebuilt every time it is visited
  int _getIndex(String path) => indexMap[path] ?? 0;
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
          name: "Stats",
          path: '/stats',
          icon: const Icon(Icons.bar_chart_rounded),
          selectedPath: selectedPath,
        ),
        const Spacer(),
        NavItem(
          name: user?.username ?? "",
          path: '/settings',
          push: true,
          icon: CircularNetworkImage(
            imageUrl: user?.profileUrl,
            radius: 18,
          ),
          selectedPath: selectedPath,
        ),
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
    this.push = false,
  });

  final String name, path, selectedPath;
  final Widget icon;
  final bool push;

  @override
  Widget build(BuildContext context) {
    return LabeledIconButton(
      icon: icon,
      text: name,
      onPressed: () => (push ? context.push : context.go).call(path),
      backgroundColor: path == selectedPath
          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
          : Theme.of(context).colorScheme.background,
    );
  }
}
