import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:raitec/pages/RutasOfrecidas.dart';
import 'package:raitec/pages/Splashscreen.dart';
import 'firebase_options.dart'; // Este archivo lo genera FlutterFire automáticamente

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RaiTec',
      debugShowCheckedModeBanner: false,
      home: RutasOfrecidas(), // Tu pantalla inicial
    );
  }
}
