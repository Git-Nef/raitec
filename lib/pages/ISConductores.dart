import 'package:flutter/material.dart';

class ISConductores extends StatelessWidget {
  const ISConductores({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController claveController = TextEditingController();
    final TextEditingController nipController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen arriba
            Center(
              child: Image.asset(
                'assets/logoRT.png',
                height: 120, // Puedes ajustar el tamaño
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Ingresa tu clave',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: claveController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Clave',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ingresa tu NIP',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: nipController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'NIP',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  final clave = claveController.text;
                  final nip = nipController.text;
                  print('Clave: $clave, NIP: $nip');
                },
                child: const Text('Iniciar Sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
