import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wormhole_chess/model/direction.dart';
import 'package:wormhole_chess/model/position.dart';

import '../model/chess_piece.dart';
import '../model/game_board.dart';

class GameService {
  final _games = FirebaseFirestore.instance.collection('games');

  FirebaseFirestore get _db => _games.firestore;

  String get _userId =>
      FirebaseAuth.instance.currentUser!.uid; // TODO: Handle error

  Future<DocumentReference<Map<String, dynamic>>> newGame(Mode mode) async {
    final board = GameBoard.fromMode(mode);
    // TODO: handle errors
    return await _games.add({
      'players': [
        _userId,
        '__local',
        if (mode != Mode.twoPlayer) ...['__local', '__local']
      ],
      'status': 'in_progress',
      'turn': board.player.name,
      'mode': mode.name,
      'createdAt': FieldValue.serverTimestamp(),
      for (final p in board.startPos.keys) p.name: board.startPos[p].toString(),
    });
  }

  Stream<GameBoard?> streamGame(String? gameId) {
    if (gameId == null) return const Stream.empty();
    final movesStream = _games.doc(gameId).collection('moves').snapshots();
    return _games.doc(gameId).snapshots().asyncMap((snapshot) async {
      final game = snapshot.data();
      if (!snapshot.exists || game == null) return null;
      final query = await movesStream.first;
      final moves = query.docs.map((doc) {
        final move = doc.data();
        final promotion = move['promotion'];
        return Move(
          player: Player.values.byName(move['player']),
          from: Position.fromString(move['from']),
          to: Position.fromString(move['to']),
          dir: Direction.values.byName(move['direction']),
          turn: move['turn'],
          promotion: promotion == null
              ? null
              : ChessPieceType.values.byName(promotion),
        );
      }).toList();
      print(moves);

      return GameBoard.build(
        mode: Mode.values.byName(game['mode']),
        player: Player.values.byName(game['turn']),
        startPos: {
          for (final p in Player.values)
            if (game[p.name] != null) p: Position.fromString(game[p.name]),
        },
        moves: moves,
      );
    });
  }

  void updateStartPos(String? gameId, GameBoard board) async {
    print((gameId, board.player, board.startPos));
    _games.doc(gameId).update({
      'turn': board.player.name,
      for (final p in board.startPos.keys) p.name: board.startPos[p].toString(),
    });
  }

  void movePiece(String? gameId, Move move, Player next) {
    _games.doc(gameId).update({'turn': next.name});
    _games.doc(gameId).collection('moves').add({
      'player': move.player.name,
      'turn': move.turn,
      'from': move.from.toString(),
      'to': move.to.toString(),
      'direction': move.dir.name,
      'createdAt': FieldValue.serverTimestamp(),
      if (move.promotion != null) 'promotion': move.promotion?.name,
    });
  }
}
