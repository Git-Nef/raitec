import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:raitec/pages/MisSolicitudes.dart';
import 'package:raitec/pages/sesion.dart';
import 'ubicacion.dart';

class RutasOfrecidas extends StatefulWidget {
  const RutasOfrecidas({super.key});

  @override
  State<RutasOfrecidas> createState() => _RutasOfrecidasState();
}

class _RutasOfrecidasState extends State<RutasOfrecidas> {
  final Color raitecBlue = const Color(0xFF0D66D0);
  List<Map<String, dynamic>> rutas = [];
  List<Map<String, dynamic>> rutasFiltradas = [];

  final TextEditingController _busquedaController = TextEditingController();
  String filtroCP = 'Todos';
  List<String> listaCP = ['Todos'];

  @override
  void initState() {
    super.initState();
    _cargarRutasDesdeFirestore();
  }

  Future<void> _cargarRutasDesdeFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('usuarios').get();
    List<Map<String, dynamic>> rutasTemp = [];
    Set<String> cps = {};

    for (var doc in snapshot.docs) {
      final rutasRef = doc.reference.collection('rutas').doc('info');
      final rutaDoc = await rutasRef.get();
      if (!rutaDoc.exists) continue;

      final data = rutaDoc.data()!;
      final origen = data['origen'];
      final destino = data['destino'];
      final horarios = data['horarios'] as List<dynamic>?;
      final lugares = data['lugaresDisponibles'] ?? 0;
      final nombreRuta = data['nombreRuta'] ?? 'Sin nombre';

      if (origen == null || destino == null || horarios == null) continue;

      final horarioTexto = horarios.map((h) => '${h['dia']} (${h['horaInicio']})').join(', ');

      String direccion = 'Desconocida';
      String cp = 'N/A';
      try {
        final placemarks = await placemarkFromCoordinates(origen['lat'], origen['lng']);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          direccion = '${place.street}, ${place.locality}';
          cp = place.postalCode ?? 'N/A';
        }
      } catch (_) {}

      cps.add(cp);

      rutasTemp.add({
        'ruta': nombreRuta,
        'nombreConductor': doc.data()['nombre'] ?? 'Sin nombre',
        'email': doc.data()['email'] ?? 'Sin correo',
        'telefono': doc.data()['telefono'] ?? 'Sin número',
        'horario': horarioTexto,
        'precio': 25,
        'origen': LatLng(origen['lat'], origen['lng']),
        'destino': LatLng(destino['lat'], destino['lng']),
        'lugaresDisponibles': lugares,
        'direccion': direccion,
        'codigoPostal': cp,
        'rutaId': rutasRef.id,
        'uidConductor': doc.id,
      });
    }

    setState(() {
      rutas = rutasTemp;
      rutasFiltradas = rutasTemp;
      listaCP = ['Todos', ...cps.toList()..sort()];
    });
  }

  void _filtrarRutas() {
    final query = _busquedaController.text.toLowerCase();
    setState(() {
      rutasFiltradas = rutas.where((ruta) {
        final nombre = ruta['ruta'].toString().toLowerCase();
        final conductor = ruta['nombreConductor'].toString().toLowerCase();
        final direccion = ruta['direccion'].toString().toLowerCase();
        final cp = ruta['codigoPostal'].toString();
        final matchTexto = nombre.contains(query) || conductor.contains(query) || direccion.contains(query);
        final matchCP = (filtroCP == 'Todos' || cp == filtroCP);
        return matchTexto && matchCP;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Rutas Disponibles',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _busquedaController,
              onChanged: (_) => _filtrarRutas(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar ruta, conductor o dirección...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              dropdownColor: Colors.grey[900],
              value: filtroCP,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_pin, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[850],
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              style: const TextStyle(color: Colors.white),
              items: listaCP.map((cp) {
                return DropdownMenuItem(
                  value: cp,
                  child: Text(cp == 'Todos' ? 'Todos los Códigos Postales' : cp),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                filtroCP = val;
                _filtrarRutas();
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: rutasFiltradas.isEmpty
                ? Center(
              child: Text('No hay rutas que mostrar.',
                  style: GoogleFonts.poppins(color: Colors.white70)),
            )
                : ListView.builder(
              itemCount: rutasFiltradas.length,
              itemBuilder: (context, index) {
                final ruta = rutasFiltradas[index];
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ruta['ruta'],
                          style: GoogleFonts.poppins(
                            color: raitecBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _infoRow(Icons.person, ruta['nombreConductor'], Colors.white),
                        _infoRow(Icons.email, ruta['email'], Colors.white),
                        _infoRow(Icons.phone, ruta['telefono'], Colors.white),
                        _infoRow(Icons.schedule, ruta['horario'], Colors.white),
                        _infoRow(Icons.place, ruta['direccion'], Colors.white),
                        _infoRow(Icons.pin_drop, 'CP: ${ruta['codigoPostal']}', Colors.white),
                        _infoRow(Icons.event_seat,
                            'Asientos disponibles: ${ruta['lugaresDisponibles']}', Colors.white),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: ruta['lugaresDisponibles'] > 0
                              ? () {
                            final uidPasajero = SessionManager().numControl;
                            if (uidPasajero == null || uidPasajero.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Inicia sesión para pedir un rait'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Ubicacion(
                                  origen: ruta['origen'],
                                  destino: ruta['destino'],
                                  nombreRuta: ruta['ruta'],
                                  rutaId: ruta['rutaId'],
                                  uidConductor: ruta['uidConductor'],
                                  uidPasajero: uidPasajero,
                                  datosRuta: ruta,
                                ),
                              ),
                            );
                          }
                              : null,
                          icon: const Icon(Icons.map, color: Colors.white),
                          label: Text(
                            ruta['lugaresDisponibles'] > 0
                                ? "Ver ruta y pedir Rait"
                                : "Sin asientos disponibles",
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ruta['lugaresDisponibles'] > 0
                                ? raitecBlue
                                : Colors.grey.shade800,
                            disabledBackgroundColor: Colors.grey.shade700,
                            disabledForegroundColor: Colors.white70,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MisSolicitudes()));
        },
        label: Text('Solicitudes de Rait', style: GoogleFonts.poppins(color: Colors.white)),
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        backgroundColor: raitecBlue,
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
