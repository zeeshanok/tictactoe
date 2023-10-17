import 'package:flutter/foundation.dart';
import 'package:tictactoe/common/logic/player.dart';

typedef CellList = List<PlayerType?>;

class TicTacToeBoard extends ChangeNotifier {
  final CellList cells;

  final List<Cell> moves;

  final Player playerX;

  final Player playerO;

  /// Result of the game. If null the game is still ongoing.
  GameResult? result;

  int get moveCount => moves.length;

  TicTacToeBoard({
    required this.playerX,
    required this.playerO,
  })  : cells = List.filled(9, null),
        moves = [];

  factory TicTacToeBoard.fromNotation(String notation,
      {required Player playerX, required Player playerO}) {
    final board = TicTacToeBoard(playerX: playerX, playerO: playerO);
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

  PlayerType get currentPlayer =>
      moveCount % 2 == 0 ? PlayerType.X : PlayerType.O;

  void _play(Cell cell) {
    if (result != null) return;
    final index = cell.index;

    if (cells[index] != null) {
      throw FilledCellException(cell.toString());
    }

    cells[index] = currentPlayer;
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

  void startGame() async {
    while (getResult() == null) {
      _play(await (currentPlayer == PlayerType.X ? playerX : playerO)
          .getMove(this));
    }
  }
}

GameResult? getResultFromCells(CellList cells) {
  final moveCount = cells.where((c) => c != null).length;
  if (moveCount < 5) return null;

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
  String get player => playerNumConvert(playerType);
}

class DrawResult implements GameResult {}
