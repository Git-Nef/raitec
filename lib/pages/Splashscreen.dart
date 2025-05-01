import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raitec/pages/InicioSesion.dart';
import 'package:raitec/pages/RutasOfrecidas.dart';
import 'package:raitec/pages/mapa.dart';
import 'package:raitec/pages/ubicacion.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MySplashScreen();
  }
}

class _MySplashScreen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 5), // Se agregó const para optimización
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return InicioSesion();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset('assets/SplashScreen.png'),
      ),
    );
  }
}
