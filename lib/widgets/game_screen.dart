import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wormhole_chess/service/game_service.dart';
import 'package:wormhole_chess/widgets/tile.dart';

import '../model/chess_piece.dart';
import '../model/direction.dart';
import '../model/game_board.dart';
import '../model/position.dart';

class GameScreen extends StatefulWidget {
  final String? gameId;
  const GameScreen({super.key, this.gameId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameBoard board = GameBoard.empty();

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
            for (final attack in GameBoard.getPawnAttacks(pos, piece))
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
    final dir = possibleMoves[to];
    if (selected == null || dir == null) return; // TODO: error
    final next = board.movePiece(selected!, to, dir);
    setState(() {
      board = next;
      selected = null;
      validMoves = [];
      possibleMoves = {};
      invalidPawnAttacks = [];
      // TODO: Do something with check
      if (board.isKingInCheck(Player.white)) {
        print("White in check");
      }
      if (board.isKingInCheck(Player.black)) {
        print("Black in check");
      }
    });
    GameService().movePiece(widget.gameId, next.moves.last, next.player);
  }

  void selectStart(Position pos) {
    // TODO: Move this logic out of the UI
    final startPos = {...board.startPos, board.player: pos};
    final possibleStart = GameBoard.getPossibleStarts(startPos.values);
    if (possibleStart.length == 1) {
      startPos[Player.amber] = possibleStart.first;
    }
    final next = GameBoard.build(
      mode: board.mode,
      startPos: startPos,
      player: board.player == Player.purple ? Player.black : Player.white,
    );
    setState(() => board = next);
    GameService().updateStartPos(widget.gameId, next);
  }

  Widget _buildTiles(BuildContext context, BoxConstraints constraints, int planeLayer, int ringLayer) {
    // TODO: Should already be a square, due to having [AspectRatio] as the parent, but additional enforcement may be prudent
    final size = constraints.maxHeight / 8;

    final outerRadius = size * sqrt(5);
    final innerRadius = size * sqrt(2.5);
    final voidRadius = size;
    final sqrt_2 = sqrt(0.2);
    final sqrt_8 = sqrt_2 * 2;

    final possibleStarts = board.possibleStarts;

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
            onTap: board.isStarted
                ? validMoves.contains(pos) &&
                        board[selected]?.player == board.player
                    ? () => movePiece(pos)
                    : () => selectPiece(pos)
                : possibleStarts.contains(pos)
                    ? () => selectStart(pos)
                    : () => {},
            isSelected: selected == pos,
            isValidMove: board.isStarted
                ? validMoves.contains(pos)
                : possibleStarts.contains(pos),
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
        child: StreamBuilder<GameBoard?>(
          stream: GameService().streamGame(widget.gameId),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.stackTrace);
            if (snapshot.hasData && snapshot.data != null) board = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text("${board.player.name}'s Turn"),
                Flexible(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: LayoutBuilder(builder: (context, constraints) => _buildTiles(context, constraints, 3, 2)),
                    ),
                  ),
                ),
                const SizedBox.square(dimension: 20),
                Flexible(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: LayoutBuilder(builder: (context, constraints) => _buildTiles(context, constraints, 0, 1)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }
        ),
      ),
    );
  }
}
