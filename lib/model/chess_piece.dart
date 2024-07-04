import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'direction.dart';

enum ChessPieceType {
  pawn(10, FontAwesomeIcons.solidChessPawn),
  rook(50, FontAwesomeIcons.solidChessRook),
  knight(30, FontAwesomeIcons.solidChessKnight),
  bishop(30, FontAwesomeIcons.solidChessBishop),
  queen(100, FontAwesomeIcons.solidChessQueen),
  king(1000, FontAwesomeIcons.solidChessKing);

  final int value;
  final IconData icon;

  const ChessPieceType(this.value, this.icon);
}

enum Player { white, black, amber, purple }

class ChessPiece {
  final ChessPieceType type;
  final Player player;
  final String imagePath;
  final int? firstMoved;
  final Direction direction;

  ChessPiece({
    required this.type,
    required this.player,
    required this.direction,
    this.firstMoved,
  }) : imagePath = 'assets/${player.name}/${type.name}.svg';

  ChessPiece.from({
    required ChessPiece from,
    ChessPieceType? type,
    Direction? direction,
    int? firstMoved,
  }) : this(
    type: type ?? from.type,
    player: from.player,
    firstMoved: firstMoved ?? from.firstMoved,
    direction: direction ?? from.direction,
  );
}