import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrarVehiculo extends StatefulWidget {
  final String numControl; // Número de control del conductor

  const RegistrarVehiculo({super.key, required this.numControl});

  @override
  State<RegistrarVehiculo> createState() => _RegistrarVehiculoState();
}

class _RegistrarVehiculoState extends State<RegistrarVehiculo> {
  final _formKey = GlobalKey<FormState>();
  final _marca = TextEditingController();
  final _modelo = TextEditingController();
  final _anio = TextEditingController();
  final _matricula = TextEditingController();
  final _color = TextEditingController();
  final _seguro = TextEditingController();
  final _asientos = TextEditingController();
  final _caracteristicas = TextEditingController();

  String? fotoUrl;

  Future<void> seleccionarFoto() async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen == null) return;

    final nombreArchivo =
        'vehiculo-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance
        .ref()
        .child('vehiculos/${widget.numControl}/$nombreArchivo');

    await ref.putFile(File(imagen.path));
    final url = await ref.getDownloadURL();

    setState(() {
      fotoUrl = url;
    });
  }

  Future<void> guardarVehiculo() async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.numControl)
          .collection('vehiculo')
          .doc('info')
          .set({
        'marca': _marca.text.trim(),
        'modelo': _modelo.text.trim(),
        'anio': _anio.text.trim(),
        'matricula': _matricula.text.trim(),
        'color': _color.text.trim(),
        'seguro': _seguro.text.trim(),
        'asientos': _asientos.text.trim(),
        'caracteristicas': _caracteristicas.text.trim(),
        'fotoUrl': fotoUrl ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo registrado exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: \$e')),
      );
    }
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Vehículo')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _input('Marca', _marca),
                _input('Modelo', _modelo),
                _input('Año', _anio),
                _input('Matrícula', _matricula),
                _input('Color', _color),
                _input('Seguro', _seguro),
                _input('Número de Asientos', _asientos),
                _input('Características (ej. Bluetooth, aire acondicionado)',
                    _caracteristicas),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Subir Foto del Vehículo'),
                  onPressed: seleccionarFoto,
                ),
                if (fotoUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Image.network(fotoUrl!, height: 160),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: guardarVehiculo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('GUARDAR VEHÍCULO',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
