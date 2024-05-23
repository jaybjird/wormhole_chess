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

enum Direction {
  north,
  northeast,
  east,
  southeast,
  south,
  southwest,
  west,
  northwest;

  Direction right([int i = 1]) => Direction.values[(index + i) % 8];
  Direction left([int i = 1]) => Direction.values[(8 + index - i) % 8];
  bool get isCardinal => index % 2 == 0;
}

class Position {
  final int rank, file, layer;
  final Direction? _ringSide;

  Position(this.rank, this.file, this.layer)
      : _ringSide = switch ((rank, file)) {
          // Null if not part of the ring
          (int r, int f) when r < 2 || r > 5 || f < 2 || f > 5 => null,
          (2, 2) => Direction.southwest,
          (2, 5) => Direction.southeast,
          (2, _) => Direction.south,
          (5, 2) => Direction.northwest,
          (5, 5) => Direction.northeast,
          (5, _) => Direction.north,
          (_, 2) => Direction.west,
          (_, 5) => Direction.east,
          _ => null, // Included for exhaustiveness
        }?.right(layer < 2 ? 0 : 4); // Invert if on the reverse layer

  @override
  String toString() => 'Position{rank: $rank, file: $file, layer: $layer}';

  (int, int, int) get split => (rank, file, layer);

  Map<Position, Direction> next(Direction dir) {
    if (_ringSide != null && !_ringSide.isCardinal && (layer == 0 || layer == 3)) {
      final mod = layer < 2 ? 1 : -1;
      return dir.isCardinal
          ? {
              ..._next(dir),
              Position(rank, file, layer + mod): _ringSide.right(4)
            }
          : {..._next(dir.left()), ..._next(dir.right())};
    }

    if (isRingCorner()) {
      // TODO: avoid !
      if (_ringSide!.index % 4 == dir.index % 4) {
        return {Position(rank, file, layer + (_ringSide == dir ? -1 : 1)): dir};
      }

      final turnRight = dir == _ringSide.right(2);
      final turned = turnRight ? dir.right() : dir.left();
      return _next(turned);
    }

    return nextEuclidean(dir);
  }

  Map<Position, Direction> _next(Direction dir) {
    final mod = layer < 2 ? 1 : -1;
    return switch (dir) {
      Direction.north => {Position(rank + mod, file, layer): dir},
      Direction.south => {Position(rank - mod, file, layer): dir},
      Direction.east => {Position(rank, file + mod, layer): dir},
      Direction.west => {Position(rank, file - mod, layer): dir},
      _ => {}, // TODO: be exhaustive
    };
  }

  Map<Position, Direction> nextEuclidean(Direction dir) {
    var pos = _next(dir).keys.first; // TODO
    if (!pos.inBoard) {
      final dLayer = switch (dir) {
        Direction.north => rank < 4 ? 1 : -1,
        Direction.south => rank < 4 ? -1 : 1,
        Direction.east => file < 4 ? 1 : -1,
        Direction.west => file < 4 ? -1 : 1,
        _ => 0,
      };
      return {Position(rank, file, layer + dLayer): dir};
    }
    if (_ringSide != null) {
      if (_ringSide.right() == pos._ringSide)  {
        return {pos: _ringSide.right(3)};
      } else if (_ringSide.left() == pos._ringSide) {
        return {pos: _ringSide.left(3)};
      }
    }
    return {pos: dir};
  }

  bool isRingCorner() =>
      (rank == 2 || rank == 5) &&
          (file == 2 || file == 5) &&
          (layer == 1 || layer == 2);

  List<Direction> get cardinals {
    if (_ringSide == null || _ringSide.isCardinal) {
      return [
        Direction.north,
        Direction.east,
        Direction.south,
        Direction.west,
      ];
    }
    final directions = [
      Direction.northeast,
      Direction.southeast,
      Direction.southwest,
      Direction.northwest,
    ];
    if (layer == 0 || layer == 3) {
      // For five sided tiles, split one of the directions in two, but maintain
      // sort order.
      final opposite = _ringSide.right(4);
      final index = directions.indexOf(opposite);
      directions[index] = opposite.right();
      directions.insert(index, opposite.left());
    }
    return directions;
  }

