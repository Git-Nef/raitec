import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raitec/pages/FirestoreService.dart';
import 'package:raitec/pages/InicioSesion.dart';
import 'package:raitec/pages/aspirar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _formKey = GlobalKey<FormState>();
  final firestore = FirestoreService();

  final _numControl = TextEditingController();
  final _nip = TextEditingController();
  final _confirmNip = TextEditingController();
  final _nombre = TextEditingController();
  final _edad = TextEditingController();
  final _carrera = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  final _nacionalidad = TextEditingController();
  final _fechaNacimiento = TextEditingController();
  final _telefonoEmergencia = TextEditingController();

  String? fotografiaUrl;
  String? firmaUrl;

  Future<void> seleccionarImagen(bool desdeCamara, String tipo) async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: desdeCamara ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 75,
    );

    if (imagen == null) return;

    final nombreArchivo = '$tipo-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref =
        FirebaseStorage.instance.ref().child('usuarios/$tipo/$nombreArchivo');

    await ref.putFile(File(imagen.path));
    final url = await ref.getDownloadURL();

    setState(() {
      if (tipo == 'foto') {
        fotografiaUrl = url;
      } else {
        firmaUrl = url;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imagen de $tipo subida correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.white),
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
                  ),
                  onPressed: () async {
                    try {
                      await firestore.crearUsuario(
                        _numControl.text.trim(),
                        {
                          'numControl': _numControl.text.trim(),
                          'nip': _nip.text.trim(),
                          'nombre': _nombre.text.trim(),
                          'edad': int.tryParse(_edad.text.trim()) ?? 0,
                          'carrera': _carrera.text.trim(),
                          'direccion': _direccion.text.trim(),
                          'telefono': _telefono.text.trim(),
                          'nacionalidad': _nacionalidad.text.trim(),
                          'fechaNacimiento': _fechaNacimiento.text.trim(),
                          'telefonoEmergencia': _telefonoEmergencia.text.trim(),
                          'fotografiaUrl': fotografiaUrl ?? '',
                          'firmaUrl': firmaUrl ?? '',
                          'esConductor': false,
                        },
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Usuario registrado')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const InicioSesion()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: \$e')),
                      );
                    }
                  },
                  child: const Text('REGISTRARME',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const InicioSesion()));
                  },
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
                const SizedBox(height: 24),
                const Text('¿Quieres ser conductor?',
                    style: TextStyle(fontSize: 16)),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const Aspirar()));
                  },
                  child: const Text('Elaborar Petición'),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller,
      {bool obscure = false, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF0F0F0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _botonesImagen(String titulo, String tipo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () => seleccionarImagen(true, tipo),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cámara'),
            ),
            OutlinedButton.icon(
              onPressed: () => seleccionarImagen(false, tipo),
              icon: const Icon(Icons.image),
              label: const Text('Galería'),
            ),
          ],
        ),
      ],
    );
  }
}
