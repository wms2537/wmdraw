import 'package:flutter/material.dart';
import 'package:wmdraw/screens/draw_screen.dart';
import 'package:wmdraw/widgets/hcaptcha.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool buttonEnabled = false;
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
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
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.pinkAccent.shade200,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'WMDraw',
                        style: TextStyle(
                          color: Theme.of(context)
                              .accentTextTheme
                              .headline6!
                              .color,
                          fontSize: 50,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: Card(
                      color: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8.0,
                      child: Container(
                        margin: EdgeInsets.all(16),
                        height: 600,
                        constraints: BoxConstraints(minHeight: 320),
                        width: deviceSize.width * 0.6,
                        padding: EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: buttonEnabled
                                    ? () {
                                        Navigator.of(context)
                                            .pushNamed(DrawScreen.routeName);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.pinkAccent,
                                  padding: EdgeInsets.all(24),
                                ),
                                child: Text('Start Drawing'),
                              ),
                              Container(
                                margin: EdgeInsets.all(16),
                                width: 360,
                                height: 500,
                                child: Captcha((bool success) {
                                  if (success) {
                                    setState(() {
                                      buttonEnabled = true;
                                    });
                                  }
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
