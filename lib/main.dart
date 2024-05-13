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
      home: GameBoard(),
    );
  }
}

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Map<(int rank, int file), ChessPiece> board = {
    (1, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 1): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 2): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 3): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 4): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 5): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 6): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (1, 7): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    (0, 0): ChessPiece(isWhite: true, type: ChessPieceType.rook),
    (0, 1): ChessPiece(isWhite: true, type: ChessPieceType.knight),
    (0, 2): ChessPiece(isWhite: true, type: ChessPieceType.bishop),
    (0, 3): ChessPiece(isWhite: true, type: ChessPieceType.queen),
    (0, 4): ChessPiece(isWhite: true, type: ChessPieceType.king),
    (0, 5): ChessPiece(isWhite: true, type: ChessPieceType.bishop),
    (0, 6): ChessPiece(isWhite: true, type: ChessPieceType.knight),
    (0, 7): ChessPiece(isWhite: true, type: ChessPieceType.rook),
    (6, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    (6, 1): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
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
  };

  (int rank, int file)? selected;

  List<(int rank, int file)> validMoves = [];

  void selectPiece(int rank, int file) {
    setState(() {
      final pos = (rank, file);
      final piece = board[pos];
      if (piece != null) {
        selected = pos;
        validMoves = calculateRealValidMoves(rank, file, piece, true);
      } else {
        selected = null;
        validMoves = [];
      }
    });
  }

  inBoard(int rank, file) => rank >= 0 && rank < 8 && file >= 0 && file < 8;

  (int rank, int file) getKing(bool isWhite) => board.keys.firstWhere((pos) =>
      board[pos]?.type == ChessPieceType.king &&
      board[pos]?.isWhite == isWhite);

  bool isKingInCheck(bool isWhite) {
    final kingPosition = getKing(isWhite);
    return board.entries.any((e) {
      final piece = e.value;
      if (piece.isWhite == isWhite) return false;
      final (rank, file) = e.key;
      final moves = calculateRawValidMoves(rank, file, piece);
      return moves.any((pos) => pos == kingPosition);
    });
  }

  List<(int, int)> calculatePawnMoves(int rank, int file, ChessPiece pawn) {
    final direction = pawn.isWhite ? 1 : -1;
    final move1 = (rank + direction, file);
    final move2 = (rank + direction * 2, file);
    final notMoved = pawn.isWhite ? rank == 1 : rank == 6;
    final attack1 = (rank + direction, file + 1);
    final attack2 = (rank + direction, file - 1);
    return [
      if (board[move1] == null)
        move1,
      // TODO: Fix up attack logic
      // TODO: En Passant Rules
      if (board[attack1]?.isWhite == !pawn.isWhite)
        attack1,
      if (board[attack2]?.isWhite == !pawn.isWhite)
        attack2,
      if (board[move1] == null && board[move2] == null && notMoved)
        move2,
    ];
  }

  List<(int, int)> calculateRawValidMoves(int rank, int file, ChessPiece piece) {
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
      // TODO: Castle
      ChessPieceType.king => [
          (rank + 1, file),
          (rank + 1, file - 1),
          (rank + 1, file + 1),
          (rank - 1, file),
          (rank - 1, file - 1),
          (rank - 1, file + 1),
          (rank, file - 1),
          (rank, file + 1),
        ],
      // TODO: Castle
      ChessPieceType.rook => [
        ...calculateMoves(rank, file, piece, (r) => r + 1, (f) => f),
        ...calculateMoves(rank, file, piece, (r) => r - 1, (f) => f),
        ...calculateMoves(rank, file, piece, (r) => r, (f) => f + 1),
        ...calculateMoves(rank, file, piece, (r) => r, (f) => f - 1),
      ],
      ChessPieceType.bishop =>  [
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
    // TODO: Castle
    moves.removeWhere(
        (pos) => pos.$1 < 0 || pos.$1 > 7 || pos.$2 < 0 || pos.$2 > 7 || board[pos]?.isWhite == piece.isWhite);
    return moves;
  }

  List<(int, int)> calculateMoves(
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
      final other = board[pos];
      moves.add(pos);
      if (other != null) break;
    }
    return moves;
  }

  List<(int, int)> calculateRealValidMoves(int rank, int file, ChessPiece piece, bool checkSimulation) {
      final rawMoves = calculateRawValidMoves(rank, file, piece);
      List<(int, int)> realMoves = [];
      if (checkSimulation) {
        for (final move in rawMoves) {
          final (r, f) = move;
          if (simulatedMoveIsSafe(piece, (rank, file), move)) {
            realMoves.add(move);
          }
        }
      } else {
        realMoves = rawMoves;
      }
      return realMoves;
  }

  // TODO: Make a copy of the state instead of altering the current board
  bool simulatedMoveIsSafe(ChessPiece piece, (int, int) from, (int, int) to) {
    ChessPiece? toBefore = board[to];
    board.remove(from);
    board[to] = piece;

    bool isSafe = !isKingInCheck(piece.isWhite);

    if (toBefore != null) {
      board[to] = toBefore;
    } else {
      board.remove(to);
    }
    board[from] = piece;

    return isSafe;
  }

  void movePiece(int rank, int file) {
    final piece = board[selected];
    if (piece == null) return;
    setState(() {
      board[(rank, file)] = piece;
      board.remove(selected);
      selected = null;
      validMoves = [];
      // TODO: Do something with check
      if (isKingInCheck(true)) {
        print("White in check");
      }
      if (isKingInCheck(false)) {
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

  ChessPiece({
    required this.type,
    required this.isWhite,
  }) : imagePath = 'assets/${isWhite ? 'white' : 'black'}/${type.name}.svg';
}
