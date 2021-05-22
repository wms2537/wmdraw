import 'package:flutter/material.dart';
import 'package:wmdraw/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            title: 'WMDraw',
            home: HomePage(title: "DrawApp"),
          );
  }
}