import 'package:flutter/material.dart';
import 'package:wormhole_chess/widgets/tile.dart';
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

  void selectPiece(Position pos) {
    setState(() {
      print("selectPiece $pos");
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

  void movePiece(Position to) {
    setState(() {
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

  Widget _buildTiles(BuildContext context, BoxConstraints constraints, int planeLayer, int ringLayer) {
    // TODO: Should already be a square, due to having [AspectRatio] as the parent, but additional enforcement may be prudent
    final size = constraints.maxHeight / 8;

    final outerRadius = size * sqrt(5);
    final innerRadius = size * sqrt(2.5);
    final voidRadius = size;
    final sqrt_2 = sqrt(0.2);
    final sqrt_8 = sqrt_2 * 2;

    List<Widget> tiles = [];
    for (final layer in [planeLayer, ringLayer]) {
      for (int x = 0; x < 8; ++x) {
        for (int y = 0; y < 8; ++y) {
          final pos = Position(7 - y, x, layer);
          if (!pos.inBoard) continue;
          final baseRect = Rect.fromLTWH(x * size, y * size, size, size);
          final tilePath = switch((x, y, layer == planeLayer)) {
            (1, 3, true) => TilePath(
              outerStart: baseRect.bottomLeft,
              outerEnd: baseRect.topLeft,
              innerStart: baseRect.topRight,
              innerEnd: Offset(4 * size - outerRadius, baseRect.bottom),
              innerRadius: outerRadius,
            ),
            (1, 4, true) => TilePath(
              outerStart: baseRect.bottomLeft,
              outerEnd: baseRect.topLeft,
              innerStart: Offset(4 * size - outerRadius, baseRect.top),
              innerEnd: baseRect.bottomRight,
              innerRadius: outerRadius,
            ),
            (2, 2, true) => TilePath(
              outerStart: baseRect.bottomLeft,
              outerCorner: baseRect.topLeft,
              outerEnd: baseRect.topRight,
              innerStart: Offset((4 - sqrt1_2) * size, (4 - sqrt2) * size),
              innerEnd: Offset((4 - sqrt2) * size, (4 - sqrt1_2) * size),
              innerRadius: innerRadius,
            ),
            (2, 3, true) => TilePath(
              outerStart: Offset(4 * size - outerRadius, baseRect.bottom),
              outerEnd: baseRect.topLeft,
              innerStart: Offset((4 - sqrt2) * size, (4 - sqrt1_2) * size),
              innerEnd: Offset(4 * size - innerRadius, baseRect.bottom),
              outerRadius: outerRadius,
              innerRadius: innerRadius,
            ),
            (2, 4, true) => TilePath(
              outerStart: baseRect.bottomLeft,
              outerEnd: Offset(4 * size - outerRadius, baseRect.top),
              innerStart: Offset(4 * size - innerRadius, baseRect.top),
              innerEnd: Offset((4 - sqrt2) * size, (4 + sqrt1_2) * size),
              outerRadius: outerRadius,
              innerRadius: innerRadius,
            ),
            (2, 5, true) => TilePath(
              outerStart: baseRect.bottomRight,
              outerCorner: baseRect.bottomLeft,
              outerEnd: baseRect.topLeft,
              innerStart: Offset((4 - sqrt2) * size, (4 + sqrt1_2) * size),
              innerEnd: Offset((4 - sqrt1_2) * size, (4 + sqrt2) * size),
              innerRadius: innerRadius,
            ),
            (3, 1, true) => TilePath(
              outerStart: baseRect.topLeft,
              outerEnd: baseRect.topRight,
              innerStart: Offset(baseRect.right, 4 * size - outerRadius),
              innerEnd: baseRect.bottomLeft,
              innerRadius: outerRadius,
            ),
            (3, 2, true) => TilePath(
              outerStart: baseRect.topLeft,
              outerEnd: Offset(baseRect.right, 4 * size - outerRadius),
              innerStart: Offset(baseRect.right, 4 * size - innerRadius),
              innerEnd: Offset((4 - sqrt1_2) * size, (4 - sqrt2) * size),
              outerRadius: outerRadius,
              innerRadius: innerRadius,
            ),
            (3, 5, true) => TilePath(
              outerStart: Offset(baseRect.right, 4 * size + outerRadius),
              outerEnd: baseRect.bottomLeft,
              innerStart: Offset((4 - sqrt1_2) * size, (4 + sqrt2) * size),
              innerEnd: Offset(baseRect.right, 4 * size + innerRadius),
              outerRadius: outerRadius,
              innerRadius: innerRadius,
            ),
            (3, 6, true) => TilePath(
              outerStart: baseRect.bottomRight,
              outerEnd: baseRect.bottomLeft,
              innerStart: baseRect.topLeft,
              innerEnd: Offset(baseRect.right, 4 * size + outerRadius),
              innerRadius: outerRadius,
            ),
            (4, 1, true) => TilePath(
              outerStart: baseRect.topLeft,
              outerEnd: baseRect.topRight,
              innerStart: baseRect.bottomRight,
              innerEnd: Offset(baseRect.left, 4 * size - outerRadius),
              innerRadius: outerRadius,
            ),
            (4, 2, true) => TilePath(
              outerStart: Offset(baseRect.left, 4 * size - outerRadius),
              outerEnd: baseRect.topRight,
              innerStart: Offset((4 + sqrt1_2) * size, (4 - sqrt2) * size),
              innerEnd: Offset(baseRect.left, 4 * size - innerRadius),
              outerRadius: outerRadius,
              innerRadius: innerRadius,
            ),
            (4, 5, true) => TilePath(
              outerStart: baseRect.bottomRight,
              outerEnd: Offset(baseRect.left, 4 * size + outerRadius),
              innerStart: Offset(baseRect.left, 4 * size + innerRadius),
              innerEnd:  Offset((4 + sqrt1_2) * size, (4 + sqrt2) * size),
              outerRadius: outerRadius,
              innerRadius: innerRadius,
            ),
            (4, 6, true) => TilePath(
              outerStart: baseRect.bottomRight,
              outerEnd: baseRect.bottomLeft,
              innerStart: Offset(baseRect.left, 4 * size + outerRadius),
              innerEnd: baseRect.topRight,
              innerRadius: outerRadius,
            ),
            (5, 2, true) => TilePath(
              outerStart: baseRect.topLeft,
              outerCorner: baseRect.topRight,
              outerEnd: baseRect.bottomRight,
              innerStart: Offset((4 + sqrt2) * size, (4 - sqrt1_2) * size),
              innerEnd: Offset((4 + sqrt1_2) * size, (4 - sqrt2) * size),
              innerRadius: innerRadius,
            ),
            (5, 3, true) => TilePath(
              outerStart: baseRect.topRight,
              outerEnd: Offset(4 * size + outerRadius, baseRect.bottom),
              innerStart: Offset(4 * size + innerRadius, baseRect.bottom),
              innerEnd: Offset((4 + sqrt2) * size, (4 - sqrt1_2) * size),
              outerRadius: outerRadius,
              innerRadius: innerRadius,
            ),
            (5, 4, true) => TilePath(
              outerStart: Offset(4 * size + outerRadius, baseRect.top),
              outerEnd: baseRect.bottomRight,
              innerStart: Offset((4 + sqrt2) * size, (4 + sqrt1_2) * size),
              innerEnd: Offset(4 * size + innerRadius, baseRect.top),
              outerRadius: outerRadius,
              innerRadius: innerRadius,
            ),
            (5, 5, true) => TilePath(
              outerStart: baseRect.topRight,
              outerCorner: baseRect.bottomRight,
              outerEnd: baseRect.bottomLeft,
              innerStart: Offset((4 + sqrt1_2) * size, (4 + sqrt2) * size),
              innerEnd: Offset((4 + sqrt2) * size, (4 + sqrt1_2) * size),
              innerRadius: innerRadius,
            ),
            (6, 3, true) => TilePath(
              outerStart: baseRect.topRight,
              outerEnd: baseRect.bottomRight,
              innerStart: Offset(4 * size + outerRadius, baseRect.bottom),
              innerEnd: baseRect.topLeft,
              innerRadius: outerRadius,
            ),
            (6, 4, true) => TilePath(
              outerStart: baseRect.topRight,
              outerEnd: baseRect.bottomRight,
              innerStart: baseRect.bottomLeft,
              innerEnd: Offset(4 * size + outerRadius, baseRect.top),
              innerRadius: outerRadius,
            ),
            (2, 2, false) => TilePath(
              outerStart: Offset((4 - sqrt2) * size, (4 - sqrt1_2) * size),
              outerEnd: Offset((4 - sqrt1_2) * size, (4 - sqrt2) * size),
              innerStart: Offset((4 - sqrt_2) * size, (4 - sqrt_8) * size),
              innerEnd: Offset((4 - sqrt_8) * size, (4 - sqrt_2) * size),
              outerRadius: innerRadius,
              innerRadius: voidRadius,
            ),
            (2, 3, false) => TilePath(
              outerStart: Offset(4 * size - innerRadius, baseRect.bottom),
              outerEnd: Offset((4 - sqrt2) * size, (4 - sqrt1_2) * size),
              innerStart: Offset((4 - sqrt_8) * size, (4 - sqrt_2) * size),
              innerEnd: Offset(4 * size - voidRadius, baseRect.bottom),
              outerRadius: innerRadius,
              innerRadius: voidRadius,
            ),
            (2, 4, false) => TilePath(
              outerStart: Offset((4 - sqrt2) * size, (4 + sqrt1_2) * size),
              outerEnd: Offset(4 * size - innerRadius, baseRect.top),
              innerStart: Offset(4 * size - voidRadius, baseRect.top),
              innerEnd: Offset((4 - sqrt_8) * size, (4 + sqrt_2) * size),
              outerRadius: innerRadius,
              innerRadius: voidRadius,
            ),
            (2, 5, false) => TilePath(
              outerStart: Offset((4 - sqrt1_2) * size, (4 + sqrt2) * size),
              outerEnd: Offset((4 - sqrt2) * size, (4 + sqrt1_2) * size),
              innerStart: Offset((4 - sqrt_8) * size, (4 + sqrt_2) * size),
              innerEnd: Offset((4 - sqrt_2) * size, (4 + sqrt_8) * size),
              outerRadius: innerRadius,
              innerRadius: voidRadius,
            ),
            (3, 2, false) => TilePath(
              outerStart: Offset((4 - sqrt1_2) * size, (4 - sqrt2) * size),
              outerEnd: Offset(baseRect.right, 4 * size - innerRadius),
              innerStart: Offset(baseRect.right, 4 * size - voidRadius),
              innerEnd: Offset((4 - sqrt_2) * size, (4 - sqrt_8) * size),
              outerRadius: innerRadius,
              innerRadius: voidRadius,
            ),
            (3, 5, false) => TilePath(
              outerStart: Offset(baseRect.right, 4 * size + innerRadius),
              outerEnd: Offset((4 - sqrt1_2) * size, (4 + sqrt2) * size),
              innerStart: Offset((4 - sqrt_2) * size, (4 + sqrt_8) * size),
              innerEnd: Offset(baseRect.right, 4 * size + voidRadius),
              outerRadius: innerRadius,
              innerRadius: voidRadius,
            ),
            (4, 2, false) => TilePath(
              outerStart: Offset(baseRect.left, 4 * size - innerRadius),
              outerEnd: Offset((4 + sqrt1_2) * size, (4 - sqrt2) * size),
              innerStart: Offset((4 + sqrt_2) * size, (4 - sqrt_8) * size),
              innerEnd: Offset(baseRect.left, 4 * size - voidRadius),
              outerRadius: outerRadius,
              innerRadius: innerRadius,
            ),
            (4, 5, false) => TilePath(
              outerStart: Offset((4 + sqrt1_2) * size, (4 + sqrt2) * size),
              outerEnd: Offset(baseRect.left, 4 * size + innerRadius),
              innerStart: Offset(baseRect.left, 4 * size + voidRadius),
              innerEnd: Offset((4 + sqrt_2) * size, (4 + sqrt_8) * size),
              outerRadius: innerRadius,
              innerRadius: voidRadius,
            ),
            (5, 2, false) => TilePath(
              outerStart: Offset((4 + sqrt1_2) * size, (4 - sqrt2) * size),
              outerEnd: Offset((4 + sqrt2) * size, (4 - sqrt1_2) * size),
              innerStart: Offset((4 + sqrt_8) * size, (4 - sqrt_2) * size),
              innerEnd: Offset((4 + sqrt_2) * size, (4 - sqrt_8) * size),
              outerRadius: innerRadius,
              innerRadius: voidRadius,
            ),
            (5, 3, false) => TilePath(
              outerStart: Offset((4 + sqrt2) * size, (4 - sqrt1_2) * size),
              outerEnd: Offset(4 * size + innerRadius, baseRect.bottom),
              innerStart: Offset(4 * size + voidRadius, baseRect.bottom),
              innerEnd: Offset((4 + sqrt_8) * size, (4 - sqrt_2) * size),
              outerRadius: innerRadius,
              innerRadius: voidRadius,
            ),
            (5, 4, false) => TilePath(
              outerStart: Offset(4 * size + innerRadius, baseRect.top),
              outerEnd: Offset((4 + sqrt2) * size, (4 + sqrt1_2) * size),
              innerStart: Offset((4 + sqrt_8) * size, (4 + sqrt_2) * size),
              innerEnd: Offset(4 * size + voidRadius, baseRect.top),
              outerRadius: innerRadius,
              innerRadius: voidRadius,
            ),
            (5, 5, false) => TilePath(
              outerStart: Offset((4 + sqrt2) * size, (4 + sqrt1_2) * size),
              outerEnd: Offset((4 + sqrt1_2) * size, (4 + sqrt2) * size),
              innerStart: Offset((4 + sqrt_2) * size, (4 + sqrt_8) * size),
              innerEnd: Offset((4 + sqrt_8) * size, (4 + sqrt_2) * size),
              outerRadius: innerRadius,
              innerRadius: voidRadius,
            ),
            _ => TilePath(
                outerStart: baseRect.topLeft,
                outerEnd: baseRect.topRight,
                innerStart: baseRect.bottomRight,
                innerEnd: baseRect.bottomLeft,
              ),
          };
          final tile = Tile(
            path: tilePath,
            onTap: validMoves.contains(pos)
                ? () => movePiece(pos)
                : () => selectPiece(pos),
            isSelected: selected == pos,
            isValidMove: validMoves.contains(pos),
            isInvalidPawnAttack: invalidPawnAttacks.contains(pos),
            isThreatened: possibleMoves.containsKey(pos) &&
                !validMoves.contains(pos),
            piece: board[pos],
            isWhite: pos.isWhite,
          );
          tiles.add(tile);
        }
      }
    }

    return Stack(children: tiles);
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
