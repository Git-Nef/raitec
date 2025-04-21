import 'package:flutter/material.dart';
import 'package:raitec/pages/PrincipalConductor.dart';

class ISConductores extends StatelessWidget {
  const ISConductores({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController claveController = TextEditingController();
    final TextEditingController nipController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(''),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen con mayor tamaño
              Image.asset(
                'assets/logoRT.png',
                height: 180,
              ),
              const SizedBox(height: 40),

              // Campo Clave
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ingresa tu clave',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: claveController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Clave',
                ),
              ),
              const SizedBox(height: 24),

              // Campo NIP
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ingresa tu NIP',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nipController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'NIP',
                ),
              ),
              const SizedBox(height: 32),

              // Botón estilizado
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    final clave = claveController.text;
                    final nip = nipController.text;
                    print('Clave: $clave, NIP: $nip');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PrincipalConductor()),
                    );
                  },
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
