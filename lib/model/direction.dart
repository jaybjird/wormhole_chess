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
