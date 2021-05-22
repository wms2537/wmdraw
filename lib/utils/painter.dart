import 'package:flutter/material.dart';

class Painter extends CustomPainter {
  List<Offset?> points;
  Color color;
  StrokeCap strokeCap;
  double strokeWidth;
  List<Painter> painters;

  Painter(
      { required this.points,
      required this.color,
      required this.strokeCap,
      required this.strokeWidth,
      this.painters = const []});

  @override
  void paint(Canvas canvas, Size size) {
    for (Painter painter in painters) {
      painter.paint(canvas, size);
    }

    Paint paint = new Paint();
    paint.color = color;
    paint.strokeCap = strokeCap;
    paint.strokeWidth = strokeWidth;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(Painter oldPainter) => oldPainter.points != points;
}