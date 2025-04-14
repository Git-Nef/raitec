import 'package:flutter/material.dart';
import 'package:raitec/pages/ISConductores.dart';
import 'package:raitec/pages/PrincipalConductor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inicio de Sesión',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PrincipalConductor(),
    );
  }
}
