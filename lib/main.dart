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

class Position {
  final int rank, file;
  Position(this.rank, this.file);

  (int, int) get split => (rank, file);

  bool get inBoard => rank >= 0 && rank < 8 && file >= 0 && file < 8;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          rank == other.rank &&
          file == other.file;

  @override
  int get hashCode => rank.hashCode ^ file.hashCode;
}

class GameBoardWidget extends StatefulWidget {
  const GameBoardWidget({super.key});

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  GameBoard board = GameBoard(turn: 2, board: {
    Position(1, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 1): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 2): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 3): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 4): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 5): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 6): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 7): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(0, 0): ChessPiece(isWhite: true, type: ChessPieceType.rook),
    Position(0, 1): ChessPiece(isWhite: true, type: ChessPieceType.knight),
    Position(0, 2): ChessPiece(isWhite: true, type: ChessPieceType.bishop),
    Position(0, 3): ChessPiece(isWhite: true, type: ChessPieceType.queen),
    Position(0, 4): ChessPiece(isWhite: true, type: ChessPieceType.king),
    Position(0, 5): ChessPiece(isWhite: true, type: ChessPieceType.bishop),
    Position(0, 6): ChessPiece(isWhite: true, type: ChessPieceType.knight),
    Position(0, 7): ChessPiece(isWhite: true, type: ChessPieceType.rook),
    Position(6, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 1): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 2): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 3): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 4): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 5): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 6): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 7): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(7, 0): ChessPiece(isWhite: false, type: ChessPieceType.rook),
    Position(7, 1): ChessPiece(isWhite: false, type: ChessPieceType.knight),
    Position(7, 2): ChessPiece(isWhite: false, type: ChessPieceType.bishop),
    Position(7, 3): ChessPiece(isWhite: false, type: ChessPieceType.queen),
    Position(7, 4): ChessPiece(isWhite: false, type: ChessPieceType.king),
    Position(7, 5): ChessPiece(isWhite: false, type: ChessPieceType.bishop),
    Position(7, 6): ChessPiece(isWhite: false, type: ChessPieceType.knight),
    Position(7, 7): ChessPiece(isWhite: false, type: ChessPieceType.rook),
  });

  Position? selected;

  List<Position> possibleMoves = [],
      validMoves = [],
      invalidPawnAttacks = [];

  void selectPiece(int rank, int file) {
    setState(() {
      final pos = Position(rank, file);
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
        board = board.movePiece(selected!, Position(rank, file));
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

  Widget _buildTiles(BuildContext context, BoxConstraints constraints) {
    final size = constraints.maxHeight / 8;
    double outerRadius = size * sqrt(5);
    double innerRadius = size * 1.6; // approx. avg(sqrt(5) + 1)
    double voidRadius = size;
    List<Widget> tiles = [
      Positioned(left: size * 0, top: size * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 0))),
      Positioned(left: size * 1, top: size * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 1))),
      Positioned(left: size * 2, top: size * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 2))),
      Positioned(left: size * 3, top: size * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 3))),
      Positioned(left: size * 4, top: size * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 4))),
      Positioned(left: size * 5, top: size * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 5))),
      Positioned(left: size * 6, top: size * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 6))),
      Positioned(left: size * 7, top: size * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 7))),
      Positioned(left: size * 0, top: size * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 0))),
      Positioned(left: size * 1, top: size * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 1))),
      Positioned(left: size * 2, top: size * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 2))),
      ClipPath(clipper: SquareWithArcClipper(innerRadius: outerRadius, startAngle: 243.5, sweepAngle: 26.5), child: _buildTile(6, 3)),
      ClipPath(clipper: SquareWithArcClipper(innerRadius: outerRadius, startAngle: 270.0, sweepAngle: 26.5), child: _buildTile(6, 4)),
      Positioned(left: size * 5, top: size * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 5))),
      Positioned(left: size * 6, top: size * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 6))),
      Positioned(left: size * 7, top: size * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 7))),
      Positioned(left: size * 0, top: size * 2, child: SizedBox.square(dimension: size, child: _buildTile(5, 0))),
      Positioned(left: size * 1, top: size * 2, child: SizedBox.square(dimension: size, child: _buildTile(5, 1))),
      ClipPath(clipper: WarpingCornerClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 206.5, sweepAngle: 37.0), child: _buildTile(5, 2)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 206.5, sweepAngle: 37.0), child: _buildTile(5, 2)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 243.5, sweepAngle: 26.5), child: _buildTile(5, 3)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 243.5, sweepAngle: 26.5), child: _buildTile(5, 3)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 270.0, sweepAngle: 26.5), child: _buildTile(5, 4)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 270.0, sweepAngle: 26.5), child: _buildTile(5, 4)),
      ClipPath(clipper: WarpingCornerClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 296.5, sweepAngle: 37.0), child: _buildTile(5, 5)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 296.5, sweepAngle: 37.0), child: _buildTile(5, 5)),
      Positioned(left: size * 6, top: size * 2, child: SizedBox.square(dimension: size, child: _buildTile(5, 6))),
      Positioned(left: size * 7, top: size * 2, child: SizedBox.square(dimension: size, child: _buildTile(5, 7))),
      Positioned(left: size * 0, top: size * 3, child: SizedBox.square(dimension: size, child: _buildTile(4, 0))),
      ClipPath(clipper: SquareWithArcClipper(innerRadius: outerRadius, startAngle: 540.0, sweepAngle: 26.5), child: _buildTile(4, 1)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 540.0, sweepAngle: 26.5), child: _buildTile(4, 2)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 540.0, sweepAngle: 26.5), child: _buildTile(4, 2)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 333.5, sweepAngle: 26.5), child: _buildTile(4, 5)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 333.5, sweepAngle: 26.5), child: _buildTile(4, 5)),
      ClipPath(clipper: SquareWithArcClipper(innerRadius: outerRadius, startAngle: 333.5, sweepAngle: 26.5), child: _buildTile(4, 6)),
      Positioned(left: size * 7, top: size * 3, child: SizedBox.square(dimension: size, child: _buildTile(4, 7))),
      Positioned(left: size * 0, top: size * 4, child: SizedBox.square(dimension: size, child: _buildTile(3, 0))),
      ClipPath(clipper: SquareWithArcClipper(innerRadius: outerRadius, startAngle: 513.5, sweepAngle: 26.5), child: _buildTile(3, 1)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 513.5, sweepAngle: 26.5), child: _buildTile(3, 2)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 513.5, sweepAngle: 26.5), child: _buildTile(3, 2)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 360.0, sweepAngle: 26.5), child: _buildTile(3, 5)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 360.0, sweepAngle: 26.5), child: _buildTile(3, 5)),
      ClipPath(clipper: SquareWithArcClipper(innerRadius: outerRadius, startAngle: 360.0, sweepAngle: 26.5), child: _buildTile(3, 6)),
      Positioned(left: size * 7, top: size * 4, child: SizedBox.square(dimension: size, child: _buildTile(3, 7))),
      Positioned(left: size * 0, top: size * 5, child: SizedBox.square(dimension: size, child: _buildTile(2, 0))),
      Positioned(left: size * 1, top: size * 5, child: SizedBox.square(dimension: size, child: _buildTile(2, 1))),
      ClipPath(clipper: WarpingCornerClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 476.5, sweepAngle: 37.0), child: _buildTile(2, 2)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 476.5, sweepAngle: 37.0), child: _buildTile(2, 2)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 450.0, sweepAngle: 26.5), child: _buildTile(2, 3)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 450.0, sweepAngle: 26.5), child: _buildTile(2, 3)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 423.5, sweepAngle: 26.5), child: _buildTile(2, 4)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 423.5, sweepAngle: 26.5), child: _buildTile(2, 4)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 386.5, sweepAngle: 37.0), child: _buildTile(2, 5)),
      ClipPath(clipper: WarpingCornerClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 386.5, sweepAngle: 37.0), child: _buildTile(2, 5)),
      Positioned(left: size * 6, top: size * 5, child: SizedBox.square(dimension: size, child: _buildTile(2, 6))),
      Positioned(left: size * 7, top: size * 5, child: SizedBox.square(dimension: size, child: _buildTile(2, 7))),
      Positioned(left: size * 0, top: size * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 0))),
      Positioned(left: size * 1, top: size * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 1))),
      Positioned(left: size * 2, top: size * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 2))),
      ClipPath(clipper: SquareWithArcClipper(innerRadius: outerRadius, startAngle: 450.0, sweepAngle: 26.5), child: _buildTile(1, 3)),
      ClipPath(clipper: SquareWithArcClipper(innerRadius: outerRadius, startAngle: 423.5, sweepAngle: 26.5), child: _buildTile(1, 4)),
      Positioned(left: size * 5, top: size * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 5))),
      Positioned(left: size * 6, top: size * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 6))),
      Positioned(left: size * 7, top: size * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 7))),
      Positioned(left: size * 0, top: size * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 0))),
      Positioned(left: size * 1, top: size * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 1))),
      Positioned(left: size * 2, top: size * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 2))),
      Positioned(left: size * 3, top: size * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 3))),
      Positioned(left: size * 4, top: size * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 4))),
      Positioned(left: size * 5, top: size * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 5))),
      Positioned(left: size * 6, top: size * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 6))),
      Positioned(left: size * 7, top: size * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 7))),
    ];

    return Stack(children: tiles);
  }

  Tile _buildTile(int rank, int file) {
    final pos = Position(rank, file);
    return Tile(
      onTap: validMoves.contains(pos)
          ? () => movePiece(rank, file)
          : () => selectPiece(rank, file),
      isSelected: selected == pos,
      isValidMove: validMoves.contains(pos),
      isInvalidPawnAttack: invalidPawnAttacks.contains(pos),
      isThreatened: possibleMoves.contains(pos) &&
          !validMoves.contains(pos),
      piece: board[pos],
      isWhite: (rank + file) % 2 == 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(builder: _buildTiles),
          ),
        ),
      ),
    );
  }
}

