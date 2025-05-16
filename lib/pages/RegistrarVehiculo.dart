import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrarVehiculo extends StatefulWidget {
  final String numControl;
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

  @override
  void initState() {
    super.initState();
    _cargarDatosVehiculo();
  }

  Future<void> _cargarDatosVehiculo() async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.numControl)
        .collection('vehiculo')
        .doc('info')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _marca.text = data['marca'] ?? '';
      _modelo.text = data['modelo'] ?? '';
      _anio.text = data['anio'] ?? '';
      _matricula.text = data['matricula'] ?? '';
      _color.text = data['color'] ?? '';
      _seguro.text = data['seguro'] ?? '';
      _asientos.text = data['asientos'] ?? '';
      _caracteristicas.text = data['caracteristicas'] ?? '';
      setState(() {
        fotoUrl = data['fotoUrl'];
      });
    }
  }

  Future<void> _seleccionarFoto(bool desdeCamara) async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: desdeCamara ? ImageSource.camera : ImageSource.gallery,
    );

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

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.numControl)
          .update({'esConductor': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo guardado correctamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  bool get camposCompletos {
    return _marca.text.trim().isNotEmpty &&
        _modelo.text.trim().isNotEmpty &&
        _anio.text.trim().isNotEmpty &&
        _matricula.text.trim().isNotEmpty &&
        _color.text.trim().isNotEmpty &&
        _seguro.text.trim().isNotEmpty &&
        _asientos.text.trim().isNotEmpty &&
        _caracteristicas.text.trim().isNotEmpty &&
        fotoUrl != null;
  }

  void actualizarEstado() => setState(() {});

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        onChanged: (_) => actualizarEstado(),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Registrar Vehículo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16), // Espacio para evitar empalme
                _input('Marca', _marca),
                _input('Modelo', _modelo),
                _input('Año', _anio),
                _input('Matrícula', _matricula),
                _input('Color', _color),
                _input('Seguro', _seguro),
                _input('Número de Asientos', _asientos),
                _input('Características', _caracteristicas),
                const SizedBox(height: 20),
                const Text(
                  'Fotografía del auto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined, size: 20),
                        label: const Text('Cámara'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _seleccionarFoto(true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.image_outlined, size: 20),
                        label: const Text('Galería'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _seleccionarFoto(false),
                      ),
                    ),
                  ],
                ),
                if (fotoUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(fotoUrl!, height: 160),
                    ),
                  ),
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: 220,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: camposCompletos ? guardarVehiculo : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: camposCompletos
                            ? Colors.blueAccent
                            : Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: camposCompletos ? 3 : 0,
                      ),
                      child: const Text(
                        'Guardar vehículo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80), // Espacio final para evitar empalme inferior
              ],
            ),
          ),
        ),
      ),
    );
  }
}
