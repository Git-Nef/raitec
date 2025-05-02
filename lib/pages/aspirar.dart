import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raitec/pages/RegistrarVehiculo.dart';
import 'package:raitec/pages/FirestoreService.dart';

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
      SnackBar(content: Text('Documento "$tipo" subido correctamente')),
    );
  }

  void _mostrarOpcionesImagen(String tipo) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _subirArchivo(tipo, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de galería'),
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
                _uploadButton('SUBIR HORARIO', 'horario'),
                _uploadButton('SUBIR KARDEX', 'kardex'),
                _uploadButton('SUBIR LICENCIA DE CONDUCIR', 'licencia'),
                _uploadButton(
                    'SUBIR COMPROBANTE DE DOMICILIO', 'comprobante_domicilio'),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RegistrarVehiculo(numControl: widget.numControl),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'CONTINUAR A INFORMACIÓN DEL VEHÍCULO',
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

  Widget _uploadButton(String texto, String tipo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _mostrarOpcionesImagen(tipo),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            texto,
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
