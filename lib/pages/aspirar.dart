import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raitec/pages/RegistrarVehiculo.dart';
import 'package:raitec/pages/FirestoreService.dart';
import 'package:google_fonts/google_fonts.dart';

class Aspirar extends StatefulWidget {
  final String numControl;
  const Aspirar({super.key, required this.numControl});

  @override
  State<Aspirar> createState() => _AspirarState();
}

class _AspirarState extends State<Aspirar> {
  final firestore = FirestoreService();

  Future<void> _subirArchivo(String tipo, bool desdeCamara) async {
    final picker = ImagePicker();
    final XFile? archivo = await picker.pickImage(
      source: desdeCamara ? ImageSource.camera : ImageSource.gallery,
    );

    if (archivo == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('usuarios/${widget.numControl}/documentos/$tipo.jpg');

    await ref.putFile(File(archivo.path));
    final url = await ref.getDownloadURL();

    await firestore.subirDocumento(widget.numControl, tipo, url);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('Documento "$tipo" subido correctamente',
            style: GoogleFonts.poppins(color: Colors.white)),
      ),
    );
  }

  void _mostrarOpcionesImagen(String tipo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.white),
                title: Text('Tomar foto', style: GoogleFonts.poppins(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _subirArchivo(tipo, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: Text('Elegir de galería', style: GoogleFonts.poppins(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _subirArchivo(tipo, false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/SplashScreen.png', height: 220),
                const SizedBox(height: 30),
                const Icon(Icons.file_upload_rounded, size: 64, color: Colors.white),
                const SizedBox(height: 20),
                _uploadButton('SUBIR HORARIO', 'horario'),
                _uploadButton('SUBIR KARDEX', 'kardex'),
                _uploadButton('SUBIR LICENCIA DE CONDUCIR', 'licencia'),
                _uploadButton('SUBIR COMPROBANTE DE DOMICILIO', 'comprobante_domicilio'),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegistrarVehiculo(numControl: widget.numControl),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D66D0),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'CONTINUAR A INFORMACIÓN DEL VEHÍCULO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
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
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () {
                // Acción de ayuda
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
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

  Widget _uploadButton(String texto, String tipo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _mostrarOpcionesImagen(tipo),
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label: Text(
            texto,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
