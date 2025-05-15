import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
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
      final lugares = data['lugaresDisponibles'];
      final nombreRuta = data['nombreRuta'] ?? 'Sin nombre';

      if (origen == null || destino == null || horarios == null) continue;
      final horarioTexto = horarios.map((h) {
        return '${h['dia']} (${h['horaInicio']})';
      }).join(', ');

      String direccion = 'Desconocida';
      String cp = 'N/A';
      try {
        final placemarks =
        await placemarkFromCoordinates(origen['lat'], origen['lng']);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          direccion = '${place.street}, ${place.locality}';
          cp = place.postalCode ?? 'N/A';
        }
      } catch (e) {
        // Ignorar error de geocoding y usar valores por defecto
      }
      cps.add(cp);

      rutasTemp.add({
        'ruta': nombreRuta,
        'conductor': doc.data()['nombre'] ?? 'Sin nombre',
        'email': doc.data().containsKey('email') ? doc.data()['email'] : 'Sin correo',
        'telefono': doc.data()['telefono'] ?? 'Sin número',
        'horario': horarioTexto,
        'precio': 25,
        'origen': LatLng(origen['lat'], origen['lng']),
        'destino': LatLng(destino['lat'], destino['lng']),
        'lugaresDisponibles': lugares ?? 0,
        'direccion': direccion,
        'codigoPostal': cp,
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
        final conductor = ruta['conductor'].toString().toLowerCase();
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
          // Barra de búsqueda
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

          // Dropdown de Código Postal
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
                    items: listaCP
                        .map((cp) => DropdownMenuItem(
                      value: cp,
                      child: Text(cp == 'Todos' ? 'Todos los Códigos Postales' : cp),
                    ))
                        .toList(),
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

          // Lista de rutas
          Expanded(
            child: rutasFiltradas.isEmpty
                ? const Center(child: Text('No hay rutas que mostrar.'))
                : ListView.builder(
              itemCount: rutasFiltradas.length,
              itemBuilder: (context, index) {
                final ruta = rutasFiltradas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
                        _infoRow(Icons.person, ruta['conductor'], Colors.blueGrey),
                        _infoRow(Icons.email, ruta['email'], Colors.redAccent),
                        _infoRow(Icons.phone, ruta['telefono'], Colors.green),
                        _infoRow(Icons.schedule, ruta['horario'], Colors.orange),
                        _infoRow(Icons.place, ruta['direccion'], Colors.teal),
                        _infoRow(Icons.pin_drop,
                            'CP: ${ruta['codigoPostal']}', Colors.brown),
                        _infoRow(Icons.event_seat,
                            'Asientos disponibles: ${ruta['lugaresDisponibles']}',
                            Colors.purple),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Ubicacion(
                                  origen: ruta['origen'],
                                  destino: ruta['destino'],
                                  nombreRuta: ruta['ruta'],
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.map, color: raitecBlue),
                          label: const Text("Ver ruta en mapa"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: raitecBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon:
                const Icon(Icons.arrow_back_ios_new, size: 28, color: Colors.blueGrey),
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                icon:
                const Icon(Icons.home_filled, size: 30, color: Colors.blueAccent),
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              ),
              const SizedBox(width: 28),
            ],
          ),
        ),
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
