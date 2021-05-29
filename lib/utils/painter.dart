import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class Painter extends CustomPainter {
  List<Offset> points;
  Color color;
  StrokeCap strokeCap;
  double strokeWidth;
  List<Painter> painters;
  Matrix4 transformation = Matrix4.identity();

  Painter(
      {required this.points,
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
    paint.strokeWidth = strokeWidth * transformation.row0.storage[0];
    for (int i = points.length - 1; i >= 0; --i) {
      canvas.drawLine(
        MatrixUtils.transformPoint(transformation, points[i]),
        MatrixUtils.transformPoint(transformation, points[i - 1]),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(Painter oldPainter) =>
      oldPainter.transformation != transformation;
}

class MyCustomPainter extends CustomPainter {
  final ui.Image myBackground;
  const MyCustomPainter(this.myBackground);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(myBackground, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(MyCustomPainter oldPainter) =>
      oldPainter.myBackground != myBackground;
}
