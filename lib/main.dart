import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

import 'model/chess_piece.dart';
import 'model/direction.dart';
import 'model/game_board.dart';
import 'model/position.dart';


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
    Position(1, 0, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn, direction: Direction.north),
    Position(1, 1, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn, direction: Direction.north),
    Position(1, 2, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn, direction: Direction.north),
    Position(1, 3, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn, direction: Direction.north),
    Position(1, 4, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn, direction: Direction.north),
    Position(1, 5, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn, direction: Direction.north),
    Position(1, 6, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn, direction: Direction.north),
    Position(1, 7, 0): ChessPiece(isWhite: true, type: ChessPieceType.pawn, direction: Direction.north),


    Position(0, 0, 0): ChessPiece(isWhite: true, type: ChessPieceType.rook, direction: Direction.north),
    Position(0, 1, 0): ChessPiece(isWhite: true, type: ChessPieceType.knight, direction: Direction.north),
    Position(0, 2, 0): ChessPiece(isWhite: true, type: ChessPieceType.bishop, direction: Direction.north),
    Position(0, 3, 0): ChessPiece(isWhite: true, type: ChessPieceType.queen, direction: Direction.north),
    Position(0, 4, 0): ChessPiece(isWhite: true, type: ChessPieceType.king, direction: Direction.north),
    Position(0, 5, 0): ChessPiece(isWhite: true, type: ChessPieceType.bishop, direction: Direction.north),
    Position(0, 6, 0): ChessPiece(isWhite: true, type: ChessPieceType.knight, direction: Direction.north),
    Position(0, 7, 0): ChessPiece(isWhite: true, type: ChessPieceType.rook, direction: Direction.north),

    Position(6, 0, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn, direction: Direction.south),
    Position(6, 1, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn, direction: Direction.south),
    Position(6, 2, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn, direction: Direction.south),
    Position(6, 3, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn, direction: Direction.south),
    Position(6, 4, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn, direction: Direction.south),
    Position(6, 5, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn, direction: Direction.south),
    Position(6, 6, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn, direction: Direction.south),
    Position(6, 7, 0): ChessPiece(isWhite: false, type: ChessPieceType.pawn, direction: Direction.south),
    Position(7, 0, 0): ChessPiece(isWhite: false, type: ChessPieceType.rook, direction: Direction.south),
    Position(7, 1, 0): ChessPiece(isWhite: false, type: ChessPieceType.knight, direction: Direction.south),
    Position(7, 2, 0): ChessPiece(isWhite: false, type: ChessPieceType.bishop, direction: Direction.south),
    Position(7, 3, 0): ChessPiece(isWhite: false, type: ChessPieceType.queen, direction: Direction.south),
    Position(7, 4, 0): ChessPiece(isWhite: false, type: ChessPieceType.king, direction: Direction.south),
    Position(7, 5, 0): ChessPiece(isWhite: false, type: ChessPieceType.bishop, direction: Direction.south),
    Position(7, 6, 0): ChessPiece(isWhite: false, type: ChessPieceType.knight, direction: Direction.south),
    Position(7, 7, 0): ChessPiece(isWhite: false, type: ChessPieceType.rook, direction: Direction.south),
  });

  Position? selected;

  Map<Position, Direction> possibleMoves = {};
  List<Position> validMoves = [], invalidPawnAttacks = [];

  void selectPiece(int rank, int file, int layer) {
    setState(() {
      final pos = Position(rank, file, layer);
      final piece = board[pos];
      if (piece != null && pos != selected) {
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
