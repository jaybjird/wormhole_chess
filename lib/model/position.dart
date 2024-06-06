import 'direction.dart';

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
