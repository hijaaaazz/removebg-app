import 'package:flutter/material.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

class CheckerboardBackground extends StatelessWidget {
  final double squareSize;

  const CheckerboardBackground({
    super.key,
    this.squareSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerboardPainter(
        squareSize: squareSize,
        lightColor: AppColors.checkerboardLight,
        darkColor: AppColors.checkerboardDark,
      ),
      size: Size.infinite,
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  final double squareSize;
  final Color lightColor;
  final Color darkColor;

  _CheckerboardPainter({
    required this.squareSize,
    required this.lightColor,
    required this.darkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()..color = lightColor;
    final darkPaint = Paint()..color = darkColor;

    final cols = (size.width / squareSize).ceil();
    final rows = (size.height / squareSize).ceil();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final paint = (r + c) % 2 == 0 ? lightPaint : darkPaint;
        canvas.drawRect(
          Rect.fromLTWH(c * squareSize, r * squareSize, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerboardPainter oldDelegate) =>
      oldDelegate.squareSize != squareSize ||
      oldDelegate.lightColor != lightColor ||
      oldDelegate.darkColor != darkColor;
}
