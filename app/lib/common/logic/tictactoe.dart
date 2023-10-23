import 'package:flutter/foundation.dart';
import 'package:tictactoe/common/logic/player.dart';

typedef CellList = List<PlayerType?>;

int getMoveCount(CellList cells) => cells.where((c) => c != null).length;

PlayerType getCurrentPlayerType(cells) =>
    getMoveCount(cells) % 2 == 0 ? PlayerType.X : PlayerType.O;

enum GameType {
  computer,
  localMultiplayer,
  online,
}

extension GameTypeString on GameType {
  String get name => switch (this) {
        GameType.computer => 'computer',
        GameType.localMultiplayer => 'local-multiplayer',
        GameType.online => 'online',
      };

  static GameType fromName(String name) => switch (name) {
        'computer' => GameType.computer,
        'local-multiplayer' => GameType.localMultiplayer,
        'online' => GameType.online,
        _ => throw Exception("Unknown gametype")
      };
}

class TicTacToe extends ChangeNotifier {
  final CellList cells;

  final List<Cell> moves;

  final Player playerX, playerO;

  final void Function(TicTacToe game)? onGameEnd;

  final Stopwatch stopwatch;

  /// Result of the game. If null the game is still ongoing.
  GameResult? result;

  int get moveCount => moves.length;

  PlayerType get currentPlayerType => getCurrentPlayerType(cells);
  Player get currentPlayer =>
      currentPlayerType == PlayerType.X ? playerX : playerO;

  final GameType _gameType;

  TicTacToe({
    this.onGameEnd,
    required this.playerX,
    required this.playerO,
    required GameType gameType,
  })  : cells = List.filled(9, null),
        moves = [],
        stopwatch = Stopwatch(),
        _gameType = gameType;

  factory TicTacToe.fromNotation(String notation,
      {required Player playerX,
      required Player playerO,
      required GameType gameType}) {
    final board =
        TicTacToe(playerX: playerX, playerO: playerO, gameType: gameType);
    final cells = Cell.cellListfromNotation(notation);
    for (final cell in cells) {
      try {
        board._play(cell);
      } on FilledCellException {
        break;
      }
    }
    return board;
  }

  void _play(Cell cell) {
    if (result != null) return;
    final index = cell.index;

    if (cells[index] != null) {
      throw FilledCellException(cell.toString());
    }

    cells[index] = currentPlayerType;
    moves.add(cell);
    notifyListeners();
  }

  /// Checks if there is a win or if the game is being played
  /// or if the game is a draw.
  /// This function must be called after every play to check for the game's
  /// state.
  GameResult? getResult() {
    result = getResultFromCells(cells);
    return result;
  }

  Future<void> startGame() async {
    stopwatch.start();
    bool _prematureEnd = false;
    while (getResult() == null) {
      final move = await (currentPlayerType == PlayerType.X ? playerX : playerO)
          .getMove(this);
      // the wait was cancelled (usually because the user ended the game)
      if (move == null) {
        _prematureEnd = true;
        break;
      }
      _play(move);
      notifyListeners();
    }
    stopwatch.stop();
    if (!_prematureEnd) onGameEnd?.call(this);
  }

  Map<String, dynamic> toMap() => {
        "moves": Cell.notationFromCellList(moves),
        "type": _gameType.name,
        "playerX": playerX.internalName,
        "playerO": playerO.internalName,
        "timePlayed": stopwatch.elapsed.inSeconds,
      };
}

/// Returns null if the game is still ongoing otherwise returns the result
GameResult? getResultFromCells(CellList cells) {
  final moveCount = getMoveCount(cells);
  if (moveCount < 3) return null;

  // vertical ( | )
  for (final i in [0, 1, 2]) {
    final player = {
      for (final j in [0, 3, 6]) cells[i + j]
    }.singleOrNull;
    if (player != null) {
      return WinResult(playerType: player);
    }
  }
  // horizontal ( --- )
  for (final i in [0, 3, 6]) {
    final player = cells.getRange(i, i + 3).toSet().singleOrNull;
    if (player != null) {
      return WinResult(playerType: player);
    }
  }
  // diagonal ( \ )
  {
    final player = {
      for (int i = 0; i < 3; i++) cells[Cell.fromCoord(i, i).index]
    }.singleOrNull;
    if (player != null) {
      return WinResult(playerType: player);
    }
  }
  // anti diagonal ( / )
  {
    final player = {
      for (int i = 0; i < 3; i++) cells[Cell.fromCoord(i, 2 - i).index]
    }.singleOrNull;
    if (player != null) {
      return WinResult(playerType: player);
    }
  }

  // No one has won and the board is filled
  if (moveCount == 9) return DrawResult();

  // Continue playing
  return null;
}

class FilledCellException implements Exception {
  final String coord;

  FilledCellException(this.coord);
  @override
  String toString() {
    return "$coord cannot be played on again";
  }
}

class Cell {
  final int x, y;

  Cell(String cell)
      : assert(cell.length == 2),
        x = int.parse(cell[0]),
        y = int.parse(cell[1]);

  Cell.fromCoord(this.x, this.y);
  Cell.fromIndex(int index)
      : x = index % 3,
        y = index ~/ 3;

  int get index => y * 3 + x;

  static List<Cell> cellListfromNotation(String notation) {
    if (notation.length % 2 != 0) {
      throw Exception(
        "text must have an even length to hold valid cell coordinates",
      );
    }
    return [
      for (int i = 1; i < notation.length; i += 2)
        Cell(notation.substring(i - 1, i + 1))
    ];
  }

  static String notationFromCellList(List<Cell> cells) {
    return cells.join("");
  }

  // static String

  @override
  String toString() => "$x$y";
}

abstract class GameResult {}

class WinResult implements GameResult {
  final PlayerType playerType;

  WinResult({required this.playerType});
  String get player => playerType.name;
}

class DrawResult implements GameResult {}
