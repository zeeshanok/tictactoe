import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:tictactoe/common/widgets/loading.dart';
import 'package:tictactoe/pages/home/history/history_item.dart';
import 'package:tictactoe/services/game_service.dart';

class GameHistoryPage extends StatelessWidget {
  const GameHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: show something when the user has no games
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: FutureBuilder(
        future: context.read<GameService>().fetchGamesByCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final games = snapshot.data!;
            // smooth scrolling
            return DynMouseScroll(
              builder: (context, controller, physics) => ListView.separated(
                controller: controller,
                physics: physics,
                itemBuilder: (context, index) =>
                    HistoryItem(game: games[index]),
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemCount: games.length,
              ),
            ).animate().slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 200.ms,
                  curve: Curves.easeOutCubic,
                );
          } else {
            return const Center(
              child: LoadingWidget(),
            );
          }
        },
      ),
    );
  }
}
