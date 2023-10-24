import 'package:tictactoe/common/logic/tictactoe.dart';
import 'package:tictactoe/models/user.dart';

class TicTacToeGameModel {
  final int id;
  final List<Cell> moves;
  final GameType type;
  final User? playerX, playerO;

  /// Used for computer and local players
  final String playerXName, playerOName;
  final Duration timePlayed;
  final DateTime createdAt;

  TicTacToeGameModel({
    required this.id,
    required this.createdAt,
    required this.playerXName,
    required this.playerOName,
    required this.moves,
    required this.type,
    this.playerX,
    this.playerO,
    required this.timePlayed,
  });
}
