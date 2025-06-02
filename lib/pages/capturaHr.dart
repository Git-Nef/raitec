import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final LatLng destinoFijo = const LatLng(24.03265897848829, -104.64678790491564);

  final List<String> dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
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
      setState(() => origenSeleccionado = resultado);
    }
  }

  Future<void> _seleccionarHora(String dia) async {
    final TimeOfDay? seleccionada = await showTimePicker(
      context: context,
      initialTime: horaInicio[dia]!,
    );
    if (seleccionada != null) {
      setState(() => horaInicio[dia] = seleccionada);
    }
  }

  Future<void> _guardarRuta() async {
    final clave = SessionManager().numControl;
    if (!_formKey.currentState!.validate() ||
        origenSeleccionado == null ||
        clave == null ||
        clave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos y selecciona una ubicación')),
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

    try {
      final int asientos = int.parse(_asientosController.text);
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(clave)
          .collection('rutas')
          .doc('info')
          .set({
        'nombreRuta': _nombreRutaController.text.trim(),
        'lugaresDisponibles': asientos,
        'lugaresTotales': asientos,
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Capturar Horario de Ruta',
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _inputTexto(
                controller: _nombreRutaController,
                label: 'Nombre de la ruta (Ej. Jardines)',
                validator: (v) => v!.isEmpty ? 'Escribe un nombre para la ruta' : null,
              ),
              const SizedBox(height: 12),
              _inputTexto(
                controller: _asientosController,
                label: 'Asientos traseros disponibles',
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Escribe los asientos' : null,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: dias.map((dia) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          title: Text(
                            dia,
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                          value: diasActivos[dia]!,
                          onChanged: (value) {
                            setState(() => diasActivos[dia] = value);
                          },
                          activeColor: const Color(0xFF0D66D0),
                        ),
                        if (diasActivos[dia]!)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text('Hora de entrada:',
                                    style: GoogleFonts.poppins(color: Colors.white70)),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () => _seleccionarHora(dia),
                                  child: Text(
                                    horaInicio[dia]!.format(context),
                                    style: GoogleFonts.poppins(color: const Color(0xFF0D66D0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Divider(color: Colors.white12),
                      ],
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _seleccionarUbicacion,
                icon: const Icon(Icons.location_pin, color: Colors.white),
                label: Text(
                  origenSeleccionado == null
                      ? 'Seleccionar punto de partida'
                      : 'Ubicación seleccionada',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D66D0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _guardarRuta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D66D0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Guardar ruta',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputTexto({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[850],
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF0D66D0)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
