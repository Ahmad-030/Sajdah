import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw cardinal directions
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * (math.pi / 180);
      final x = center.dx + (radius - 30) * math.sin(angle);
      final y = center.dy - (radius - 30) * math.cos(angle);

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: directions[i] == 'N' ? Colors.red : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw degree marks
    for (int i = 0; i < 360; i += 10) {
      final angle = i * (math.pi / 180);
      final startRadius = i % 30 == 0 ? radius - 15 : radius - 8;
      final start = Offset(
        center.dx + startRadius * math.sin(angle),
        center.dy - startRadius * math.cos(angle),
      );
      final end = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );

      paint.strokeWidth = i % 30 == 0 ? 3 : 1;
      paint.color = i % 30 == 0 ? Colors.black : Colors.grey[400]!;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}