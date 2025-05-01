import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'ubicacion.dart'; // Asegúrate de importar tu clase Ubicacion

class RutasOfrecidas extends StatelessWidget {
  final List<Map<String, dynamic>> rutas = [
    {
      'ruta': 'RUTA: GUSTAVO DÍAZ ORDAZ',
      'conductor': 'Luis Ángel Maldonado Reyes',
      'email': 'luisangel@rutas.edu.mx',
      'telefono': '618-222-5009',
      'horario': 'Lunes a Jueves de 13:00 PM a 14:00 PM',
      'precio': 30,
      'lat': 24.0409364620994,
      'lng': -104.69581942452406,
    },
    {
      'ruta': 'RUTA: COLINAS DEL SALITITO',
      'conductor': 'Luis Enrique García Madrigal',
      'email': 'luisegm@rutas.edu.mx',
      'telefono': '618-323-5009',
      'horario': '7:00 AM - 10:00 AM',
      'precio': 15,
      'lat': 24.040085364260186,
      'lng': -104.69360344795389,
    },
    {
      'ruta': 'RUTA: BOSQUES DEL VALLE',
      'conductor': 'José Manuel Ibarra Sánchez',
      'email': 'joseibarra@rutas.edu.mx',
      'telefono': '618-113-5090',
      'horario': '7:00 AM - 10:00 AM',
      'precio': 27,
      'lat': 24.045638670770572,
      'lng': -104.69519865601404,
    },
    {
      'ruta': 'RUTA: JARDINES',
      'conductor': 'Martín Dorian Arroyo',
      'email': 'martinarroyo@rutas.edu.mx',
      'telefono': '618-999-1212',
      'horario': '7:00 AM - 10:00 AM',
      'precio': 100,
      'lat': 24.051578966219676,
      'lng': -104.6935010460035,
    },
    {
      'ruta': 'RUTA: JOYAS DEL VALLE',
      'conductor': 'Jorge Ramírez Duarte',
      'email': 'jorgeramirez@rutas.edu.mx',
      'telefono': '618-103-9090',
      'horario': '7:00 AM - 10:00 AM',
      'precio': 53,
      'lat': 24.04303129543229,
      'lng': -104.69710006029678,
    },
  ];

  final Color raitecBlue = const Color(0xFF0D66D0);

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
            Image.asset(
              'assets/logoAppbar.png',
              height: 30,
            ),
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
      body: ListView.builder(
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
                            destino: LatLng(ruta['lat'], ruta['lng']),
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
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: raitecBlue,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.arrow_back, color: Colors.white),
              Icon(Icons.home, color: Colors.white),
              Icon(Icons.search, color: Colors.white),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: raitecBlue,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
