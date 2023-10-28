import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:tictactoe/widgets/loading.dart';
import 'package:tictactoe/models/game.dart';
import 'package:tictactoe/pages/home/history/history_item.dart';
import 'package:tictactoe/services/game_service.dart';

class GameHistoryPage extends StatelessWidget {
  const GameHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: FutureBuilder(
        future: context.read<GameService>().fetchGamesByCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final games = snapshot.data!;
            if (games.isEmpty) {
              return const EmptyGames();
            } else {
              return HistoryList(games: games);
            }
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

class HistoryList extends StatelessWidget {
  const HistoryList({super.key, required this.games});

  final List<TicTacToeGameModel> games;

  @override
  Widget build(BuildContext context) {
    // smooth scrolling
    return Column(
      children: [
        Text("${games.length} games in total"),
        Expanded(
          child: DynMouseScroll(
            builder: (context, controller, physics) {
              return ListView.separated(
                controller: controller,
                physics: physics,
                itemBuilder: (context, index) =>
                    HistoryItem(game: games[index]),
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemCount: games.length,
              );
            },
          ).animate().fadeIn(),
        ),
      ],
    );
  }
}

class EmptyGames extends StatelessWidget {
  const EmptyGames({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("No games to show"),
    );
  }
}
