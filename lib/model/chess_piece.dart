import 'direction.dart';

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