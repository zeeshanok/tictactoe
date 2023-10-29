import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:tictactoe/pages/home/stats/stats_header.dart';
import 'package:tictactoe/widgets/loading.dart';
import 'package:tictactoe/models/game.dart';
import 'package:tictactoe/pages/home/stats/history_item.dart';
import 'package:tictactoe/services/game_service.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameService = context.read<GameService>();

    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: FutureBuilder(
          future: gameService.fetchGamesByCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final games = snapshot.data!;
              return HistoryList(
                games: games,
                starred: gameService.currentUserStarSet,
              );
            } else {
              return const Center(
                child: LoadingWidget(),
              );
            }
          },
        ),
      ),
    );
  }
}

class HistoryList extends StatefulWidget {
  const HistoryList({
    super.key,
    required this.games,
    required this.starred,
  });

  final List<TicTacToeGameModel> games;
  final Set<int> starred;

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  late List<TicTacToeGameModel> games = widget.games;

  Set<HistoryFilters> filters = {};

  Duration getDurationPlayed() {
    return widget.games.map((e) => e.timePlayed).reduce((a, b) => a + b);
  }

  void applyFilters(Set<HistoryFilters> filters) {
    games = widget.games
        .where((game) => filters.every((filter) =>
            filter.evaluate(game, widget.starred.contains(game.id))))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // smooth scrolling
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.games.isNotEmpty)
          StatsHeader(
            showGameCount: games.length,
            totalGameCount: widget.games.length,
            durationPlayed: getDurationPlayed(),
            filters: filters,
            onFiltersChanged: (f) => setState(() {
              filters = f;
              applyFilters(f);
            }),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: games.isEmpty
              ? const EmptyGames()
              : DynMouseScroll(
                  builder: (context, controller, physics) {
                    return ListView.separated(
                      controller: controller,
                      physics: physics,
                      itemBuilder: (context, index) => HistoryItem(
                        game: games[index],
                      ),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 6),
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
