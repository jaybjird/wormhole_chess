import 'direction.dart';

enum ChessPieceType {
  pawn(10),
  rook(50),
  knight(30),
  bishop(30),
  queen(100),
  king(1000);

  final int value;

  const ChessPieceType(this.value);
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