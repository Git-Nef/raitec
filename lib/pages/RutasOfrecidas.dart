import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:raitec/pages/MisSolicitudes.dart';
import 'package:raitec/pages/sesion.dart';
import 'package:raitec/pages/unirseRuta.dart';
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
    final snapshot =
        await FirebaseFirestore.instance.collection('usuarios').get();
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
      final lugares = data['lugaresDisponibles'];
      final nombreRuta = data['nombreRuta'] ?? 'Sin nombre';

      if (origen == null || destino == null || horarios == null) continue;

      final horarioTexto = horarios.map((h) {
        return '${h['dia']} (${h['horaInicio']})';
      }).join(', ');

      String direccion = 'Desconocida';
      String cp = 'N/A';
      try {
        final placemarks = await placemarkFromCoordinates(
          origen['lat'],
          origen['lng'],
        );
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
        'lugaresDisponibles': lugares ?? 0,
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
        final matchTexto = nombre.contains(query) ||
            conductor.contains(query) ||
            direccion.contains(query);
        final matchCP = (filtroCP == 'Todos' || cp == filtroCP);
        return matchTexto && matchCP;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logoAppbar.png', height: 30),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [raitecBlue, Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'Rutas Disponibles',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _busquedaController,
              onChanged: (_) => _filtrarRutas(),
              decoration: InputDecoration(
                hintText: 'Buscar ruta, conductor o dirección...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.location_pin, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: filtroCP,
                    items: listaCP.map((cp) {
                      return DropdownMenuItem(
                        value: cp,
                        child: Text(
                            cp == 'Todos' ? 'Todos los Códigos Postales' : cp),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      filtroCP = val;
                      _filtrarRutas();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: rutasFiltradas.isEmpty
                ? const Center(child: Text('No hay rutas que mostrar.'))
                : ListView.builder(
                    itemCount: rutasFiltradas.length,
                    itemBuilder: (context, index) {
                      final ruta = rutasFiltradas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ruta['ruta'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: raitecBlue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _infoRow(Icons.person, ruta['nombreConductor'],
                                  Colors.blueGrey),
                              _infoRow(
                                  Icons.email, ruta['email'], Colors.redAccent),
                              _infoRow(
                                  Icons.phone, ruta['telefono'], Colors.green),
                              _infoRow(Icons.schedule, ruta['horario'],
                                  Colors.orange),
                              _infoRow(
                                  Icons.place, ruta['direccion'], Colors.teal),
                              _infoRow(Icons.pin_drop,
                                  'CP: ${ruta['codigoPostal']}', Colors.brown),
                              _infoRow(
                                  Icons.event_seat,
                                  'Asientos disponibles: ${ruta['lugaresDisponibles']}',
                                  Colors.purple),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        final uidPasajero =
                                            SessionManager().numControl;
                                        if (uidPasajero == null ||
                                            uidPasajero.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Inicia sesión para pedir un rait')),
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
                                              uidConductor:
                                                  ruta['uidConductor'],
                                              uidPasajero: uidPasajero,
                                              datosRuta: ruta,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.map),
                                      label:
                                          const Text("Ver ruta y pedir Rait"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: raitecBlue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${ruta['precio']} MXN',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.map, color: raitecBlue),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.location_on,
                                          color: Colors.redAccent),
                                    ],
                                  ),
                                ],
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MisSolicitudes()),
          );
        },
        label: const Text('Solicitudes de Rait'),
        icon: const Icon(Icons.receipt_long),
        backgroundColor: Colors.blueAccent[500],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}