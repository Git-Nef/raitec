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
      SnackBar(
        content: Text('Documento "$tipo" subido correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarOpcionesImagen(String tipo) {
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
                onTap: () {
                  Navigator.pop(context);
                  _subirArchivo(tipo, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Elegir de galería', style: TextStyle(color: Colors.white)),
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

  Widget _uploadButton(String texto, String tipo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ElevatedButton.icon(
        onPressed: () => _mostrarOpcionesImagen(tipo),
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: Text(
          texto,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
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
              children: [
                Image.asset(
                  'assets/SplashScreen.png',
                  height: 200,
                ),
                const SizedBox(height: 30),
                const Icon(Icons.cloud_upload_rounded, size: 60, color: Colors.white),
                const SizedBox(height: 20),
                _uploadButton('Subir Horario', 'horario'),
                _uploadButton('Subir Kardex', 'kardex'),
                _uploadButton('Subir Licencia de Conducir', 'licencia'),
                _uploadButton('Subir Comprobante de Domicilio', 'comprobante_domicilio'),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RegistrarVehiculo(numControl: widget.numControl),
                      ),
                    );
                  },
                  label: const Text(
                    'Continuar a Vehículo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () {
                // Acción de ayuda
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.all(14),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.help_outline, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
