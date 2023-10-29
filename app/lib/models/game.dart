import 'package:tictactoe/logic/tictactoe.dart';
import 'package:tictactoe/models/user.dart';

/// Model used to represent a previous tictactoe game
class TicTacToeGameModel {
  final int id;
  final MoveList moves;
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
    required this.timePlayed,
    this.playerO,
    this.playerX,
  });
}
