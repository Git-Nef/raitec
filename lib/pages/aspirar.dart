import 'package:flutter/material.dart';
import 'package:raitec/pages/RegistrarVehiculo.dart';

class Aspirar extends StatelessWidget {
  const Aspirar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/SplashScreen.png',
                  height: 260,
                ),
                const SizedBox(height: 40),
                const Icon(Icons.download, size: 60, color: Colors.grey),
                const SizedBox(height: 20),

                // Caja de texto para ingresar matrícula
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Ingresar Matrícula',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),

                const SizedBox(height: 16),
                _uploadButton('SUBIR HORARIO'),
                _uploadButton('SUBIR KARDEX'),
                _uploadButton('SUBIR LICENCIA DE CONDUCIR'),
                _uploadButton('SUBIR COMPROBANTE DE DOMICILIO'),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RegistrarVehiculo(numControl: '20201234'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'INFORMACIÓN DEL VEHÍCULO',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción para enviar papelería
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ENVIAR PAPELERÍA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 32),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Acción de ayuda
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.help_outline, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  Widget _uploadButton(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Acción para cargar archivo
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
