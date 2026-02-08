import 'package:flutter/material.dart';

class CrosshairPainter extends CustomPainter {
  final Color color;
  CrosshairPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    const double lineLength = 25;
    const double gap = 5; // The clear space in the very center

    // Vertical Lines
    canvas.drawLine(
      Offset(centerX, centerY - lineLength),
      Offset(centerX, centerY - gap),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY + gap),
      Offset(centerX, centerY + lineLength),
      paint,
    );

    // Horizontal Lines
    canvas.drawLine(
      Offset(centerX - lineLength, centerY),
      Offset(centerX - gap, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + gap, centerY),
      Offset(centerX + lineLength, centerY),
      paint,
    );

    // Optional: Draw a tiny circle in the middle
    canvas.drawCircle(
      Offset(centerX, centerY),
      2,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
