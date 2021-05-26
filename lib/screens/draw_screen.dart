import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

import 'package:wmdraw/utils/painter.dart';
import 'package:wmdraw/widgets/color_picker.dart';
import 'package:wmdraw/widgets/width_dialog.dart';

class DrawScreen extends StatefulWidget {
  static const routeName = '/draw';
  @override
  DrawScreenState createState() => new DrawScreenState();
}

class DrawScreenState extends State<DrawScreen> with TickerProviderStateMixin {
  GlobalKey globalKey = GlobalKey();
  late AnimationController controller;
  List<Offset> points = <Offset>[];
  Color color = Colors.black;
  StrokeCap strokeCap = StrokeCap.round;
  double strokeWidth = 5.0;
  List<Painter> painters = <Painter>[];
  List<Painter> undonePainters = <Painter>[];
  Matrix4 _transformation = Matrix4.identity();
  int totalPoints = 0;
  int pannedPoints = 0;
  int? scrollBtnId = null;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void savePath() {
    painters.add(Painter(
        points: points
            .map((e) => MatrixUtils.transformPoint(
                Matrix4.inverted(_transformation), e))
            .toList(),
        color: color,
        strokeCap: strokeCap,
        strokeWidth: strokeWidth)
      ..transformation = _transformation);
    points.clear();
  }

  void scaleTransform(Offset focalPoint, double scale) {
    final transformation =
        Matrix4.translationValues(focalPoint.dx, focalPoint.dy, 0);
    transformation.multiply(Matrix4.diagonal3Values(scale, scale, 1.0));
    transformation
        .multiply(Matrix4.translationValues(-focalPoint.dx, -focalPoint.dy, 0));
    _transformation.multiply(transformation);

    setState(() {
      final numPainters = painters.length;
      for (int i = numPainters - 1; i >= 0; --i) {
        painters[i].transformation.multiply(Matrix4.inverted(transformation));
        // painters[i].strokeWidth =
        //     painters[i].strokeWidth / transformation.row0.storage[0];
      }
      points = new List.from(points);
    });
  }

