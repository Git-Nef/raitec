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
          content: Text('Completa todos los campos y selecciona una ubicación'),
        ),
      );
      return;
    }

    final horariosSeleccionados = {
      for (var dia in dias)
        if (diasActivos[dia] == true)
          dia: {
            'horaInicio': horaInicio[dia]!.format(context),
          }
    };

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
        'horarios': horariosSeleccionados,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruta guardada exitosamente')),
      );

      _asientosController.clear();
      setState(() {
        origenSeleccionado = null;
        for (var d in dias) diasActivos[d] = false;
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Capturar Horario de Ruta'),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreRutaController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la ruta ejemplo: (Jardines)',
                ),
                validator: (value) =>
                value!.isEmpty ? 'Escribe un nombre para la ruta' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _asientosController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Asientos traseros disponibles',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Escribe los asientos' : null,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: dias.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    final dia = dias[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          title: Text(dia, style: const TextStyle(color: Colors.white)),
                          value: diasActivos[dia]!,
                          onChanged: (bool value) {
                            setState(() {
                              diasActivos[dia] = value;
                            });
                          },
                          activeColor: Colors.white,
                        ),
                        if (diasActivos[dia]!)
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Row(
                              children: [
                                const Text('Inicio:',
                                    style: TextStyle(color: Colors.white70)),
                                const SizedBox(width: 10),
                                TextButton.icon(
                                  onPressed: () => _seleccionarHora(dia),
                                  icon: const Icon(Icons.access_time, size: 20, color: Colors.white),
                                  label: Text(
                                    horaInicio[dia]!.format(context),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _seleccionarUbicacion,
                icon: const Icon(Icons.place_outlined, size: 20, color: Colors.white),
                label: Text(
                  origenSeleccionado == null
                      ? 'Seleccionar punto de partida'
                      : 'Ubicación seleccionada',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _guardarRuta,
                icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.white),
                label: const Text(
                  'Guardar ruta',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