class GameBoard {
  final Map<Position, ChessPiece> _board;
  final int turn;

  GameBoard({
    this.turn = 1,
    required Map<Position, ChessPiece> board,
  }) : _board = board;

  ChessPiece? operator [](Position pos) => _board[pos];

  Position getKing(bool isWhite) => _board.keys.firstWhere((pos) =>
      _board[pos]?.type == ChessPieceType.king &&
      _board[pos]?.isWhite == isWhite);

  bool isKingInCheck(bool isWhite) {
    final kingPosition = getKing(isWhite);
    return _board.entries.any((e) {
      final piece = e.value;
      if (piece.isWhite == isWhite) return false;
      final (rank, file) = e.key.split;
      final moves = calculateRawValidMoves(rank, file, piece);
      return moves.any((pos) => pos == kingPosition);
    });
  }

  List<Position> calculatePawnAttacks(
      int rank, int file, ChessPiece pawn) {
    final direction = pawn.isWhite ? 1 : -1;
    return [Position(rank + direction, file + 1), Position(rank + direction, file - 1)];
  }

  List<Position> calculatePawnMoves(
      int rank, int file, ChessPiece pawn) {
    final direction = pawn.isWhite ? 1 : -1;
    final move1 = Position(rank + direction, file);
    final move2 = Position(rank + direction * 2, file);
    bool canAttack(Position attack) {
      if (_board[attack] != null) {
        return _board[attack]?.isWhite == !pawn.isWhite;
      }
      final piece = _board[(rank, attack.file)];
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

  List<Position> calculateRawValidMoves(
    int rank,
    int file,
    ChessPiece piece,
  ) {
    List<Position> moves = switch (piece.type) {
      ChessPieceType.pawn => calculatePawnMoves(rank, file, piece),
      ChessPieceType.knight => [
          Position(rank + 1, file + 2),
          Position(rank + 1, file - 2),
          Position(rank - 1, file + 2),
          Position(rank - 1, file - 2),
          Position(rank + 2, file + 1),
          Position(rank + 2, file - 1),
          Position(rank - 2, file + 1),
          Position(rank - 2, file - 1),
        ],
      ChessPieceType.king => [
          Position(rank + 1, file),
          Position(rank + 1, file - 1),
          Position(rank + 1, file + 1),
          Position(rank - 1, file),
          Position(rank - 1, file - 1),
          Position(rank - 1, file + 1),
          Position(rank, file - 1),
          Position(rank, file + 1),
          if (canCastle(rank, file, piece, (r) => r, (f) => f + 1))
            Position(rank, file + 2),
          if (canCastle(rank, file, piece, (r) => r, (f) => f - 1))
            Position(rank, file - 2),
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
    moves.removeWhere((pos) =>
    !pos.inBoard || _board[pos]?.isWhite == piece.isWhite);
    return moves;
  }

  List<Position> calculateMoves(
    int rank,
    int file,
    ChessPiece piece,
    int Function(int) nextRank,
    int Function(int) nextFile,
  ) {
    List<Position> moves = [];
    while (true) {
      rank = nextRank(rank);
      file = nextFile(file);
      final pos = Position(rank, file);
      if (!pos.inBoard) break;
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
      final pos = Position(rank, file);
      if (!pos.inBoard) return false;
      final piece = _board[pos];
      if (piece != null) {
        return piece.type == ChessPieceType.rook &&
            piece.firstMoved == null &&
            piece.isWhite == king.isWhite;
      }
    }
  }

  List<Position> calculateRealValidMoves(
      int rank, int file, ChessPiece piece) {
    return [
      for (final move in calculateRawValidMoves(rank, file, piece))
        if (!movePiece(Position(rank, file), move).isKingInCheck(piece.isWhite)) move,
    ];
  }

  /// Returns a new [GameBoard] where the [ChessPiece] at position [from] is moved to position [to].
  GameBoard movePiece(Position from, Position to) {
    final next = Map<Position, ChessPiece>.from(_board);
    final piece = next.remove(from);
    if (piece != null) {
      next[to] = piece.firstMoved == null
          ? ChessPiece.from(from: piece, firstMoved: turn)
          : piece;
    }

    // Castle Logic
    if (piece?.type == ChessPieceType.king) {
      final dif = to.file - from.file;
      final rook = next.remove(
          switch (dif) { 2 => (from.rank, 7), -2 => (from.rank, 0), _ => null });
      if (rook != null) {
        next[Position(from.rank, from.file + dif ~/ 2)] = rook.firstMoved == null
            ? ChessPiece.from(from: rook, firstMoved: turn)
            : rook;
      }
    }

    // En Passant
    if (piece?.type == ChessPieceType.pawn &&
        from.file != to.file // is an attack
        &&
        _board[to] == null) {
      next.remove((from.rank, to.file));
    }

    return GameBoard(turn: turn + 1, board: next);
  }
}

class Tile extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final bool isInvalidPawnAttack;
  final bool isThreatened;
  final void Function() onTap;

  const Tile({
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
      child: Container(
        color: color,
        child: AspectRatio(
          aspectRatio: 1,
          child: piece != null ? SvgPicture.asset(piece!.imagePath) : null,
        )
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
