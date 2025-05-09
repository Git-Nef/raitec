import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'ubicacion.dart';

class RutasOfrecidas extends StatefulWidget {
  const RutasOfrecidas({super.key});

  @override
  State<RutasOfrecidas> createState() => _RutasOfrecidasState();
}

class _RutasOfrecidasState extends State<RutasOfrecidas> {
  final Color raitecBlue = const Color(0xFF0D66D0);
  List<Map<String, dynamic>> rutas = [];

  @override
  void initState() {
    super.initState();
    _cargarRutasDesdeFirestore();
  }

  Future<void> _cargarRutasDesdeFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('usuarios').get();

    List<Map<String, dynamic>> rutasTemp = [];

    for (var doc in snapshot.docs) {
      final rutasRef = doc.reference.collection('rutas').doc('info');
      final rutaDoc = await rutasRef.get();

      if (rutaDoc.exists) {
        final data = rutaDoc.data()!;
        final destino = data['destino'];
        final origen = data['origen'];

        rutasTemp.add({
          'ruta': 'RUTA DE ${doc.id}',
          'conductor': doc.data()['nombre'] ?? 'Sin nombre',
          'email': doc.data()['email'] ?? 'Sin correo',
          'telefono': doc.data()['telefono'] ?? 'Sin número',
          'horario': data['dias'] != null && data['horaEntrada'] != null
              ? '${data['dias']} - ${data['horaEntrada']}'
              : 'Horario no disponible',
          'precio': 25, // Puedes cambiarlo si tienes este campo en Firestore
          'origen': LatLng(origen['lat'], origen['lng']),
          'destino': LatLng(destino['lat'], destino['lng']),
        });
      }
    }

    setState(() {
      rutas = rutasTemp;
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
      body: rutas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: rutas.length,
        itemBuilder: (context, index) {
          final ruta = rutas[index];
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
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Ubicacion(
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
                          borderRadius: BorderRadius.circular(12)),
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
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 28, color: Colors.blueGrey),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.home_filled,
                    size: 30, color: Colors.blueAccent),
                onPressed: () {
                  Navigator.pop(context);
                },
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
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
