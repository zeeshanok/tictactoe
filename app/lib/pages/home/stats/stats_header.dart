import 'package:flutter/material.dart';
import 'package:tictactoe/common/utils.dart';
import 'package:tictactoe/models/game.dart';
import 'package:tictactoe/widgets/responsive_builder.dart';

enum HistoryFilters { starred }

extension HistoryFiltersUtils on HistoryFilters {
  bool evaluate(TicTacToeGameModel game, bool starred) =>
      switch (this) { HistoryFilters.starred => starred };
}

class StatsHeader extends StatelessWidget {
  const StatsHeader({
    super.key,
    required this.durationPlayed,
    required this.filters,
    required this.onFiltersChanged,
    required this.showGameCount,
    required this.totalGameCount,
  });

  final Duration durationPlayed;
  final Set<HistoryFilters> filters;
  final void Function(Set<HistoryFilters> filters) onFiltersChanged;

  final int showGameCount, totalGameCount;

  @override
  Widget build(BuildContext context) {
    final children = [
      Text("Time played: ${formatDuration(durationPlayed)}"),
      Text("Showing $showGameCount/$totalGameCount games"),
      Align(
        alignment: Alignment.bottomRight,
        child: SegmentedButton(
          segments: const [
            ButtonSegment(
              value: HistoryFilters.starred,
              icon: Icon(Icons.star_rounded),
              label: Text("Starred"),
            )
          ],
          selected: filters,
          emptySelectionAllowed: true,
          onSelectionChanged: onFiltersChanged,
        ),
      )
    ];
    return ResponsiveBuilder(
      mobileBuilder: (context) => Column(
        children: children,
      ),
      desktopBuilder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}
