import 'package:flutter/material.dart';
import 'package:raitec/pages/ISConductores.dart';
import 'package:raitec/pages/aspirar.dart';
import 'package:raitec/pages/document.dart';
import 'package:raitec/pages/inicio.dart';
import 'package:raitec/pages/registro.dart';
import 'pages/costos.dart';

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla Principal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Aspirar()),
                );
              },
              child: const Text('Aspirar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InformacionCostosScreen()),
                );
              },
              child: const Text('Información de Costos'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DocumentUploadScreen()),
                );
              },
              child: const Text('Subir Documentos'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InicioSesion()),
                );
              },
              child: const Text('Iniciar Sesión'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ISConductores()),
                );
              },
              child: const Text('IS Conductores'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Registro()),
                );
              },
              child: const Text('Registro'),
            ),
          ],
        ),
      ),
    );
  }
}
