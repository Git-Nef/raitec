import 'package:flutter/material.dart';
import 'package:raitec/pages/InicioSesion.dart';
import 'package:raitec/pages/Splashcreen.dart';
import 'package:raitec/pages/cards.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Cards(),
    );
  }
}
