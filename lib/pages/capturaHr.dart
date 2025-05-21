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
  final TextEditingController _nombreRutaController = TextEditingController();
  final TextEditingController _asientosController = TextEditingController();
  LatLng? origenSeleccionado;
  final LatLng destinoFijo =
      const LatLng(24.03265897848829, -104.64678790491564);

  final List<String> dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  Map<String, bool> diasActivos = {};
  Map<String, TimeOfDay> horaInicio = {};

  @override
  void initState() {
    super.initState();
    for (var dia in dias) {
      diasActivos[dia] = false;
      horaInicio[dia] = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  Future<void> _seleccionarUbicacion() async {
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

  Future<void> _seleccionarHora(String dia) async {
    final TimeOfDay? seleccionada = await showTimePicker(
      context: context,
      initialTime: horaInicio[dia]!,
    );
    if (seleccionada != null) {
      setState(() {
        horaInicio[dia] = seleccionada;
      });
    }
  }

  Future<void> _guardarRuta() async {
    final clave = SessionManager().numControl;
    if (!_formKey.currentState!.validate() ||
        origenSeleccionado == null ||
        clave == null ||
        clave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Por favor completa todos los campos y selecciona una ubicación')),
      );
      return;
    }

    final diasSeleccionados = dias.where((dia) => diasActivos[dia]!).map((dia) {
      return {
        'dia': dia,
        'horaInicio': horaInicio[dia]!.format(context),
      };
    }).toList();

    if (diasSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un día y hora')),
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
        'nombreRuta': _nombreRutaController.text.trim(),
        'lugaresDisponibles': int.parse(_asientosController.text),
        'origen': {
          'lat': origenSeleccionado!.latitude,
          'lng': origenSeleccionado!.longitude,
        },
        'destino': {
          'lat': destinoFijo.latitude,
          'lng': destinoFijo.longitude,
        },
        'horarios': diasSeleccionados,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruta guardada exitosamente')),
      );

      _nombreRutaController.clear();
      _asientosController.clear();
      setState(() {
        origenSeleccionado = null;
        for (var d in dias) {
          diasActivos[d] = false;
          horaInicio[d] = const TimeOfDay(hour: 9, minute: 0);
        }
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
                controller: _nombreRutaController,
                decoration: const InputDecoration(
                    labelText: 'Nombre de la ruta (Ejemplo: Jardines)'),
                validator: (value) =>
                    value!.isEmpty ? 'Escribe un nombre para la ruta' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _asientosController,
                decoration: const InputDecoration(
                    labelText: 'Asientos traseros disponibles'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Escribe los asientos' : null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: dias.map((dia) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          title: Text(dia),
                          value: diasActivos[dia]!,
                          onChanged: (bool value) {
                            setState(() {
                              diasActivos[dia] = value;
                            });
                          },
                        ),
                        if (diasActivos[dia]!)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                const Text('Hora de entrada:'),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () => _seleccionarHora(dia),
                                  child: Text(horaInicio[dia]!.format(context)),
                                ),
                              ],
                            ),
                          ),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _seleccionarUbicacion,
                icon: const Icon(Icons.location_pin),
                label: Text(origenSeleccionado == null
                    ? 'Seleccionar punto de partida'
                    : 'Ubicación seleccionada'),
              ),
              const SizedBox(height: 16),
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