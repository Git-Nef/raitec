// IMPORTS IGUALES
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raitec/pages/FirestoreService.dart';
import 'package:raitec/pages/InicioSesion.dart';
import 'package:raitec/pages/aspirar.dart';

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
  final _email = TextEditingController();
  final _edad = TextEditingController();
  final _carrera = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  final _nacionalidad = TextEditingController();
  final _fechaNacimiento = TextEditingController();
  final _telefonoEmergencia = TextEditingController();

  String? fotografiaUrl;
  String? firmaUrl;

  Future<void> seleccionarImagen(String tipo) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.white),
                title: const Text('Tomar foto', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? imagen =
                  await picker.pickImage(source: ImageSource.camera);
                  if (imagen != null) await _subirImagen(imagen, tipo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Elegir de galería', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? imagen =
                  await picker.pickImage(source: ImageSource.gallery);
                  if (imagen != null) await _subirImagen(imagen, tipo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _subirImagen(XFile imagen, String tipo) async {
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

  bool get camposCompletos {
    return _numControl.text.trim().isNotEmpty &&
        _nip.text.trim().isNotEmpty &&
        _confirmNip.text.trim().isNotEmpty &&
        _nombre.text.trim().isNotEmpty &&
        _email.text.trim().isNotEmpty &&
        _edad.text.trim().isNotEmpty &&
        _carrera.text.trim().isNotEmpty &&
        _direccion.text.trim().isNotEmpty &&
        _telefono.text.trim().isNotEmpty &&
        _nacionalidad.text.trim().isNotEmpty &&
        _fechaNacimiento.text.trim().isNotEmpty &&
        _telefonoEmergencia.text.trim().isNotEmpty &&
        fotografiaUrl != null &&
        firmaUrl != null;
  }

  void actualizarEstado() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/logoAppbar.png', height: 60),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text('Registro de Usuario',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                _input('Número de Control', _numControl),
                _input('NIP', _nip, obscure: true),
                _input('Confirmar NIP', _confirmNip, obscure: true),
                _input('Nombre Completo', _nombre),
                _input('Correo Electrónico', _email, keyboard: TextInputType.emailAddress),
                _input('Edad', _edad, keyboard: TextInputType.number),
                _input('Carrera', _carrera),
                _input('Dirección', _direccion),
                _input('Teléfono', _telefono, keyboard: TextInputType.phone),
                _input('Nacionalidad', _nacionalidad),
                GestureDetector(
                  onTap: _seleccionarFechaNacimiento,
                  child: AbsorbPointer(
                    child: _input('Fecha de Nacimiento (YYYY-MM-DD)', _fechaNacimiento),
                  ),
                ),
                _input('Tel. Emergencia', _telefonoEmergencia, keyboard: TextInputType.phone),
                const SizedBox(height: 16),
                _uploadButton('Subir Foto de Perfil o INE', 'foto'),
                if (fotografiaUrl != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(fotografiaUrl!, height: 120),
                    ),
                  ),
                _uploadButton('Subir Firma Digital o Escaneada', 'firma'),
                if (firmaUrl != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(firmaUrl!, height: 80),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: camposCompletos ? Colors.blueAccent : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: camposCompletos ? _registrarUsuario : null,
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text(
                      'Registrarme',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '¿Ya tienes cuenta? ',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    children: [
                      TextSpan(
                        text: 'Inicia sesión',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const InicioSesion()),
                            );
                          },
                      ),
                    ],
                  ),
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
      child: TextField(
        controller: controller,
        onChanged: (_) => actualizarEstado(),
        obscureText: obscure,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _uploadButton(String texto, String tipo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: () => seleccionarImagen(tipo),
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: Text(
          texto,
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarFechaNacimiento() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento.text =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _registrarUsuario() async {
    final nip = _nip.text.trim();
    final confirm = _confirmNip.text.trim();
    final email = _email.text.trim();

    if (nip != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los NIP no coinciden')),
      );
      return;
    }

    final emailValido = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
    if (!emailValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo inválido')),
      );
      return;
    }

    try {
      await firestore.crearUsuario(
        _numControl.text.trim(),
        {
          'numControl': _numControl.text.trim(),
          'nip': nip,
          'nombre': _nombre.text.trim(),
          'email': email,
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
        MaterialPageRoute(builder: (context) => const InicioSesion()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
