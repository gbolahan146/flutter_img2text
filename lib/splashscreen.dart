import 'package:flutter/material.dart';
import 'package:generate_live_captions/home.dart';
import 'package:splashscreen/splashscreen.dart';

class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        seconds: 2,
        navigateAfterSeconds: Home(),
        title: Text(
          "Text Generator",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        gradientBackground: LinearGradient(
          begin: AlignmentDirectional.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.004, 1],
          colors: [Color(0x11232526), Color(0xff232526) ]),
          photoSize: 50,
          loaderColor: Colors.white,
          image: Image.asset("assets/notepad.png"),
        );
  }
}
