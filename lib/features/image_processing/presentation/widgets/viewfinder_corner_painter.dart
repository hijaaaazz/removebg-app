import 'package:flutter/material.dart';

/// Custom painter for camera viewfinder corner brackets `[ ]`.
class ViewfinderCornerPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  const ViewfinderCornerPainter({
    required this.color,
    this.cornerLength = 24.0,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-Left corner
    canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerLength), paint);

    // Top-Right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-Left corner
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-Right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant ViewfinderCornerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.cornerLength != cornerLength ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// Custom clipper for vertical scan reveal effects.
class VerticalScanClipRect extends CustomClipper<Rect> {
  final double progress;

  const VerticalScanClipRect(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, size.height * progress);
  }

  @override
  bool shouldReclip(covariant VerticalScanClipRect oldClipper) =>
      oldClipper.progress != progress;
}
