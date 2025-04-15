import 'package:flutter/material.dart';

class Registro extends StatelessWidget {
  const Registro({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controlNumberController = TextEditingController();
    final TextEditingController nipController = TextEditingController();
    final TextEditingController confirmNipController = TextEditingController();

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
              // Logo
              Image.asset(
                'assets/logoRaitec.png', // Replace with the actual path to the RAITEC logo
                height: 120,
              ),
              const SizedBox(height: 40),

              // Icon above the control number field
              const Icon(
                Icons.person,
                size: 40,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),

              // Campo Número de Control
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'NÚMERO DE CONTROL',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controlNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: '',
                ),
              ),
              const SizedBox(height: 24),

              // Campo Ingresa tu NIP
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'INGRESA TU NIP',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nipController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: '',
                ),
              ),
              const SizedBox(height: 24),

              // Campo Confirmar NIP
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CONFIRMAR NIP',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmNipController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: '',
                ),
              ),
              const SizedBox(height: 32),

              // Botón Registrarme
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
                    final controlNumber = controlNumberController.text;
                    final nip = nipController.text;
                    final confirmNip = confirmNipController.text;
                    print('Número de Control: $controlNumber, NIP: $nip, Confirmar NIP: $confirmNip');
                  },
                  child: const Text(
                    'REGISTRARME',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón Ya tengo una cuenta
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
                    print('Ya tengo una cuenta presionado');
                  },
                  child: const Text(
                    'YA TENGO UNA CUENTA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Texto informativo
              const Text(
                '¿QUIERES FORMAR PARTE DE\nLA PLANTILLA DE CONDUCTORES?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Botón Elaborar Petición
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
                    print('Elaborar Petición presionado');
                  },
                  child: const Text(
                    'ELABORAR PETICIÓN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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