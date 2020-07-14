import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minhas_viagens/Home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Timer(
      Duration(milliseconds: 1000),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Home()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF0066cc),
        padding: EdgeInsets.all(60),
        child: Center(
          child: Image.asset("images/logo.png"),
        ),
      ),
    );
  }
}