  void translateTransform(double dx, double dy) {
    final transformation = Matrix4.translationValues(-dx, -dy, 0);

    _transformation.multiply(transformation);

    setState(() {
      final numPainters = painters.length;
      for (int i = numPainters - 1; i >= 0; --i) {
        painters[i].transformation.multiply(Matrix4.inverted(transformation));
      }
      points = new List.from(points);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Listener(
            onPointerDown: (PointerDownEvent onPointerDown) {
              if (onPointerDown.buttons == kMiddleMouseButton) {
                scrollBtnId = onPointerDown.pointer;
              }
            },
            onPointerUp: (PointerUpEvent onPointerUp) {
              if (onPointerUp.pointer == scrollBtnId) {
                scrollBtnId = null;
              }
            },
            onPointerMove: (PointerMoveEvent onPointerMove) {
              if (scrollBtnId != null) {
                translateTransform(
                    onPointerMove.delta.dx, onPointerMove.delta.dy);
              }
            },
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                final scale = pointerSignal.scrollDelta.dy.sign * 0.2 + 1;

                scaleTransform(pointerSignal.position, scale);
                // print(_fontScale);

              }
            },
            child: GestureDetector(
              // onPanUpdate: (DragUpdateDetails details) {

              // },
              onScaleEnd: (ScaleEndDetails details) => savePath(),
              onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
                // don't update the UI if the scale didn't change
                if (scaleUpdateDetails.scale == 1.0 && scrollBtnId == null) {
                  totalPoints += 1;
                  if (totalPoints % 3 == 0) {
                    undonePainters.clear();
                    setState(() {
                      // points = new List.from(points);
                      // final newPoint = MatrixUtils.transformPoint(
                      //     Matrix4.inverted(_transformation),
                      //     );
                      // print(newPoint);
                      points = new List.from(points)
                        ..add(scaleUpdateDetails.localFocalPoint);
                    });
                  }
                  return;
                }
                scaleTransform(
                    scaleUpdateDetails.focalPoint, scaleUpdateDetails.scale);
              },
              child: RepaintBoundary(
                key: globalKey,
                child: CustomPaint(
                  painter: Painter(
                      points: points,
                      color: color,
                      strokeCap: strokeCap,
                      strokeWidth:
                          strokeWidth * _transformation.row0.storage[0],
                      painters: painters),
                  size: Size.infinite,
                  isComplex: true,
                  willChange: true,
                ),
              ),
            ),
          ),
          Positioned(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    "WMDraw",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 8, 8, 0),
            child: FloatingActionButton(
              elevation: 0,
              highlightElevation: 0,
              hoverElevation: 0,
              heroTag: 'rstbtn',
              child: Icon(Icons.center_focus_strong),
              backgroundColor: Theme.of(context).accentColor.withOpacity(0.5),
              onPressed: () {
                setState(() {
                  for (var painter in painters) {
                    painter.transformation = Matrix4.identity();
                  }
                  points = new List.from(points);
                  _transformation = Matrix4.identity();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: FloatingActionButton(
              elevation: 0,
              highlightElevation: 0,
              hoverElevation: 0,
              heroTag: 'savebtn',
              child: Icon(Icons.save),
              backgroundColor: Theme.of(context).accentColor.withOpacity(0.5),
              onPressed: () async {
                RenderRepaintBoundary boundary = globalKey.currentContext!
                    .findRenderObject() as RenderRepaintBoundary;
                ui.Image image = await boundary.toImage();
                ByteData? byteData =
                    await image.toByteData(format: ui.ImageByteFormat.png);
                final content = base64Encode(Uint8List.view(byteData!.buffer));
                final anchor = html.AnchorElement(
                    href:
                        "data:application/octet-stream;charset=utf-16le;base64,$content")
                  ..setAttribute("download", "file.png")
                  ..click();
                html.document.body!.children.remove(anchor);
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 70.0,
                width: 56.0,
                alignment: FractionalOffset.topCenter,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: controller,
                    curve:
                        Interval(0.0, 1.0 - 0 / 3 / 2.0, curve: Curves.easeOut),
                  ),
                  child: FloatingActionButton(
                    heroTag: 'redobtn',
                    mini: true,
                    child: Icon(Icons.redo),
                    onPressed: () {
                      if (undonePainters.isNotEmpty) {
                        setState(() {
                          painters.add(undonePainters.removeLast());
                        });
                      }
                    },
                  ),
                ),
              ),
              Container(
                height: 70.0,
                width: 56.0,
                alignment: FractionalOffset.topCenter,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: controller,
                    curve:
                        Interval(0.0, 1.0 - 1 / 4 / 2.0, curve: Curves.easeOut),
                  ),
                  child: FloatingActionButton(
                    heroTag: 'undobtn',
                    mini: true,
                    child: Icon(Icons.undo),
                    onPressed: () {
                      if (painters.isEmpty) {
                        return;
                      }
                      setState(() {
                        undonePainters.add(painters.removeLast());
                      });
                    },
                  ),
                ),
              ),
              Container(
                height: 70.0,
                width: 56.0,
                alignment: FractionalOffset.topCenter,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: controller,
                    curve:
                        Interval(0.0, 1.0 - 2 / 4 / 2.0, curve: Curves.easeOut),
                  ),
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: 'strokebtn',
                    child: Icon(Icons.lens),
                    onPressed: () async {
                      double? temp;
                      temp = await showDialog(
                          context: context,
                          builder: (context) =>
                              WidthDialog(strokeWidth: strokeWidth));
                      if (temp != null) {
                        setState(() {
                          savePath();
                          strokeWidth = temp!;
                        });
                      }
                    },
                  ),
                ),
              ),
              Container(
                height: 70.0,
                width: 56.0,
                alignment: FractionalOffset.topCenter,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: controller,
                    curve:
                        Interval(0.0, 1.0 - 3 / 4 / 2.0, curve: Curves.easeOut),
                  ),
                  child: FloatingActionButton(
                      heroTag: 'colorbtn',
                      mini: true,
                      child: Icon(Icons.color_lens),
                      onPressed: () async {
                        Color? temp;
                        temp = await showDialog(
                            context: context,
                            builder: (context) => ColorDialog(
                                  initialColor: color,
                                ));
                        if (temp != null) {
                          setState(() {
                            savePath();
                            color = temp!;
                          });
                        }
                      }),
                ),
              ),
              FloatingActionButton(
                heroTag: 'mainbtn',
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (BuildContext context, Widget? child) {
                    return Transform(
                      transform:
                          Matrix4.rotationZ(controller.value * 0.5 * math.pi),
                      alignment: FractionalOffset.center,
                      child: Icon(Icons.brush),
                    );
                  },
                ),
                onPressed: () {
                  if (controller.isDismissed) {
                    controller.forward();
                  } else {
                    controller.reverse();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
