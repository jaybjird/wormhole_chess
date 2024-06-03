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

  Direction right([int i = 1]) => i < 0 ? left(-i) : Direction.values[(index + i) % 8];
  Direction left([int i = 1]) => i <  0 ? right(-i) : Direction.values[(8 + index - i) % 8];
  bool get isCardinal => index % 2 == 0;

  int dif(Direction other) {
    int dif = other.index - index;

    if (dif > 4) return dif - 8;
    if (dif < -3) return dif + 8;
    return dif;
  }
}

class Position {
  final int rank, file, layer; // TODO: rank and file are being used backwards
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
        }?.right(layer < 2 ? 0 : 4); // Invert if on a reverse layer

  @override
  String toString() => 'Position{rank: $rank, file: $file, layer: $layer}';

  /// Calculating the diagonal in a single pass is hard.
  /// Calculate the neighboring cardinal directions instead, and find where
  /// they converge
  List<(Position, Direction)> nextDiagonal(Direction dir) {
    final d = diagonals;
    final i = d.indexOf(dir);

    final c = cardinals;
    var left = dir.left();
    var right = dir.right();

    if (c.length == 4) {
      return [converge(_nextPos(left), _nextPos(right), dir)];
    }

    if (!c.contains(left)) left = dir;
    if (!c.contains(right)) right = dir;

    final leftPos = _nextPos(i > 0 ? d[i - 1] : d.last);
    final centerPos = _nextPos(dir);
    final rightPos = _nextPos(d[(i + 1) % d.length]);
    return [
      converge(leftPos, centerPos, left),
      converge(centerPos, rightPos, right),
    ];
  }

  (Position, Direction) converge(Position left, Position right, Direction dir) {
    final to = Position(
      left.rank + right.rank - rank,
      left.file + right.file - file,
      left.layer + right.layer - layer,
    );
    return (to, nextHeading(to, dir));
  }

  Direction nextHeading(Position to, Direction dir) {
    if (_ringSide == null || to._ringSide == null) return dir;
    final dif = to._ringSide.dif(_ringSide);
    final flip = layer < 2 != to.layer < 2;
    return switch((dif, flip, dir.dif(_ringSide))) {
      (4, true, 3) => dir.left(2),
      (4, true, -3) => dir.right(2),
      (-3 || 3, true, _) => dir.right(dif),
      (-1 || 3, _, _) => dir.right(),
      (1 || -3, _, _) => dir.left(),
      _ => dir
    };
  }

  List<(Position, Direction)> nextCardinal(Direction dir) {
    final d = diagonals;
    if (d.length == 4) return [_nextPair(dir)];

    var left = dir.left();
    if (!d.contains(left)) left = dir;

    var right = dir.right();
    if (!d.contains(right)) right = dir;

    return [_nextPair(left), _nextPair(right)];
  }

  (Position, Direction) _nextPair(Direction dir) {
    final to = _nextPos(dir);
    return (to, nextHeading(to, dir));
  }

  Position _nextPos(Direction dir) {
    final mod = layer < 2 ? 1 : -1;
    return switch ((dir, _ringSide?.dif(dir), layer)) {
      (_, 4, _) => Position(rank, file, layer + mod),
      (_, 0, 1) || (_, 0, 2) => Position(rank, file, layer - mod),
      (Direction.north, _, _) => Position(rank + mod, file, layer),
      (Direction.south, _, _) => Position(rank - mod, file, layer),
      (Direction.east, _, _) => Position(rank, file + mod, layer),
      (Direction.west, _, _) => Position(rank, file - mod, layer),
      (_, 2, _) => _nextPos(dir.right()),
      (_, -2, _) => _nextPos(dir.left()),
      _ => this, // TODO: error
    };
  }

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

  List<Direction> get diagonals {
    final directions = [
      Direction.northeast,
      Direction.southeast,
      Direction.southwest,
      Direction.northwest,
    ];
    if (_ringSide == null || _ringSide.isCardinal) return directions;
    if (layer == 1 || layer == 2) {
      return [
        Direction.north,
        Direction.east,
        Direction.south,
        Direction.west,
      ];
    }
    if (layer == 0 || layer == 3) {
      final index = directions.indexOf(_ringSide);
      directions[index] = _ringSide.right();
      directions.insert(index, _ringSide.left());
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

  Map<Position, Direction> possibleMoves = {};
  List<Position> validMoves = [], invalidPawnAttacks = [];

  void selectPiece(int rank, int file, int layer) {
    setState(() {
      final pos = Position(rank, file, layer);
      final piece = board[pos];
      if (piece != null) {
        selected = pos;
        // TODO: Currently calls [calculateRawValidMoves] twice. Consider optimizing this
        possibleMoves = board.getRawValidMoves(pos, piece);
        validMoves = board.getRealValidMoves(pos, piece);
        invalidPawnAttacks = [
          if (piece.type == ChessPieceType.pawn)
            for (final attack in board.getPawnAttacks(pos, piece))
              if (!validMoves.contains(attack)) attack.$1,
        ];
      } else {
        selected = null;
        validMoves = [];
        possibleMoves = {};
        invalidPawnAttacks = [];
      }
    });
  }

  void movePiece(int rank, int file, int layer) {
    setState(() {
      final to = Position(rank, file, layer);
      final dir = possibleMoves[to];
      if (selected != null && dir != null) {
        board = board.movePiece(selected!, to, dir);
      } else {
        // TODO: error
      }
      selected = null;
      validMoves = [];
      possibleMoves = {};
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
      isThreatened: possibleMoves.containsKey(pos) &&
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
      ...getPawnAttacks(pos, pawn)
          .where((move) => _board[move.$1]?.isWhite == !pawn.isWhite),
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
      if (!pos.inBoard || _board[pos]?.isWhite == piece.isWhite) continue;
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
            piece.isWhite == king.isWhite;
      }
    }
  }

  List<Position> getRealValidMoves(Position pos, ChessPiece piece) {
    return [
      for (final move in getRawValidMoves(pos, piece).entries)
        if (!movePiece(pos, move.key, move.value).isKingInCheck(piece.isWhite))
          move.key,
    ];
  }

  /// Returns a new [GameBoard] where the [ChessPiece] at position [from] is moved to position [to] facing the given [Direction].
  GameBoard movePiece(Position from, Position to, Direction dir) {
    print("movePiece $dir");
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
  final Direction direction;

  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.direction,
    this.firstMoved,
  }) : imagePath = 'assets/${isWhite ? 'white' : 'black'}/${type.name}.svg';

  ChessPiece.from({
    required ChessPiece from,
    ChessPieceType? type,
    Direction? direction,
    int? firstMoved,
  }) : this(
          type: type ?? from.type,
          isWhite: from.isWhite,
          firstMoved: firstMoved ?? from.firstMoved,
          direction: direction ?? from.direction,
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
