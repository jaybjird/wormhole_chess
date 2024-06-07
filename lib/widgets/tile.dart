import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../model/chess_piece.dart';

class TilePath {
  final Offset outerStart, outerEnd, innerStart, innerEnd;
  final Offset? outerCorner;
  final double? outerRadius, innerRadius;

  TilePath(
      {required this.outerStart,
        required this.outerEnd,
        required this.innerStart,
        required this.innerEnd,
        this.outerCorner,
        this.outerRadius,
        this.innerRadius});

  List<Offset> get points => [
    outerStart,
    if (outerCorner != null) outerCorner!,
    outerEnd,
    innerEnd,
    innerStart,
  ];

  Rect get rect {
    final p = points;
    final x = p.map((p) => p.dx);
    final y = p.map((p) => p.dy);
    return Rect.fromLTRB(
      x.reduce(min),
      y.reduce(min),
      x.reduce(max),
      y.reduce(max),
    );
  }

  TilePath translate(double dx, double dy) {
    return TilePath(
      outerStart: outerStart.translate(dx, dy),
      outerCorner: outerCorner?.translate(dx, dy),
      outerEnd: outerEnd.translate(dx, dy),
      innerStart: innerStart.translate(dx, dy),
      innerEnd: innerEnd.translate(dx, dy),
      outerRadius: outerRadius,
      innerRadius: innerRadius,
    );
  }
}

class TileClipper extends CustomClipper<Path> {
  final TilePath tilePath;

  const TileClipper(this.tilePath);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(tilePath.outerStart.dx, tilePath.outerStart.dy);
    if (tilePath.outerCorner != null) {
      path.lineTo(tilePath.outerCorner!.dx, tilePath.outerCorner!.dy);
    }
    if (tilePath.outerRadius != null) {
      path.arcToPoint(
        tilePath.outerEnd,
        radius: Radius.circular(tilePath.outerRadius!),
      );
    } else {
      path.lineTo(tilePath.outerEnd.dx, tilePath.outerEnd.dy);
    }
    path.lineTo(tilePath.innerStart.dx, tilePath.innerStart.dy);
    if (tilePath.innerRadius != null) {
      path.arcToPoint(
        tilePath.innerEnd,
        radius: Radius.circular(tilePath.innerRadius!),
        clockwise: false,
      );
    } else {
      path.lineTo(tilePath.innerEnd.dx, tilePath.innerEnd.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
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

  final TilePath path;

  const Tile({
    super.key,
    required this.isWhite,
    this.piece,
    this.isSelected = false,
    this.isValidMove = false,
    this.isInvalidPawnAttack = false,
    this.isThreatened = false,
    required this.onTap,
    required this.path,
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
    final rect = path.rect;
    return Positioned.fromRect(
        rect: rect,
        child: GestureDetector(
          onTap: onTap,
          child: ClipPath(
            clipper: TileClipper(path.translate(-rect.left, -rect.top)),
            child: Container(
              color: color,
              child: piece != null ? SvgPicture.asset(piece!.imagePath) : null,
            ),
          ),
        )
    );
  }
}
