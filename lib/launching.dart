import 'package:ecoflow/landingPage.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LaunchingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF041D31),
      body: Center(
        child: Hero(
          tag: 'logo',
          child:
              Image.asset('images/ecoflow_logo.png', width: 200, height: 200),
        ),
      ),
    );
  }
}

class LaunchingScreen extends StatefulWidget {
  @override
  _LaunchingScreenState createState() => _LaunchingScreenState();
}

class _LaunchingScreenState extends State<LaunchingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => LandingPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LaunchingPage();
  }
}
