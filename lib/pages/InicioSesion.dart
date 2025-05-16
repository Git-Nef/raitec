import 'package:flutter/material.dart';
import 'package:raitec/pages/PrincipalConductor.dart';
import 'package:raitec/pages/PrincipalUsuario.dart';
import 'package:raitec/pages/Registro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raitec/pages/sesion.dart';

class InicioSesion extends StatelessWidget {
  const InicioSesion({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController claveController = TextEditingController();
    final TextEditingController nipController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/LogoPantallas.png',
                  height: 140,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Número de control',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: claveController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ingresa tu número',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'NIP',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nipController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ingresa tu NIP',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _mainButton(
                text: 'Iniciar Sesión',
                onPressed: () async {
                  final clave = claveController.text.trim();
                  final nip = nipController.text.trim();

                  if (clave.isEmpty || nip.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completa ambos campos'),
                      ),
                    );
                    return;
                  }

                  try {
                    final doc = await FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(clave)
                        .get();

                    if (!doc.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Usuario no encontrado')),
                      );
                      return;
                    }

                    final data = doc.data();
                    if (data?['nip'] == nip) {
                      SessionManager().setNumControl(clave);
                      if (data?['esConductor'] == false) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PrincipalUsuario(numControl: clave)),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PrincipalConductor(numControl: clave)),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('NIP incorrecto')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _mainButton(
                text: 'Crear Cuenta',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Registro()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainButton({
    required String text,
    required VoidCallback onPressed,
    Color color = Colors.blueAccent,
  }) {
    return Center(
      child: SizedBox(
        width: 240, // Ancho reducido para un look más elegante
        height: 44,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
