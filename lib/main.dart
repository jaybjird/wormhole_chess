import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

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
  GameBoard board = GameBoard(turn: 2, board: {
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
  });

  (int rank, int file)? selected;

  List<(int rank, int file)> possibleMoves = [],
      validMoves = [],
      invalidPawnAttacks = [];

  void selectPiece(int rank, int file) {
    setState(() {
      final pos = (rank, file);
      final piece = board[pos];
      if (piece != null) {
        selected = pos;
        // TODO: Currently calls [calculateRawValidMoves] twice. Consider optimizing this
        possibleMoves = board.calculateRawValidMoves(rank, file, piece);
        validMoves = board.calculateRealValidMoves(rank, file, piece);
        invalidPawnAttacks = [
          if (piece.type == ChessPieceType.pawn)
            for (final attack in board.calculatePawnAttacks(rank, file, piece))
              if (!validMoves.contains(attack)) attack,
        ];
      } else {
        selected = null;
        validMoves = [];
        possibleMoves = [];
        invalidPawnAttacks = [];
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
      possibleMoves = [];
      invalidPawnAttacks = [];
      // TODO: Do something with check
      if (board.isKingInCheck(true)) {
        print("White in check");
      }
      if (board.isKingInCheck(false)) {
        print("Black in check");
      }
    });
  }

  // piece: board[(rank, file)],
  // onTap: validMoves.contains((rank, file))
  //     ? () => movePiece(rank, file)
  //     : () => selectPiece(rank, file),
  // isSelected: selected == (rank, file),
  // isValidMove: validMoves.contains((rank, file)),
  // isInvalidPawnAttack: invalidPawnAttacks.contains((rank, file)),
  // isThreatened: possibleMoves.contains((rank, file)) && !validMoves.contains((rank, file)),

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Column(
                  children: [
                    for (int rank = 8; rank-- > 0;)
                      Row(
                        children: [
                          for (int file = 0; file < 8; file++)
                            Expanded(
                              child: (rank == 3 || rank == 4) &&
                                      (file == 3 || file == 4)
                                  ? Container()
                                  : Square(
                                      isWhite: (rank + file) % 2 == 1,
                                      onTap: () {},
                                    ),
                            ),
                        ],
                      ),
                  ],
                ),
                LayoutBuilder(builder: (ctx, constraints) {
                  return Center(
                    child: SizedBox.square(
                      dimension: 5 * constraints.maxHeight / 16,
                      child: Column(
                        children: [
                          for (int rank = 6; rank-- > 2;)
                            Row(
                              children: [
                                for (int file = 2; file < 6; file++)
                                  Expanded(
                                    child: (rank == 3 || rank == 4) &&
                                        (file == 3 || file == 4)
                                        ? Container()
                                        : Square(
                                      isWhite: (rank + file) % 2 == 0,
                                      onTap: () {},
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
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

  bool inBoard(int rank, int file) =>
      rank >= 0 && rank < 8 && file >= 0 && file < 8;

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

  List<(int rank, int file)> calculatePawnAttacks(
      int rank, int file, ChessPiece pawn) {
    final direction = pawn.isWhite ? 1 : -1;
    return [(rank + direction, file + 1), (rank + direction, file - 1)];
  }

  List<(int rank, int file)> calculatePawnMoves(
      int rank, int file, ChessPiece pawn) {
    final direction = pawn.isWhite ? 1 : -1;
    final move1 = (rank + direction, file);
    final move2 = (rank + direction * 2, file);
    bool canAttack((int, int) attack) {
      if (_board[attack] != null) {
        return _board[attack]?.isWhite == !pawn.isWhite;
      }
      final piece = _board[(rank, attack.$2)];
      return piece != null &&
          piece.type == ChessPieceType.pawn &&
          piece.isWhite == !pawn.isWhite &&
          piece.firstMoved == turn - 1 &&
          rank == (piece.isWhite ? 3 : 4);
    }

    return [
      if (_board[move1] == null) move1,
      if (_board[move1] == null &&
          _board[move2] == null &&
          pawn.firstMoved == null)
        move2,
      for (final attack in calculatePawnAttacks(rank, file, pawn))
        if (canAttack(attack)) attack,
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
      int rank, int file, ChessPiece piece) {
    return [
      for (final move in calculateRawValidMoves(rank, file, piece))
        if (!movePiece((rank, file), move).isKingInCheck(piece.isWhite)) move,
    ];
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
      final rook = next.remove(
          switch (dif) { 2 => (from.$1, 7), -2 => (from.$1, 0), _ => null });
      if (rook != null) {
        next[(from.$1, from.$2 + dif ~/ 2)] = rook.firstMoved == null
            ? ChessPiece.from(from: rook, firstMoved: turn)
            : rook;
      }
    }

    // En Passant
    if (piece?.type == ChessPieceType.pawn &&
        from.$2 != to.$2 // is an attack
        &&
        _board[to] == null) {
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
  final bool isInvalidPawnAttack;
  final bool isThreatened;
  final void Function() onTap;

  const Square({
    super.key,
    required this.isWhite,
    this.piece,
    this.isSelected = false,
    this.isValidMove = false,
    this.isInvalidPawnAttack = false,
    this.isThreatened = false,
    required this.onTap,
  });

  Color get color {
    if (isSelected) return Colors.green;
    if (isValidMove) return Colors.green[200]!;
    if (isInvalidPawnAttack) return Colors.yellow[300]!;
    if (isThreatened) return Colors.red[500]!;
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


class RingSegmentClipper extends CustomClipper<Path> {
  final double innerRadius;
  final double outerRadius;
  final double startAngle;
  final double sweepAngle;

  RingSegmentClipper({
    required this.innerRadius,
    required this.outerRadius,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    final center = Offset(size.width / 2, size.height / 2);

    final startAngleRad = startAngle * (3.1415926535897932 / 180);
    final sweepAngleRad = sweepAngle * (3.1415926535897932 / 180);

    path.moveTo(center.dx + innerRadius * cos(startAngleRad),
        center.dy + innerRadius * sin(startAngleRad));

    path.arcTo(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngleRad,
      sweepAngleRad,
      false,
    );

    path.lineTo(center.dx + outerRadius * cos(startAngleRad + sweepAngleRad),
        center.dy + outerRadius * sin(startAngleRad + sweepAngleRad));

    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      startAngleRad + sweepAngleRad,
      -sweepAngleRad,
      false,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class WarpingCornerClipper extends CustomClipper<Path> {
  final double innerRadius;
  final double outerRadius;
  final double startAngle;
  final double sweepAngle;

  WarpingCornerClipper({
    required this.innerRadius,
    required this.outerRadius,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    final center = Offset(size.width / 2, size.height / 2);

    final startAngleRad = startAngle * (3.1415926535897932 / 180);
    final sweepAngleRad = sweepAngle * (3.1415926535897932 / 180);

    path.moveTo(center.dx + innerRadius * cos(startAngleRad),
        center.dy + innerRadius * sin(startAngleRad));

    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      startAngleRad,
      sweepAngleRad,
      false,
    );

    path.lineTo(center.dx + outerRadius * cos(startAngleRad + sweepAngleRad),
        center.dy + outerRadius * sin(startAngleRad + sweepAngleRad));

    if (cos(startAngleRad) * sin(startAngleRad) > 0) {
      path.lineTo(center.dx + outerRadius * cos(startAngleRad),
          center.dy + outerRadius * sin(startAngleRad + sweepAngleRad));
    } else {
      path.lineTo(center.dx + outerRadius * cos(startAngleRad + sweepAngleRad),
          center.dy + outerRadius * sin(startAngleRad));
    }

    path.lineTo(center.dx + outerRadius * cos(startAngleRad),
        center.dy + outerRadius * sin(startAngleRad));

    path.moveTo(center.dx + innerRadius * cos(startAngleRad + sweepAngleRad),
        center.dy + innerRadius * sin(startAngleRad + sweepAngleRad));

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class SquareWithArcClipper extends CustomClipper<Path> {
  final double innerRadius;
  final double startAngle;
  final double sweepAngle;

  SquareWithArcClipper({
    required this.innerRadius,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    final center = Offset(size.width / 2, size.height / 2);

    // Move to first corner
    final startAngleRad = startAngle * (3.1415926535897932 / 180);
    double c1 = cos(startAngleRad);
    double s1 = sin(startAngleRad);
    double x1 = center.dx + innerRadius * c1;
    double y1 = center.dy + innerRadius * s1;
    path.moveTo(x1, y1);

    // Draw an arc to the second corner
    final sweepAngleRad = sweepAngle * (3.1415926535897932 / 180);
    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      startAngleRad,
      sweepAngleRad,
      false,
    );

    // Calculate the position of the second corner
    double c2 = cos(startAngleRad + sweepAngleRad);
    double s2 = sin(startAngleRad + sweepAngleRad);
    double x2 = center.dx + innerRadius * c2;
    double y2 = center.dy + innerRadius * s2;

    // Rotate the angle by 45 degrees and take the tangent. If the tangent
    // is greater than zero, then the square is east/west oriented,
    // otherwise it is north/south oriented
    final orientation = tan(startAngleRad + 45 * (3.1415926535897932 / 180));

    // Draw lines to the third and fourth corners
    if (orientation > 0) {
      final x3 = (x1 * c2 < x2 * c2 ? x1 : x2) + y2 - y1;
      path.lineTo(x3, y2);
      path.lineTo(x3, y1);
    } else {
      final y3 = (y1 * s2 < y2 * s2 ? y1 : y2) - x2 + x1;
      path.lineTo(x2, y3);
      path.lineTo(x1, y3);
    }

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