  bool get inBoard {
    // The center 4 positions do not exist on any layer
    if ((rank == 3 || rank == 4) && (file == 3 || file == 4)) return false;
    switch(layer) {
      case 0 || 3: // main layers contain any position
        return rank >= 0 && rank < 8 && file >= 0 && file < 8;
      case 1 || 2: // ring layers do not contain outer positions
        return rank >= 2 && rank < 6 && file >= 2 && file < 6;
      default:
        return false;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          rank == other.rank &&
          file == other.file &&
          layer == other.layer;

  @override
  int get hashCode => rank.hashCode ^ file.hashCode ^ layer.hashCode;
}

class GameBoardWidget extends StatefulWidget {
  const GameBoardWidget({super.key});

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  GameBoard board = GameBoard(turn: 2, board: {
    Position(1, 0, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 1, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 2, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 3, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 4, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 5, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 6, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(1, 7, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn),
    Position(0, 0, 0): ChessPiece(isWhite: true, type: ChessPieceType.rook),
    Position(0, 1, 0): ChessPiece(isWhite: true, type: ChessPieceType.knight),
    Position(0, 2, 0): ChessPiece(isWhite: true, type: ChessPieceType.bishop),
    Position(0, 3, 0): ChessPiece(isWhite: true, type: ChessPieceType.queen),
    Position(0, 4, 0): ChessPiece(isWhite: true, type: ChessPieceType.king),
    Position(0, 5, 0): ChessPiece(isWhite: true, type: ChessPieceType.bishop),
    Position(0, 6, 0): ChessPiece(isWhite: true, type: ChessPieceType.knight),
    Position(0, 7, 0): ChessPiece(isWhite: true, type: ChessPieceType.rook),
    Position(6, 0, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 1, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 2, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 3, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 4, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 5, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 6, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(6, 7, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn),
    Position(7, 0, 0): ChessPiece(isWhite: false, type: ChessPieceType.rook),
    Position(7, 1, 0): ChessPiece(isWhite: false, type: ChessPieceType.knight),
    Position(7, 2, 0): ChessPiece(isWhite: false, type: ChessPieceType.bishop),
    Position(7, 3, 0): ChessPiece(isWhite: false, type: ChessPieceType.queen),
    Position(7, 4, 0): ChessPiece(isWhite: false, type: ChessPieceType.king),
    Position(7, 5, 0): ChessPiece(isWhite: false, type: ChessPieceType.bishop),
    Position(7, 6, 0): ChessPiece(isWhite: false, type: ChessPieceType.knight),
    Position(7, 7, 0): ChessPiece(isWhite: false, type: ChessPieceType.rook),
  });

  Position? selected;

  List<Position> possibleMoves = [],
      validMoves = [],
      invalidPawnAttacks = [];

  void selectPiece(int rank, int file, int layer) {
    setState(() {
      final pos = Position(rank, file, layer);
      final piece = board[pos];
      if (piece != null) {
        selected = pos;
        // TODO: Currently calls [calculateRawValidMoves] twice. Consider optimizing this
        possibleMoves = board.calculateRawValidMoves(rank, file, layer, piece);
        validMoves = board.calculateRealValidMoves(rank, file, layer, piece);
        invalidPawnAttacks = [
          if (piece.type == ChessPieceType.pawn)
            for (final attack in board.calculatePawnAttacks(rank, file, layer, piece))
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

  void movePiece(int rank, int file, int layer) {
    setState(() {
      if (selected != null) {
        board = board.movePiece(selected!, Position(rank, file, layer));
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

  Widget _buildTiles(BuildContext context, BoxConstraints constraints, int mainLayer, int ringLayer) {
    final size = constraints.maxHeight / 8;
    final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    final (w, h) = (center.dx / 4, center.dy / 4);

    double outerRadius = size * sqrt(5);
    double innerRadius = size * 1.6; // approx. avg(sqrt(5) + 1)
    double voidRadius = size;
    List<Widget> tiles = [
      Positioned(left: w * 0, top: h * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 0, mainLayer))),
      Positioned(left: w * 1, top: h * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 1, mainLayer))),
      Positioned(left: w * 2, top: h * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 2, mainLayer))),
      Positioned(left: w * 3, top: h * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 3, mainLayer))),
      Positioned(left: w * 4, top: h * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 4, mainLayer))),
      Positioned(left: w * 5, top: h * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 5, mainLayer))),
      Positioned(left: w * 6, top: h * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 6, mainLayer))),
      Positioned(left: w * 7, top: h * 0, child: SizedBox.square(dimension: size, child: _buildTile(7, 7, mainLayer))),
      Positioned(left: w * 0, top: h * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 0, mainLayer))),
      Positioned(left: w * 1, top: h * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 1, mainLayer))),
      Positioned(left: w * 2, top: h * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 2, mainLayer))),
      Positioned(left: w * 3, top: h * 1, child: SizedBox.square(dimension: size, child: ClipPath( clipper: SquareWithArcClipper( arcRadius: outerRadius, center: center.translate(-w * 3, -h * 1)), child: _buildTile(6, 3, mainLayer)))),
      Positioned(left: w * 4, top: h * 1, child: SizedBox.square(dimension: size, child: ClipPath( clipper: SquareWithArcClipper( arcRadius: outerRadius, center: center.translate(-w * 4, -h * 1)), child: _buildTile(6, 4, mainLayer)))),
      Positioned(left: w * 5, top: h * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 5, mainLayer))),
      Positioned(left: w * 6, top: h * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 6, mainLayer))),
      Positioned(left: w * 7, top: h * 1, child: SizedBox.square(dimension: size, child: _buildTile(6, 7, mainLayer))),
      Positioned(left: w * 0, top: h * 2, child: SizedBox.square(dimension: size, child: _buildTile(5, 0, mainLayer))),
      Positioned(left: w * 1, top: h * 2, child: SizedBox.square(dimension: size, child: _buildTile(5, 1, mainLayer))),
      ClipPath(clipper: WarpingCornerClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 206.5, sweepAngle: 37.0), child: _buildTile(5, 2, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 206.5, sweepAngle: 37.0), child: _buildTile(5, 2, ringLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 243.5, sweepAngle: 26.5), child: _buildTile(5, 3, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 243.5, sweepAngle: 26.5), child: _buildTile(5, 3, ringLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 270.0, sweepAngle: 26.5), child: _buildTile(5, 4, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 270.0, sweepAngle: 26.5), child: _buildTile(5, 4, ringLayer)),
      ClipPath(clipper: WarpingCornerClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 296.5, sweepAngle: 37.0), child: _buildTile(5, 5, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 296.5, sweepAngle: 37.0), child: _buildTile(5, 5, ringLayer)),
      Positioned(left: w * 6, top: h * 2, child: SizedBox.square(dimension: size, child: _buildTile(5, 6, mainLayer))),
      Positioned(left: w * 7, top: h * 2, child: SizedBox.square(dimension: size, child: _buildTile(5, 7, mainLayer))),
      Positioned(left: w * 0, top: h * 3, child: SizedBox.square(dimension: size, child: _buildTile(4, 0, mainLayer))),
      Positioned(left: w * 1, top: h * 3, child: SizedBox.square(dimension: size, child: ClipPath( clipper: SquareWithArcClipper( arcRadius: outerRadius, center: center.translate(-w * 1, -h * 3)), child: _buildTile(4, 1, mainLayer)))),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 540.0, sweepAngle: 26.5), child: _buildTile(4, 2, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 540.0, sweepAngle: 26.5), child: _buildTile(4, 2, ringLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 333.5, sweepAngle: 26.5), child: _buildTile(4, 5, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 333.5, sweepAngle: 26.5), child: _buildTile(4, 5, ringLayer)),
      Positioned(left: w * 6, top: h * 3, child: SizedBox.square(dimension: size, child: ClipPath( clipper: SquareWithArcClipper( arcRadius: outerRadius, center: center.translate(-w * 6, -h * 3)), child: _buildTile(4, 6, mainLayer)))),
      Positioned(left: w * 7, top: h * 3, child: SizedBox.square(dimension: size, child: _buildTile(4, 7, mainLayer))),
      Positioned(left: w * 0, top: h * 4, child: SizedBox.square(dimension: size, child: _buildTile(3, 0, mainLayer))),
      Positioned(left: w * 1, top: h * 4, child: SizedBox.square(dimension: size, child: ClipPath( clipper: SquareWithArcClipper( arcRadius: outerRadius, center: center.translate(-w * 1, -h * 4)), child: _buildTile(3, 1, mainLayer)))),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 513.5, sweepAngle: 26.5), child: _buildTile(3, 2, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 513.5, sweepAngle: 26.5), child: _buildTile(3, 2, ringLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 360.0, sweepAngle: 26.5), child: _buildTile(3, 5, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 360.0, sweepAngle: 26.5), child: _buildTile(3, 5, ringLayer)),
      Positioned(left: w * 6, top: h * 4, child: SizedBox.square(dimension: size, child: ClipPath( clipper: SquareWithArcClipper( arcRadius: outerRadius, center: center.translate(-w * 6, -h * 4)), child: _buildTile(3, 6, mainLayer)))),
      Positioned(left: w * 7, top: h * 4, child: SizedBox.square(dimension: size, child: _buildTile(3, 7, mainLayer))),
      Positioned(left: w * 0, top: h * 5, child: SizedBox.square(dimension: size, child: _buildTile(2, 0, mainLayer))),
      Positioned(left: w * 1, top: h * 5, child: SizedBox.square(dimension: size, child: _buildTile(2, 1, mainLayer))),
      ClipPath(clipper: WarpingCornerClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 476.5, sweepAngle: 37.0), child: _buildTile(2, 2, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 476.5, sweepAngle: 37.0), child: _buildTile(2, 2, ringLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 450.0, sweepAngle: 26.5), child: _buildTile(2, 3, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 450.0, sweepAngle: 26.5), child: _buildTile(2, 3, ringLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 423.5, sweepAngle: 26.5), child: _buildTile(2, 4, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 423.5, sweepAngle: 26.5), child: _buildTile(2, 4, ringLayer)),
      ClipPath(clipper: WarpingCornerClipper(innerRadius: innerRadius, outerRadius: outerRadius, startAngle: 386.5, sweepAngle: 37.0), child: _buildTile(2, 5, mainLayer)),
      ClipPath(clipper: RingSegmentClipper(innerRadius: voidRadius, outerRadius: innerRadius, startAngle: 386.5, sweepAngle: 37.0), child: _buildTile(2, 5, ringLayer)),
      Positioned(left: w * 6, top: h * 5, child: SizedBox.square(dimension: size, child: _buildTile(2, 6, mainLayer))),
      Positioned(left: w * 7, top: h * 5, child: SizedBox.square(dimension: size, child: _buildTile(2, 7, mainLayer))),
      Positioned(left: w * 0, top: h * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 0, mainLayer))),
      Positioned(left: w * 1, top: h * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 1, mainLayer))),
      Positioned(left: w * 2, top: h * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 2, mainLayer))),
      Positioned(left: w * 3, top: h * 6, child: SizedBox.square(dimension: size, child: ClipPath( clipper: SquareWithArcClipper( arcRadius: outerRadius, center: center.translate(-w * 3, -h * 6)), child: _buildTile(1, 3, mainLayer)))),
      Positioned(left: w * 4, top: h * 6, child: SizedBox.square(dimension: size, child: ClipPath( clipper: SquareWithArcClipper( arcRadius: outerRadius, center: center.translate(-w * 4, -h * 6)), child: _buildTile(1, 4, mainLayer)))),
      Positioned(left: w * 5, top: h * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 5, mainLayer))),
      Positioned(left: w * 6, top: h * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 6, mainLayer))),
      Positioned(left: w * 7, top: h * 6, child: SizedBox.square(dimension: size, child: _buildTile(1, 7, mainLayer))),
      Positioned(left: w * 0, top: h * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 0, mainLayer))),
      Positioned(left: w * 1, top: h * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 1, mainLayer))),
      Positioned(left: w * 2, top: h * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 2, mainLayer))),
      Positioned(left: w * 3, top: h * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 3, mainLayer))),
      Positioned(left: w * 4, top: h * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 4, mainLayer))),
      Positioned(left: w * 5, top: h * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 5, mainLayer))),
      Positioned(left: w * 6, top: h * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 6, mainLayer))),
      Positioned(left: w * 7, top: h * 7, child: SizedBox.square(dimension: size, child: _buildTile(0, 7, mainLayer))),
    ];

    return Stack(children: tiles);
  }

  Tile _buildTile(int rank, int file, int layer) {
    final pos = Position(rank, file, layer);
    return Tile(
      onTap: validMoves.contains(pos)
          ? () => movePiece(rank, file, layer)
          : () => selectPiece(rank, file, layer),
      isSelected: selected == pos,
      isValidMove: validMoves.contains(pos),
      isInvalidPawnAttack: invalidPawnAttacks.contains(pos),
      isThreatened: possibleMoves.contains(pos) &&
          !validMoves.contains(pos),
      piece: board[pos],
      isWhite: (rank + file + layer) % 2 == 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(builder: (context, constraints) => _buildTiles(context, constraints, 3, 2)),
              ),
            ),
            const SizedBox.square(dimension: 40),
            Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(builder: (context, constraints) => _buildTiles(context, constraints, 0, 1)),
              ),
            ),
          ],
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
      final (rank, file, layer) = e.key.split;
      final moves = calculateRawValidMoves(rank, file, layer, piece);
      return moves.any((pos) => pos == kingPosition);
    });
  }

  List<Position> calculatePawnAttacks(
      int rank, int file, int layer, ChessPiece pawn) {
    final direction = pawn.isWhite ? 1 : -1;
    return [Position(rank + direction, file + 1, layer), Position(rank + direction, file - 1, layer)];
  }

  List<Position> calculatePawnMoves(
      int rank, int file, int layer, ChessPiece pawn) {
    final direction = pawn.isWhite ? 1 : -1;
    final move1 = Position(rank + direction, file, layer);
    final move2 = Position(rank + direction * 2, file, layer);
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
      for (final attack in calculatePawnAttacks(rank, file, layer, pawn))
        if (canAttack(attack)) attack,
    ];
  }

  List<Position> calculateRawValidMoves(
    int rank,
    int file,
    int layer,
    ChessPiece piece,
  ) {
    List<Position> moves = switch (piece.type) {
      ChessPieceType.pawn => calculatePawnMoves(rank, file, layer, piece),
      ChessPieceType.knight => [
          Position(rank + 1, file + 2, layer),
          Position(rank + 1, file - 2, layer),
          Position(rank - 1, file + 2, layer),
          Position(rank - 1, file - 2, layer),
          Position(rank + 2, file + 1, layer),
          Position(rank + 2, file - 1, layer),
          Position(rank - 2, file + 1, layer),
          Position(rank - 2, file - 1, layer),
        ],
      ChessPieceType.king => [
          Position(rank + 1, file, layer),
          Position(rank + 1, file - 1, layer),
          Position(rank + 1, file + 1, layer),
          Position(rank - 1, file, layer),
          Position(rank - 1, file - 1, layer),
          Position(rank - 1, file + 1, layer),
          Position(rank, file - 1, layer),
          Position(rank, file + 1, layer),
          if (canCastle(rank, file, layer, piece, (r) => r, (f) => f + 1))
            Position(rank, file + 2, layer),
          if (canCastle(rank, file, layer, piece, (r) => r, (f) => f - 1))
            Position(rank, file - 2, layer),
        ],
      ChessPieceType.rook => [
          ...calculateMoves(rank, file, layer, piece, (r) => r + 1, (f) => f),
          ...calculateMoves(rank, file, layer, piece, (r) => r - 1, (f) => f),
          ...calculateMoves(rank, file, layer, piece, (r) => r, (f) => f + 1),
          ...calculateMoves(rank, file, layer, piece, (r) => r, (f) => f - 1),
        ],
      ChessPieceType.bishop => [
          ...calculateMoves(rank, file, layer, piece, (r) => r + 1, (f) => f + 1),
          ...calculateMoves(rank, file, layer, piece, (r) => r + 1, (f) => f - 1),
          ...calculateMoves(rank, file, layer, piece, (r) => r - 1, (f) => f + 1),
          ...calculateMoves(rank, file, layer, piece, (r) => r - 1, (f) => f - 1),
        ],
      ChessPieceType.queen => [
          ...calculateMoves(rank, file, layer, piece, (r) => r + 1, (f) => f),
          ...calculateMoves(rank, file, layer, piece, (r) => r - 1, (f) => f),
          ...calculateMoves(rank, file, layer, piece, (r) => r, (f) => f + 1),
          ...calculateMoves(rank, file, layer, piece, (r) => r, (f) => f - 1),
          ...calculateMoves(rank, file, layer, piece, (r) => r + 1, (f) => f + 1),
          ...calculateMoves(rank, file, layer, piece, (r) => r + 1, (f) => f - 1),
          ...calculateMoves(rank, file, layer, piece, (r) => r - 1, (f) => f + 1),
          ...calculateMoves(rank, file, layer, piece, (r) => r - 1, (f) => f - 1),
        ],
    };
    moves.removeWhere((pos) =>
    !pos.inBoard || _board[pos]?.isWhite == piece.isWhite);
    return moves;
  }

  List<Position> calculateMoves(
    int rank,
    int file,
    int layer,
    ChessPiece piece,
    int Function(int) nextRank,
    int Function(int) nextFile,
  ) {
    List<Position> moves = [];
    while (true) {
      rank = nextRank(rank);
      file = nextFile(file);
      final pos = Position(rank, file, layer);
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
    int layer,
    ChessPiece king,
    int Function(int) nextRank,
    int Function(int) nextFile,
  ) {
    if (king.firstMoved != null) return false;
    while (true) {
      rank = nextRank(rank);
      file = nextFile(file);
      final pos = Position(rank, file, layer);
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
      int rank, int file, int layer, ChessPiece piece) {
    return [
      for (final move in calculateRawValidMoves(rank, file, layer, piece))
        if (!movePiece(Position(rank, file, layer), move).isKingInCheck(piece.isWhite)) move,
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
        next[Position(from.rank, from.file + dif ~/ 2, from.layer)] = rook.firstMoved == null
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
  final double arcRadius;
  final Offset center;

  SquareWithArcClipper({
    required this.arcRadius,
    required this.center,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    final (w, h) = (size.width, size.height);

    if (center.dx < 0) {
      if (center.dy > 0) {
        path.moveTo(0, 0);
        path.arcToPoint(Offset(center.dx + arcRadius, h), radius: Radius.circular(arcRadius));
        path.lineTo(w, h);
        path.lineTo(w, 0);
        path.lineTo(0, 0);
      } else {
        path.moveTo(center.dx + arcRadius, 0);
        path.arcToPoint(Offset(0, h), radius: Radius.circular(arcRadius));
        path.lineTo(w, h);
        path.lineTo(w, 0);
        path.lineTo(center.dx + arcRadius, 0);
      }
    } else if (center.dy < 0) {
      if (center.dx > 0) {
        path.moveTo(0, 0);
        path.lineTo(0, h);
        path.lineTo(w, h);
        path.lineTo(w, center.dy + arcRadius);
        path.arcToPoint(const Offset(0, 0), radius: Radius.circular(arcRadius));
      } else {
        path.moveTo(0, center.dy + arcRadius);
        path.lineTo(0, h);
        path.lineTo(w, h);
        path.lineTo(w, 0);
        path.arcToPoint(Offset(0, center.dy + arcRadius), radius: Radius.circular(arcRadius));
      }
    } else if (center.dx == 0) {
      path.moveTo(0, 0);
      path.lineTo(0, center.dy - arcRadius);
      path.arcToPoint(Offset(w, h), radius: Radius.circular(arcRadius));
      path.lineTo(w, 0);
      path.lineTo(0, 0);
    } else if (center.dy == 0) {
      path.moveTo(0, 0);
      path.lineTo(0, h);
      path.lineTo(w, h);
      path.arcToPoint(Offset(center.dx - arcRadius, 0), radius: Radius.circular(arcRadius));
      path.lineTo(0, 0);
    } else if (center.dx < center.dy) {
      path.moveTo(0, 0);
      path.lineTo(0, h);
      path.arcToPoint(Offset(w, center.dy - arcRadius), radius: Radius.circular(arcRadius));
      path.lineTo(w, 0);
      path.lineTo(0, 0);
    } else {
      path.moveTo(0, 0);
      path.lineTo(0, h);
      path.lineTo(center.dx - arcRadius, h);
      path.arcToPoint(Offset(w, 0), radius: Radius.circular(arcRadius));
      path.lineTo(0, 0);
    }
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
