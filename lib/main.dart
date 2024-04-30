import 'dart:io';

class Position {
  Position(this.rank, this.file);
  final int rank, file;

  get outBounds => rank < 0 || rank > 7 || file < 0 || file > 7;

  @override
  toString() => String.fromCharCodes([file + 97, rank + 49]);

  @override
  bool operator ==(Object other) {
    return other is Position && other.rank == rank && other.file == file;
  }

  @override
  int get hashCode {
    return rank.hashCode ^ file.hashCode;
  }
}

enum PieceType {
  pawn(noMoves),
  rook(noMoves),
  knight(noMoves),
  bishop(noMoves),
  queen(noMoves),
  king(noMoves);

  const PieceType(this.getMoves);
  final List<Position> Function(ChessPiece) getMoves;
}

List<Position> noMoves(ChessPiece piece) => [];

enum Orientation {
  north, // ^
  south, // v
  east,  // >
  west,  // <
}

enum Player {
  white,
  black,
  purple,
  amber;
}

class ChessPiece {
  ChessPiece({
    required this.type,
    required this.player,
    required this.facing,
    required this.position,
    this.turnMoved = 0,
  });
  PieceType type;
  final Player player;
  Orientation facing;
  Position position;
  int turnMoved;

}

PieceType? getType(int i, int j) {
  if (i == 1 || i == 6) return PieceType.pawn;
  if (i != 0 && i != 7) return null;
  if (j == 0 || j == 7) return PieceType.rook;
  //if (j == 1 || j == 6) return PieceType.knight;
  //if (j == 3) return PieceType.queen;
  if (j == 4) return PieceType.king;
  //if (j == 2 || j == 5) return PieceType.bishop;
  return null;
}

var board = List<List<ChessPiece?>>.generate(8, (i) => List<ChessPiece?>.generate(8, (j) {
  final type = getType(i, j);
  return type == null ? null : ChessPiece(
    type: type,
    player: i > 4 ? Player.black : Player.white,
    facing: i > 4 ? Orientation.south : Orientation.north,
    position: Position(i, j),
  );
}));

void printBoard() {
  String s = "   a b c d e f g h\n";
  for (int i = 8; i-- > 0;) {
    s += "${i+1}  ";
    for (int j = 0; j < 8; ++j) {
      final piece = board[i][j];
      if (piece != null) {
        var c = piece.type.name[0];
        if (piece.type == PieceType.knight) {
          c = 'n';
        }
        if (piece.player == Player.white) {
          c = c.toUpperCase();
        }
        s += c;
      } else {
        s += (i + j) % 2 == 0 ? 'B' : 'W';
      }
      s += ' ';
    }
    s += "\n";
  }
  s += "\n   a b c d e f g h\n";
  print(s);
}

enum Action {move, attack, both, castle}

