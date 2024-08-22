import 'dart:math';

import 'package:wormhole_chess/model/position.dart';

import 'chess_piece.dart';
import 'direction.dart';

enum Mode {
  twoPlayer,
  fourPlayer,
}

final whiteStart = Position(0, 3, 0);

final _possibleStarts = {
  whiteStart: Direction.north,
  Position(7, 4, 0): Direction.south,
  Position(0, 4, 3): Direction.south,
  Position(7, 3, 3): Direction.north,
  Position(4, 0, 3): Direction.west,
  Position(3, 7, 3): Direction.east,
};

Map<Position, ChessPiece> _getInitialPositions(Player player, Position start) {
  final dir = _possibleStarts[start]!;
  final p = start.rank == 0 || start.file == 0 ? 1 : 6;
  final isKing = start.isWhite != (player == Player.white || player == Player.amber);

  ChessPieceType getType(int i) => switch (i) {
    0 || 7 => ChessPieceType.rook,
    1 || 6 => ChessPieceType.knight,
    2 || 5 => ChessPieceType.bishop,
    _ => (i == start.file || i == start.rank) == isKing
        ? ChessPieceType.king
        : ChessPieceType.queen,
  };

  return switch (start.rank) {
    0 || 7 => {
      for (int file = 0; file < 8; file++)
        Position(p, file, start.layer):
        ChessPiece(player: player, direction: dir, type: ChessPieceType.pawn),
      for (int file = 0; file < 8; file++)
        Position(start.rank, file, start.layer):
        ChessPiece(player: player, direction: dir, type: getType(file)),
    },
    _ => {
      for (int rank = 0; rank < 8; rank++)
        Position(rank, p, start.layer):
        ChessPiece(player: player, direction: dir, type: ChessPieceType.pawn),
      for (int rank = 0; rank < 8; rank++)
        Position(rank, start.file, start.layer):
        ChessPiece(player: player, direction: dir, type: getType(rank)),
    },
  };
}

class Move {
  final Player player;
  final Position from;
  final Position to;
  final Direction dir;
  final int turn;
  final ChessPieceType? promotion;

  Move({
    required this.player,
    required this.from,
    required this.to,
    required this.dir,
    required this.turn,
    this.promotion,
  });
}

class GameBoard {
  final Map<Position, ChessPiece> board;
  final List<Move> moves;
  final Mode mode;
  final Player player;
  final Map<Player, Position> startPos;

  GameBoard.empty()
      : startPos = {},
        moves = [],
        mode = Mode.twoPlayer,
        player = Player.white,
        board = {};

  GameBoard.fromMode(Mode mode) : this.build(
    mode: mode,
    startPos: {Player.white: whiteStart},
    player: mode == Mode.twoPlayer ? Player.black : Player.purple,
  );

  GameBoard.build({
    required this.mode,
    required this.startPos,
    required this.player,
    this.moves = const [],
  }) : board = moves.fold(
          {
            for (final entry in startPos.entries)
              ..._getInitialPositions(entry.key, entry.value),
          },
          (board, move) => _movePiece(board, move),
        );

  const GameBoard({
    required this.board,
    required this.moves,
    required this.player,
    required this.mode,
    required this.startPos,
  });

  ChessPiece? operator [](Position? pos) => board[pos];

  Position? getKing(Player player) => board.keys.where((pos) =>
  board[pos]?.type == ChessPieceType.king &&
      board[pos]?.player == player).firstOrNull;

  bool isKingInCheck(Player player) {
    final kingPosition = getKing(player);
    return kingPosition == null || board.entries.any((e) {
      final piece = e.value;
      if (piece.player == player) return false;
      final moves = getRawValidMoves(e.key, piece);
      return moves.keys.any((pos) => pos == kingPosition);
    });
  }

