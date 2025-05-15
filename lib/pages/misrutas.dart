import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:raitec/pages/sesion.dart';
import 'capturaHr.dart';

class MisRutas extends StatefulWidget {
  const MisRutas({super.key});

  @override
  State<MisRutas> createState() => _MisRutasState();
}

class _MisRutasState extends State<MisRutas> {
  String? direccionOrigen;
  String? direccionDestino;
  Map<String, dynamic>? rutaData;
  String horarioTexto = '';
  int lugaresDisponibles = 0;
  String nombreRuta = 'Sin nombre';

  @override
  void initState() {
    super.initState();
    _obtenerRuta();
  }

  Future<void> _obtenerRuta() async {
    final clave = SessionManager().numControl;
    if (clave == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(clave)
        .collection('rutas')
        .doc('info')
        .get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      final origen = data['origen'];
      final destino = data['destino'];
      final horarios = data['horarios'] as List<dynamic>?;
      lugaresDisponibles = data['lugaresDisponibles'] ?? 0;
      nombreRuta = data['nombreRuta'] ?? 'Sin nombre';

      if (horarios != null) {
        horarioTexto = horarios.map((h) {
          return '${h['dia']} (${h['horaInicio']})';
        }).join(', ');
      } else {
        horarioTexto = 'Sin horarios registrados';
      }

      final origenPlacemark =
      await placemarkFromCoordinates(origen['lat'], origen['lng']);
      final destinoPlacemark =
      await placemarkFromCoordinates(destino['lat'], destino['lng']);

      setState(() {
        rutaData = data;
        direccionOrigen =
        '${origenPlacemark.first.street}, ${origenPlacemark.first.locality}';
        direccionDestino =
        '${destinoPlacemark.first.street}, ${destinoPlacemark.first.locality}';
      });
    }
  }

  Widget _rutaCard(String nombre, String origenTxt, String destinoTxt,
      String horariosTxt, int lugares) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D66D0),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                    child:
                    Text(origenTxt, style: const TextStyle(fontSize: 14))),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                    child:
                    Text(destinoTxt, style: const TextStyle(fontSize: 14))),
              ],
            ),
            const Divider(height: 25),
            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Expanded(child: Text('Horarios: $horariosTxt')),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.event_seat),
                const SizedBox(width: 8),
                Text('Asientos disponibles: $lugares'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Image.asset('assets/logoAppbar.png', height: 140),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '¿No tienes ninguna ruta registrada?\nLlena el siguiente formulario.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CapturarHorarioRuta()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D66D0),
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 6,
              ),
              child: const Text(
                'REGISTRAR RUTA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 35),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'TUS RUTAS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (rutaData != null &&
                direccionOrigen != null &&
                direccionDestino != null)
              _rutaCard(
                nombreRuta,
                direccionOrigen!,
                direccionDestino!,
                horarioTexto,
                lugaresDisponibles,
              )
            else
              const Text("No tienes rutas registradas."),
          ],
        ),
      ),
    );
  }
}
