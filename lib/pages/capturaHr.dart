import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raitec/pages/seleccionarUbicacion.dart';
import 'package:raitec/pages/sesion.dart';

class CapturarHorarioRuta extends StatefulWidget {
  const CapturarHorarioRuta({super.key});

  @override
  State<CapturarHorarioRuta> createState() => _CapturarHorarioRutaState();
}

class _CapturarHorarioRutaState extends State<CapturarHorarioRuta> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _diasController = TextEditingController();
  final TextEditingController _asientosController = TextEditingController();

  LatLng? origenSeleccionado;
  final LatLng destinoFijo = const LatLng(24.03265897848829, -104.64678790491564);

  void _seleccionarUbicacion() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SeleccionarUbicacion()),
    );

    if (resultado != null && resultado is LatLng) {
      setState(() {
        origenSeleccionado = resultado;
      });
    }
  }

  Future<void> _guardarRuta() async {
    final clave = SessionManager().numControl;

    if (!_formKey.currentState!.validate() || origenSeleccionado == null || clave == null || clave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos y selecciona una ubicación')),
      );
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(clave)
        .collection('rutas')
        .doc('info');

    try {
      await docRef.set({
        'horaSalida': _horaController.text,
        'dias': _diasController.text,
        'lugaresDisponibles': int.parse(_asientosController.text),
        'origen': {
          'lat': origenSeleccionado!.latitude,
          'lng': origenSeleccionado!.longitude,
        },
        'destino': {
          'lat': destinoFijo.latitude,
          'lng': destinoFijo.longitude,
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruta guardada exitosamente')),
      );

      // Limpiar campos
      _horaController.clear();
      _diasController.clear();
      _asientosController.clear();
      setState(() {
        origenSeleccionado = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capturar horario de ruta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _diasController,
                decoration: const InputDecoration(labelText: 'Días del viaje (ej. Lunes-Viernes)'),
                validator: (value) => value!.isEmpty ? 'Escribe los días' : null,
              ),
              TextFormField(
                controller: _horaController,
                decoration: const InputDecoration(labelText: 'Hora de salida (ej. 3:00pm)'),
                validator: (value) => value!.isEmpty ? 'Escribe la hora' : null,
              ),
              TextFormField(
                controller: _asientosController,
                decoration: const InputDecoration(labelText: 'Asientos traseros disponibles'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Escribe los asientos' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _seleccionarUbicacion,
                icon: const Icon(Icons.location_pin),
                label: Text(origenSeleccionado == null
                    ? 'Seleccionar punto de partida'
                    : 'Ubicación seleccionada'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _guardarRuta,
                child: const Text('Guardar ruta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
