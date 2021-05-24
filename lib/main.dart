import 'package:flutter/material.dart';
import 'package:wmdraw/screens/draw_screen.dart';
import 'package:wmdraw/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            title: 'WMDraw',
            home: HomeScreen(title: "DrawApp"),
            theme: ThemeData(
              primarySwatch: Colors.teal,
              primaryColorLight: Colors.teal.shade200,
              backgroundColor: Colors.teal.shade100,
              accentColor: Colors.cyan,
              primaryIconTheme: IconThemeData(color: Colors.black)
                  ),
            routes: {
              DrawScreen.routeName: (ctx) => DrawScreen(),
            },
          );
  }
}
// background-image: linear-gradient( 109.6deg,  rgba(116,18,203,1) 11.2%, rgba(230,46,131,1) 91.2% );