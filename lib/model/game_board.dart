import 'dart:math';

import 'package:wormhole_chess/model/position.dart';

import 'chess_piece.dart';
import 'direction.dart';

class GameBoard {
  final Map<Position, ChessPiece> _board;
  final int turn;

  GameBoard({
    this.turn = 1,
    required Map<Position, ChessPiece> board,
  }) : _board = board;

  Player get player => Player.values[(turn + 1) % 2];

  ChessPiece? operator [](Position? pos) => _board[pos];

  Position? getKing(Player player) => _board.keys.where((pos) =>
  _board[pos]?.type == ChessPieceType.king &&
      _board[pos]?.player == player).firstOrNull;

  bool isKingInCheck(Player player) {
    final kingPosition = getKing(player);
    return kingPosition == null || _board.entries.any((e) {
      final piece = e.value;
      if (piece.player == player) return false;
      final moves = getRawValidMoves(e.key, piece);
      return moves.keys.any((pos) => pos == kingPosition);
    });
  }

  List<(Position, Direction)> getPawnAttacks(Position pos, ChessPiece pawn) {
    final dir = pawn.direction;
    final diagonals = pos.diagonals;

    var left = dir.left();
    if (!diagonals.contains(left)) left = dir;
    var (lPos, lDir) = pos.nextDiagonal(left).first;
    if (lPos.cardinals.contains(lDir.right())) lDir = lDir.right();

    var right = dir.right();
    if (!diagonals.contains(right)) right = dir;
    var (rPos, rDir) = pos.nextDiagonal(right).last;
    if (rPos.cardinals.contains(rDir.left())) rDir = rDir.left();

    return [(lPos, lDir), (rPos, rDir)];
  }

  List<(Position, Direction)> getPawnMoves(Position pos, ChessPiece pawn) {
    final moves1 = pos.nextCardinal(pawn.direction)
        .where((move) => move.$1.inBoard && _board[move.$1] == null);
    return [
      ...moves1,
      if (pawn.firstMoved == null)
        ...moves1
            .expand((move) => move.$1.nextCardinal(move.$2))
            .where((move) => move.$1.inBoard && _board[move.$1] == null),
      ...getPawnAttacks(pos, pawn).where((move) {
        final piece = _board[move.$1];
        return piece != null && piece.player != pawn.player;
      }),
      // TODO: en passant
    ];
  }

  List<(Position, Direction)> getKnightMoves(Position pos) {
    // TODO: Look into a better way to calculate knight moves
    return [
      ...pos.cardinals.expand((dir) {
        final (p, d) = pos.nextCardinal(dir).first;

        final diagonals = p.diagonals;
        var left = d.left();
        if (!diagonals.contains(left)) left = d;

        var right = d.right();
        if (!diagonals.contains(right)) right = d;

        return [p.nextDiagonal(left).first, ...p.nextDiagonal(right)];
      }),
      ...pos.diagonals.expand((dir) {
        final (p, d) = pos.nextDiagonal(dir).first;

        final cardinals = p.cardinals;
        var left = d.left();
        if (!cardinals.contains(left)) left = d;

        var right = d.right();
        if (!cardinals.contains(right)) right = d;

        return [p.nextCardinal(left).first, ...p.nextCardinal(right)];
      }),
    ];
  }

  List<(Position, Direction)> getKingMoves(Position pos, ChessPiece king) {
    return [
      ...pos.cardinals.map((dir) => pos.nextCardinal(dir).first),
      ...pos.diagonals.map((dir) => pos.nextDiagonal(dir).first),
      if (king.firstMoved == null)
        for (final dir in pos.cardinals)
          if (canCastle(pos, king, dir))
            pos.nextCardinal(dir).first.$1.nextCardinal(dir).first
    ];
  }

  Map<Position, Direction> getRawValidMoves(Position pos, ChessPiece piece) {
    final moveList = switch (piece.type) {
      ChessPieceType.pawn => getPawnMoves(pos, piece),
      ChessPieceType.knight => getKnightMoves(pos),
      ChessPieceType.king => getKingMoves(pos, piece),
      ChessPieceType.rook => getRookMoves(pos),
      ChessPieceType.bishop => getBishopMoves(pos),
      ChessPieceType.queen => [...getRookMoves(pos), ...getBishopMoves(pos)],
    };
    final Map<Position, Direction> moveMap = {};
    for (final (pos, dir) in moveList) {
      if (!pos.inBoard || _board[pos]?.player == piece.player) continue;
      moveMap[pos] = dir;
    }
    return moveMap;
  }

  List<(Position, Direction)> getBishopMoves(Position pos) {
    List<(Position, Direction)> moves = [];
    var list = pos.diagonals.expand((dir) => pos.nextDiagonal(dir)).toList();
    for (int i = 0; i < 7 && list.isNotEmpty; ++i) {
      list = list.fold([], (next, move) {
        final (p, d) = move;
        if (p.inBoard && !moves.contains(move)) {
          moves.add(move);
          if (_board[p] == null) {
            next.addAll(p.nextDiagonal(d));
          }
        }
        return next;
      });
    }
    return moves;
  }