Map<Position, Action> getMoves(Position pos) {
  if (pos.outBounds) return {};
  final piece = board[pos.rank][pos.file];
  if (piece == null) return {};
  Map<Position, Action> moves = {};
  switch (piece.type) {
    case PieceType.pawn:
      final dir = piece.facing == Orientation.north ? 1 : -1;
      moves[Position(pos.rank + dir, pos.file)] = Action.move;
      if (piece.turnMoved < 1) moves[Position(pos.rank + dir * 2, pos.file)] = Action.move;
      moves[Position(pos.rank + dir, pos.file + 1)] = Action.attack;
      moves[Position(pos.rank + dir, pos.file - 1)] = Action.attack;
  // TODO: en passant
    case PieceType.knight:
      moves[Position(pos.rank + 2, pos.file + 1)] = Action.both;
      moves[Position(pos.rank + 2, pos.file - 1)] = Action.both;
      moves[Position(pos.rank - 2, pos.file + 1)] = Action.both;
      moves[Position(pos.rank - 2, pos.file - 1)] = Action.both;
      moves[Position(pos.rank + 1, pos.file + 2)] = Action.both;
      moves[Position(pos.rank + 1, pos.file - 2)] = Action.both;
      moves[Position(pos.rank - 1, pos.file + 2)] = Action.both;
      moves[Position(pos.rank - 1, pos.file - 2)] = Action.both;
    case PieceType.bishop:
      for (int r = pos.rank, f = pos.file; r++ < 7 && f++ < 7;) {
        moves[Position(r, f)] = Action.both;
        if (board[r][f] != null) break;
      }
      for (int r = pos.rank, f = pos.file; r-- > 0 && f++ < 7;) {
        moves[Position(r, f)] = Action.both;
        if (board[r][f] != null) break;
      }
      for (int r = pos.rank, f = pos.file; r++ < 7 && f-- > 0;) {
        moves[Position(r, f)] = Action.both;
        if (board[r][f] != null) break;
      }
      for (int r = pos.rank, f = pos.file; r-- < 0 && f-- > 0;) {
        moves[Position(r, f)] = Action.both;
        if (board[r][f] != null) break;
      }
    case PieceType.rook:
      for (int r = pos.rank; r++ < 7;) {
        moves[Position(r, pos.file)] = Action.both;
        if (board[r][pos.file] != null) break;
      }
      for (int f = pos.file; f++ < 7;) {
        moves[Position(pos.rank, f)] = Action.both;
        if (board[pos.rank][f] != null) break;
      }
      for (int r = pos.rank; r-- > 0 ;) {
        moves[Position(r, pos.file)] = Action.both;
        if (board[r][pos.file] != null) break;
      }
      for (int f = pos.file; f-- > 0;) {
        moves[Position(pos.rank, f)] = Action.both;
        if (board[pos.rank][f] != null) break;
      }
      if (piece.turnMoved < 1) {
        for (final p in moves.keys) {
          final at = board[p.rank][p.file];
          if (at != null && at.type == PieceType.king && at.turnMoved < 1) {
            moves[p] = Action.castle;
          }
        }
      }
    case PieceType.queen:
      for (int r = pos.rank, f = pos.file; r++ < 7 && f++ < 7;) {
        moves[Position(r, f)] = Action.both;
        if (board[r][f] != null) break;
      }
      for (int r = pos.rank, f = pos.file; r-- > 0 && f++ < 7;) {
        moves[Position(r, f)] = Action.both;
        if (board[r][f] != null) break;
      }
      for (int r = pos.rank, f = pos.file; r++ < 7 && f-- > 0;) {
        moves[Position(r, f)] = Action.both;
        if (board[r][f] != null) break;
      }
      for (int r = pos.rank, f = pos.file; r-- < 0 && f-- > 0;) {
        moves[Position(r, f)] = Action.both;
        if (board[r][f] != null) break;
      }
      for (int r = pos.rank; r++ < 7;) {
        moves[Position(r, pos.file)] = Action.both;
        if (board[r][pos.file] != null) break;
      }
      for (int f = pos.file; f++ < 7;) {
        moves[Position(pos.rank, f)] = Action.both;
        if (board[pos.rank][f] != null) break;
      }
      for (int r = pos.rank; r-- > 0 ;) {
        moves[Position(r, pos.file)] = Action.both;
        if (board[r][pos.file] != null) break;
      }
      for (int f = pos.file; f-- > 0;) {
        moves[Position(pos.rank, f)] = Action.both;
        if (board[pos.rank][f] != null) break;
      }
    case PieceType.king:
      moves[Position(pos.rank + 1, pos.file + 1)] = Action.both;
      moves[Position(pos.rank - 1, pos.file + 1)] = Action.both;
      moves[Position(pos.rank + 1, pos.file - 1)] = Action.both;
      moves[Position(pos.rank - 1, pos.file - 1)] = Action.both;
      moves[Position(pos.rank - 1, pos.file)] = Action.both;
      moves[Position(pos.rank + 1, pos.file)] = Action.both;
      moves[Position(pos.rank, pos.file - 1)] = Action.both;
      moves[Position(pos.rank, pos.file + 1)] = Action.both;
  }
  moves.removeWhere((p, action) {
    if (p.outBounds) return true;
    if (action == Action.castle) return false;
    final at = board[p.rank][p.file];
    if (at != null) {
      if (at.player != piece.player && action != Action.move) {
        return false;
      }
    } else if (action != Action.attack) {
      return false;
    }
    return true;
  });
  return moves;
}

int turn = 1;

void main() {
  printBoard();
  String? cmd = stdin.readLineSync();
  for (; cmd != null; cmd = stdin.readLineSync()) {
    final runes = cmd.toLowerCase().trim().runes.toList();
    if (runes.length < 2) continue;
    final from = Position(runes[1]-49, runes[0]-97);
    final moves = getMoves(from);
    if (runes.length < 4) {
      print(moves);
      continue;
    }
    final to = Position(runes[3]-49, runes[2]-97);
    if (!moves.containsKey(to)) {
      print("illegal");
      continue;
    }
    final piece = board[from.rank][from.file];
    if (moves[to] == Action.castle) {
      final kTo = Position(
        to.rank,
        (from.file == 0 ? -2 : 2) + to.file,
      );
      final rTo = Position(
        to.rank,
        (from.file == 0 ? 1 : -1) + kTo.file,
      );
      final king = board[to.rank][to.file];
      king?.turnMoved = turn;
      board[rTo.rank][rTo.file] = piece;
      board[rTo.rank][rTo.file]?.position = rTo;
      board[kTo.rank][kTo.file] = king;
      board[kTo.rank][kTo.file]?.position = kTo;
      board[to.rank][to.file] = null;
    } else {
      board[to.rank][to.file] = piece;
      board[to.rank][to.file]?.position = to;
    }
    board[from.rank][from.file] = null;
    piece?.turnMoved = turn;
    turn++;
    printBoard();
  }
}