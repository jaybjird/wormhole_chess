import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // debugShowCheckedModeBanner: false,
      home: GameBoardWidget(),
    );
  }
}

class GameBoardWidget extends StatefulWidget {
  const GameBoardWidget({super.key});

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  GameBoard board = GameBoard(turn: 2, board:{
    (3, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn, firstMoved: 1),
    (1, 1): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 2): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 3): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 4): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 5): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 6): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 7): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (0, 0): ChessPiece(isWhite: true, type: ChessPieceType.rook),
    // (0, 1): ChessPiece(isWhite: true, type: ChessPieceType.knight),
    // (0, 2): ChessPiece(isWhite: true, type: ChessPieceType.bishop),
    // (0, 3): ChessPiece(isWhite: true, type: ChessPieceType.queen),
    (0, 4): ChessPiece(isWhite: true, type: ChessPieceType.king),
    // (0, 5): ChessPiece(isWhite: true, type: ChessPieceType.bishop),
    // (0, 6): ChessPiece(isWhite: true, type: ChessPieceType.knight),
    (0, 7): ChessPiece(isWhite: true, type: ChessPieceType.rook),
    (6, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    (3, 1): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    (6, 2): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    (6, 3): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    (6, 4): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    (6, 5): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    (6, 6): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    (6, 7): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    (7, 0): ChessPiece(isWhite: false, type: ChessPieceType.rook),
    (7, 1): ChessPiece(isWhite: false, type: ChessPieceType.knight),
    (7, 2): ChessPiece(isWhite: false, type: ChessPieceType.bishop),
    (7, 3): ChessPiece(isWhite: false, type: ChessPieceType.queen),
    (7, 4): ChessPiece(isWhite: false, type: ChessPieceType.king),
    (7, 5): ChessPiece(isWhite: false, type: ChessPieceType.bishop),
    (7, 6): ChessPiece(isWhite: false, type: ChessPieceType.knight),
    (7, 7): ChessPiece(isWhite: false, type: ChessPieceType.rook),
  });

  (int rank, int file)? selected;

  List<(int rank, int file)> validMoves = [];

  void selectPiece(int rank, int file) {
    setState(() {
      final pos = (rank, file);
      final piece = board[pos];
      if (piece != null) {
        selected = pos;
        validMoves = board.calculateRealValidMoves(rank, file, piece, true);
      } else {
        selected = null;
        validMoves = [];
      }
    });
  }

  void movePiece(int rank, int file) {
    setState(() {
      if (selected != null) {
        board = board.movePiece(selected!, (rank, file));
      }
      selected = null;
      validMoves = [];
      // TODO: Do something with check
      if (board.isKingInCheck(true)) {
        print("White in check");
      }
      if (board.isKingInCheck(false)) {
        print("Black in check");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              for (int rank = 8; rank-- > 0;)
                Row(
                  children: [
                    for (int file = 0; file < 8; file++)
                      Expanded(
                        child: Square(
                          isWhite: (rank + file) % 2 == 1,
                          piece: board[(rank, file)],
                          onTap: validMoves.contains((rank, file))
                              ? () => movePiece(rank, file)
                              : () => selectPiece(rank, file),
                          isSelected: selected == (rank, file),
                          isValidMove: validMoves.contains((rank, file)),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameBoard {
  final Map<(int rank, int file), ChessPiece> _board;
  final int turn;

  GameBoard({
    this.turn = 1,
    required Map<(int rank, int file), ChessPiece> board,
  }) : _board = board;

  ChessPiece? operator []((int, int) pos) => _board[pos]; // get

  bool inBoard(int rank, int file) => rank >= 0 && rank < 8 && file >= 0 && file < 8;

  (int rank, int file) getKing(bool isWhite) => _board.keys.firstWhere((pos) =>
  _board[pos]?.type == ChessPieceType.king &&
      _board[pos]?.isWhite == isWhite);

  bool isKingInCheck(bool isWhite) {
    final kingPosition = getKing(isWhite);
    return _board.entries.any((e) {
      final piece = e.value;
      if (piece.isWhite == isWhite) return false;
      final (rank, file) = e.key;
      final moves = calculateRawValidMoves(rank, file, piece);
      return moves.any((pos) => pos == kingPosition);
    });
  }

  List<(int rank, int file)> calculatePawnMoves(int rank, int file, ChessPiece pawn) {
    final direction = pawn.isWhite ? 1 : -1;
    final move1 = (rank + direction, file);
    final move2 = (rank + direction * 2, file);
    final attack1 = (rank + direction, file + 1);
    final attack2 = (rank + direction, file - 1);
    bool canAttack((int, int) attack) {
      if (_board[attack] != null) {
        return _board[attack]?.isWhite == !pawn.isWhite;
      }
      final piece = _board[(rank, attack.$2)];
      return piece != null
          && piece.type == ChessPieceType.pawn
          && piece.isWhite == !pawn.isWhite
          && piece.firstMoved == turn - 1
          && rank == (piece.isWhite ? 3 : 4);
    }
    canAttack(attack1);
    return [
      if (_board[move1] == null) move1,
      if (_board[move1] == null && _board[move2] == null && pawn.firstMoved == null) move2,
      if (canAttack(attack1)) attack1,
      if (canAttack(attack2)) attack2,
    ];
  }

  List<(int rank, int file)> calculateRawValidMoves(
      int rank,
      int file,
      ChessPiece piece,
      ) {
    List<(int, int)> moves = switch (piece.type) {
      ChessPieceType.pawn => calculatePawnMoves(rank, file, piece),
      ChessPieceType.knight => [
        (rank + 1, file + 2),
        (rank + 1, file - 2),
        (rank - 1, file + 2),
        (rank - 1, file - 2),
        (rank + 2, file + 1),
        (rank + 2, file - 1),
        (rank - 2, file + 1),
        (rank - 2, file - 1),
      ],
      ChessPieceType.king => [
        (rank + 1, file),
        (rank + 1, file - 1),
        (rank + 1, file + 1),
        (rank - 1, file),
        (rank - 1, file - 1),
        (rank - 1, file + 1),
        (rank, file - 1),
        (rank, file + 1),
        if (canCastle(rank, file, piece, (r) => r, (f) => f + 1))
          (rank, file + 2),
        if (canCastle(rank, file, piece, (r) => r, (f) => f - 1))
          (rank, file - 2),
      ],
      ChessPieceType.rook => [
        ...calculateMoves(rank, file, piece, (r) => r + 1, (f) => f),
        ...calculateMoves(rank, file, piece, (r) => r - 1, (f) => f),
        ...calculateMoves(rank, file, piece, (r) => r, (f) => f + 1),
        ...calculateMoves(rank, file, piece, (r) => r, (f) => f - 1),
      ],
      ChessPieceType.bishop => [
        ...calculateMoves(rank, file, piece, (r) => r + 1, (f) => f + 1),
        ...calculateMoves(rank, file, piece, (r) => r + 1, (f) => f - 1),
        ...calculateMoves(rank, file, piece, (r) => r - 1, (f) => f + 1),
        ...calculateMoves(rank, file, piece, (r) => r - 1, (f) => f - 1),
      ],
      ChessPieceType.queen => [
        ...calculateMoves(rank, file, piece, (r) => r + 1, (f) => f),
        ...calculateMoves(rank, file, piece, (r) => r - 1, (f) => f),
        ...calculateMoves(rank, file, piece, (r) => r, (f) => f + 1),
        ...calculateMoves(rank, file, piece, (r) => r, (f) => f - 1),
        ...calculateMoves(rank, file, piece, (r) => r + 1, (f) => f + 1),
        ...calculateMoves(rank, file, piece, (r) => r + 1, (f) => f - 1),
        ...calculateMoves(rank, file, piece, (r) => r - 1, (f) => f + 1),
        ...calculateMoves(rank, file, piece, (r) => r - 1, (f) => f - 1),
      ],
    };
    moves.removeWhere((pos) {
      final (r, f) = pos;
      return !inBoard(r, f) || _board[pos]?.isWhite == piece.isWhite;
    });
    return moves;
  }

  List<(int rank, int file)> calculateMoves(
      int rank,
      int file,
      ChessPiece piece,
      int Function(int) nextRank,
      int Function(int) nextFile,
      ) {
    List<(int, int)> moves = [];
    while (true) {
      rank = nextRank(rank);
      file = nextFile(file);
      if (!inBoard(rank, file)) break;
      final pos = (rank, file);
      final other = _board[pos];
      moves.add(pos);
      if (other != null) break;
    }
    return moves;
  }

  bool canCastle(
      int rank,
      int file,
      ChessPiece king,
      int Function(int) nextRank,
      int Function(int) nextFile,
      ) {
    if (king.firstMoved != null) return false;
    while (true) {
      rank = nextRank(rank);
      file = nextFile(file);
      if (!inBoard(rank, file)) return false;
      final pos = (rank, file);
      final piece = _board[pos];
      if (piece != null) {
        return piece.type == ChessPieceType.rook &&
            piece.firstMoved == null &&
            piece.isWhite == king.isWhite;
      }
    }
  }

  List<(int rank, int file)> calculateRealValidMoves(
      int rank, int file, ChessPiece piece, bool checkSimulation) {
    final rawMoves = calculateRawValidMoves(rank, file, piece);
    List<(int, int)> realMoves = [];
    if (checkSimulation) {
      for (final move in rawMoves) {
        if (!movePiece((rank, file), move).isKingInCheck(piece.isWhite)) {
          realMoves.add(move);
        }
      }
    } else {
      realMoves = rawMoves;
    }
    return realMoves;
  }

  /// Returns a new [GameBoard] where the [ChessPiece] at position [from] is moved to position [to].
  GameBoard movePiece((int rank, int file) from, (int rank, int file) to) {
    final next = Map<(int, int), ChessPiece>.from(_board);
    final piece = next.remove(from);
    if (piece != null) {
      next[to] = piece.firstMoved == null
          ? ChessPiece.from(from: piece, firstMoved: turn)
          : piece;
    }

    // Castle Logic
    if (piece?.type == ChessPieceType.king) {
      final dif = to.$2 - from.$2;
      final rook = next.remove(switch(dif) {
        2 => (from.$1, 7),
        -2 => (from.$1, 0),
        _ => null
      });
      if (rook != null) {
        next[(from.$1, from.$2 + dif ~/ 2)] = rook.firstMoved == null
            ? ChessPiece.from(from: rook, firstMoved: turn)
            : rook;
      }
    }

    // En Passant
    if (piece?.type == ChessPieceType.pawn
        && from.$2 != to.$2 // is an attack
        && _board[to] == null) {
      next.remove((from.$1, to.$2));
    }

    return GameBoard(turn: turn + 1, board: next);
  }
}

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function() onTap;

  const Square({
    super.key,
    required this.isWhite,
    this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.onTap,
  });

  Color get color {
    if (isSelected) return Colors.green;
    if (isValidMove) return Colors.green[200]!;
    return Colors.grey[isWhite ? 300 : 600]!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: color,
          child: piece != null ? SvgPicture.asset(piece!.imagePath) : null,
        ),
      ),
    );
  }
}

enum ChessPieceType { pawn, rook, knight, bishop, queen, king }

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;
  final int? firstMoved;

  ChessPiece({
    required this.type,
    required this.isWhite,
    this.firstMoved,
  }) : imagePath = 'assets/${isWhite ? 'white' : 'black'}/${type.name}.svg';

  ChessPiece.from({
    required ChessPiece from,
    ChessPieceType? type,
    int? firstMoved,
  }) : this(
    type: type ?? from.type,
    isWhite: from.isWhite,
    firstMoved: firstMoved ?? from.firstMoved,
  );
}