  List<(Position, Direction)> getRookMoves(Position pos) {
    List<(Position, Direction)> moves = [];
    var list = pos.cardinals.map((dir) => pos.nextCardinal(dir).first).toList();
    for (int i = 0; i < 7 && list.isNotEmpty; ++i) {
      list = list.fold([], (next, move) {
        final (p, d) = move;
        if (p.inBoard && !moves.contains(move)) {
          moves.add(move);
          if (_board[p] == null) {
            next.addAll(p.nextCardinal(d));
          }
        }
        return next;
      });
    }
    return moves;
  }

  bool canCastle(Position pos, ChessPiece king, Direction dir) {
    if (king.firstMoved != null) return false;
    while (true) {
      pos = pos.nextCardinal(dir).first.$1;
      if (!pos.inBoard) return false;
      final piece = _board[pos];
      if (piece != null) {
        return piece.type == ChessPieceType.rook &&
            piece.firstMoved == null &&
            piece.player == king.player;
      }
    }
  }

  List<Position> getRealValidMoves(Position pos, ChessPiece piece) {
    return [
      for (final move in getRawValidMoves(pos, piece).entries)
        if (!movePiece(pos, move.key, move.value).isKingInCheck(piece.player))
          move.key,
    ];
  }

  /// Returns a new [GameBoard] where the [ChessPiece] at position [from] is moved to position [to] facing the given [Direction].
  GameBoard movePiece(Position from, Position to, Direction dir) {
    final next = Map<Position, ChessPiece>.from(_board);
    final piece = next.remove(from);
    if (piece != null) {
      next[to] = ChessPiece.from(
        from: piece,
        firstMoved: piece.firstMoved ?? turn,
        direction: dir,
      );
    }

    // Castle Logic
    if (piece?.type == ChessPieceType.king) {
      final dRank = to.rank - from.rank;
      final dFile = to.file - from.file;
      final rook = next.remove(switch ((dRank, dFile)) {
        (2, 0) => Position(7, to.file, to.layer),
        (-2, 0) => Position(0, to.file, to.layer),
        (0, 2) => Position(to.rank, 7, to.layer),
        (0, -2) => Position(to.rank, 0, to.layer),
        _ => null,
      });
      if (rook != null) {
        final rookTo = Position(
          from.rank + dRank ~/ 2,
          from.file + dFile ~/ 2,
          from.layer,
        );
        next[rookTo] = ChessPiece.from(
          from: rook,
          firstMoved: turn,
          direction: dir.right(4),
        );
      }
    }

    // TODO: En Passant
    // if (piece?.type == ChessPieceType.pawn &&
    //     from.file != to.file // is an attack
    //     &&
    //     _board[to] == null) {
    //   next.remove((from.rank, to.file));
    // }

    return GameBoard(turn: turn + 1, board: next);
  }


  (Position, Position, Direction) getBestMove(int depth) {
    int bestScore = -9999;
    List<(Position, Position, Direction)> bestMoves = [];

    _board.forEach((from, piece) {
      final moves = getRawValidMoves(from, piece);
      if (piece.player != player) return;
      moves.forEach((to, dir) {
        final nextBoard = movePiece(from, to, dir);
        final map = nextBoard._getBestScore(depth - 1);
        final score = map[player]! - map[nextBoard.player]!;
        if (bestScore < score) {
          bestScore = score;
          bestMoves = [(from, to, dir)];
        } else if (bestScore == score) {
          bestMoves.add((from, to, dir));
        }
      });
    });

    // TODO: handle or prevent cases where there are no moves
    return bestMoves[Random().nextInt(bestMoves.length)];
  }

  Map<Player, int> _getBestScore(int depth) {
    if (depth == 0) return evaluateBoard();

    final counts = {Player.white: 0, Player.black: 0};
    var best = {Player.white: 0, Player.black: 0};
    int bestScore = -9999;

    _board.forEach((from, piece) {
      final moves = getRawValidMoves(from, piece);
      counts[piece.player] = counts[piece.player]! + moves.length;
      if (piece.player != player) return;
      moves.forEach((to, dir) {
        final next = movePiece(from, to, dir);
        final map = next._getBestScore(depth - 1);
        final score = map[player]! - map[next.player]!;
        if (bestScore < score) {
          bestScore = score;
          best = map;
        }
      });
    });

    // Add the number of possible moves to the evaluation to encourage mobility
    counts.forEach((player, count) => best[player] = best[player]! + count);

    return best;
  }

  Map<Player, int> evaluateBoard() {
    final score = {Player.white: 0, Player.black: 0};
    for (var piece in _board.values) {
      score[piece.player] = score[piece.player]! + piece.type.value;
    }
    return score;
  }
}