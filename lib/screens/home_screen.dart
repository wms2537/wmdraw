import 'package:flutter/material.dart';
import 'package:wmdraw/screens/draw_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  //Set default painter values
  List<Offset> points = <Offset>[];
  Color color = Colors.black;
  StrokeCap strokeCap = StrokeCap.round;
  double strokeWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(116, 18, 203, 1),
                  Color.fromRGBO(230, 46, 131, 1),
                ],
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
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                Expanded(
                  child: Center(
                    child: InkWell(
                      onTap: () =>
                          Navigator.of(context).pushNamed(DrawScreen.routeName),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              borderRadius: BorderRadius.circular(16)),
                          padding: EdgeInsets.all(24),
                          child: Text('Start Drawing')),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