  static List<(Position, Direction)> getPawnAttacks(Position pos, ChessPiece pawn) {
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

  /// Returns the [Position] behind an attack for en passant calculations.
  static Position getEnPassant(ChessPiece pawn, Position from, Position to) {
    // TODO: figure out a cheaper solution
    final moves = from.nextCardinal(pawn.direction);
    final index = getPawnAttacks(from, pawn).indexWhere((e) => e.$1 == to);
    late Position move;
    switch (index) {
      case 0: move = moves.first.$1;
      case 1: move = moves.last.$1;
      default: return from;
    }
    return Position(
      from.rank + to.rank - move.rank,
      from.file + to.file - move.file,
      from.layer + to.layer - move.layer,
    );
  }

  List<(Position, Direction)> getPawnMoves(Position pos, ChessPiece pawn) {
    final moves1 = pos.nextCardinal(pawn.direction)
        .where((move) => move.$1.inBoard && board[move.$1] == null);

    bool canAttack(Position attack) {
      if (!attack.inBoard) return false;
      // Check for a valid basic attack
      if (board[attack] != null) return board[attack]!.player != pawn.player; // TODO: check for ally

      // Check for en passant
      // Calculate the taget position
      final adjacent = getEnPassant(pawn, pos, attack);

      // Check if the target is valid for en passant
      final at = board[adjacent];
      if (at == null) return false;
      if (at.player == pawn.player) return false; // TODO: check for ally
      if (at.type != ChessPieceType.pawn) return false;
      // Check that the target piece's first move was on its player's last turn
      if (moves.lastIndexWhere((move) => move.player == at.player) != at.firstMoved) return false;

      // Check that the target piece had move forward two spaces
      final prev = moves[at.firstMoved!].from; // previous if guarantees null safety
      return switch ((
        prev.rank - adjacent.rank,
        prev.file - adjacent.file,
        prev.layer - adjacent.layer,
      )) {
        (-2 || 2, 0, 0) => true, // moved two ranks
        (0, -2 || 2, 0) => true, // moved two files
        // these checks only work because pawns always outside the wormhole
        (-1 || 1, 0, -1 || 1) => true, // moved one rank and one layer
        (0, -1 || 1, -1 || 1) => true, // moved one file and one layer
        _ => false,
      };
    }

    return [
      ...moves1,
      if (pawn.firstMoved == null)
        ...moves1
            .expand((move) => move.$1.nextCardinal(move.$2))
            .where((move) => move.$1.inBoard && board[move.$1] == null),
      ...getPawnAttacks(pos, pawn).where((move) => canAttack(move.$1)),
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
      if (!pos.inBoard || board[pos]?.player == piece.player) continue;
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
          if (board[p] == null) {
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
          if (board[p] == null) {
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
      final piece = board[pos];
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
    final move = Move(
      player: player,
      from: from,
      to: to,
      dir: dir,
      turn: moves.length,
      promotion: isPromotion(from, to) ? ChessPieceType.queen : null,
    );
    return GameBoard(
      startPos: startPos,
      board: _movePiece(Map<Position, ChessPiece>.from(board), move),
      moves: [...moves, move],
      player: _nextPlayer,
      mode: mode,
    );
  }

  Player get _nextPlayer {
    if (mode == Mode.twoPlayer) {
      return player != Player.white ? Player.white : Player.black;
    }
    int current = player.index;
    for (int i = (current + 1) % 4; i != current; i = (current + 1) % 4) {
      Player next = Player.values[i];
      if (board.values.any((piece) => piece.player == next)) {
        return next;
      }
    }
    return player;
  }

  static Map<Position, ChessPiece> _movePiece(Map<Position, ChessPiece> board, Move move) {
    final piece = board.remove(move.from);
    if (piece == null || !move.to.inBoard) return board;

    // En Passant Logic
    if (piece.type == ChessPieceType.pawn &&
        board[move.to] == null &&
        getPawnAttacks(move.from, piece).any((m) => m.$1 == move.to)) {
      board.remove(getEnPassant(piece, move.from, move.to));
    }

    // Move the piece
    board[move.to] = ChessPiece.from(
      from: piece,
      firstMoved: piece.firstMoved ?? move.turn,
      direction: move.dir,
      type: move.promotion,
    );

    // Castle Logic
    if (piece.type == ChessPieceType.king) {
      final dRank = move.to.rank - move.from.rank;
      final dFile = move.to.file - move.from.file;
      final rook = board.remove(switch ((dRank, dFile)) {
        (2, 0) => Position(7, move.to.file, move.to.layer),
        (-2, 0) => Position(0, move.to.file, move.to.layer),
        (0, 2) => Position(move.to.rank, 7, move.to.layer),
        (0, -2) => Position(move.to.rank, 0, move.to.layer),
        _ => null,
      });
      if (rook != null) {
        final rookTo = Position(
          move.from.rank + dRank ~/ 2,
          move.from.file + dFile ~/ 2,
          move.from.layer,
        );
        board[rookTo] = ChessPiece.from(
          from: rook,
          firstMoved: move.turn,
          direction: move.dir.right(4),
        );
      }
    }
    return board;
  }

  (Position, Position, Direction) getBestMove(int depth) {
    int bestScore = -9999;
    List<(Position, Position, Direction)> bestMoves = [];

    board.forEach((from, piece) {
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

    board.forEach((from, piece) {
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
    for (var piece in board.values) {
      score[piece.player] = score[piece.player]! + piece.type.value;
    }
    return score;
  }

  static List<Position> getPossibleStarts(Iterable<Position> taken) {
    final takenSet = {
      for (final pos in taken) ...[
        pos,
        Position(pos.file, pos.rank, pos.layer),
        Position(7 - pos.file, 7 - pos.rank, pos.layer)
      ],
    };
    return [
      for (final pos in _possibleStarts.keys)
        if (!takenSet.contains(pos))
          pos
    ];
  }

  List<Position> get possibleStarts => getPossibleStarts(startPos.values);

  bool get isStarted => player == Player.white || moves.isNotEmpty;


  bool isPromotion(Position from, Position to) {
    if (board[from]?.type != ChessPieceType.pawn) return false;

    bool canPromote(bool Function(Position) test) =>
        startPos.entries.any((e) => e.key != player &&
            e.value.layer == to.layer && test(e.value));

    return switch ((to.rank, to.file)) {
      (0 || 7, _) when canPromote((pos) => pos.rank == to.rank) => true,
      (_, 0 || 7) when canPromote((pos) => pos.file == to.file) => true,
      _ => false
    };
  }
}
