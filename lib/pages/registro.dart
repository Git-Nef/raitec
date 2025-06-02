import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raitec/pages/FirestoreService.dart';
import 'package:raitec/pages/InicioSesion.dart';

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

  bool _mostrarNip = false;
  bool _mostrarConfirmNip = false;

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

  Future<void> seleccionarImagen(String tipo) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? imagen = await picker.pickImage(source: ImageSource.camera);
                  if (imagen != null) await _subirImagen(imagen, tipo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
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
    final ref = FirebaseStorage.instance.ref().child('usuarios/$tipo/$nombreArchivo');
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

  void _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await firestore.crearUsuario(
        _numControl.text.trim(),
        {
          'numControl': _numControl.text.trim(),
          'nip': _nip.text.trim(),
          'nombre': _nombre.text.trim(),
          'email': _email.text.trim(),
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
        MaterialPageRoute(builder: (_) => const InicioSesion()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/logoAppbar.png', height: 140),
                const SizedBox(height: 10),
                Text('Registro de Usuario',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _input('Número de Control', _numControl),
                _input('NIP', _nip,
                    obscure: !_mostrarNip,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'El NIP es obligatorio';
                      if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*]).{8,}$').hasMatch(value)) {
                        return 'Debe tener 8 caracteres, mayúscula, número y símbolo';
                      }
                      return null;
                    },
                    icon: _nipVisibilityToggle()),
                _input('Confirmar NIP', _confirmNip,
                    obscure: !_mostrarConfirmNip,
                    validator: (value) {
                      if (value != _nip.text) return 'Los NIP no coinciden';
                      return null;
                    },
                    icon: _confirmNipVisibilityToggle()),
                _input('Nombre Completo', _nombre),
                _input('Correo Electrónico', _email,
                    keyboard: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Correo requerido';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Correo inválido';
                      }
                      return null;
                    }),
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
                const SizedBox(height: 20),
                _uploadButton('SUBIR FOTO DE PERFIL O INE', 'foto'),
                if (fotografiaUrl != null) Image.network(fotografiaUrl!, height: 120),
                const SizedBox(height: 24),
                _uploadButton('SUBIR FIRMA DIGITAL O ESCANEADA', 'firma'),
                if (firmaUrl != null) Image.network(firmaUrl!, height: 80),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: camposCompletos ? const Color(0xFF0D66D0) : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: camposCompletos ? _registrarUsuario : null,
                    child: Text(
                      'REGISTRARME',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '¿Ya tienes cuenta? ',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                    children: [
                      TextSpan(
                        text: 'Inicia sesión',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF0D66D0),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const InicioSesion()),
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
      {bool obscure = false,
        TextInputType keyboard = TextInputType.text,
        String? Function(String?)? validator,
        Widget? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (_) => actualizarEstado(),
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[850],
          suffixIcon: icon,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF0D66D0)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _uploadButton(String texto, String tipo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => seleccionarImagen(tipo),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D66D0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            texto,
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _nipVisibilityToggle() => IconButton(
    icon: Icon(_mostrarNip ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
    onPressed: () => setState(() => _mostrarNip = !_mostrarNip),
  );

  Widget _confirmNipVisibilityToggle() => IconButton(
    icon: Icon(_mostrarConfirmNip ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
    onPressed: () => setState(() => _mostrarConfirmNip = !_mostrarConfirmNip),
  );
}
