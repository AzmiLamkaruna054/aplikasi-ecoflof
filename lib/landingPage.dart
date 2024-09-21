import 'package:ecoflow/main_screen.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _showButton = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF041D31),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Updated to center
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Updated to center
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Image.asset('images/ecoflow_logo.png',
                        width: 190, height: 190),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Selamat Datang di EcoFlow!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Column(
              children: [
                _showButton
                    ? ElevatedButton(
                        onPressed: () {
                          // Navigasi ke halaman utama
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainScreen()));
                        },
                        child: Text(
                          'Mulai',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.black),
                        ),
                      )
                    : Container(),
                SizedBox(height: 35),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
