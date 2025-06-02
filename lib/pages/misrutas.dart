import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raitec/pages/sesion.dart';
import 'package:raitec/pages/capturaHr.dart';
import 'package:raitec/pages/PasajerosPendientes.dart';

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
      nombreRuta = data['nombreRuta'] ?? 'Ruta Programada';

      if (horarios != null && horarios.isNotEmpty) {
        horarioTexto = horarios.map((h) {
          return '${h['dia']} (${h['horaInicio']})';
        }).join(', ');
      } else {
        horarioTexto = 'Sin horarios registrados';
      }

      final origenPlacemark = await placemarkFromCoordinates(origen['lat'], origen['lng']);
      final destinoPlacemark = await placemarkFromCoordinates(destino['lat'], destino['lng']);

      setState(() {
        rutaData = data;
        direccionOrigen = '${origenPlacemark.first.street}, ${origenPlacemark.first.locality}';
        direccionDestino = '${destinoPlacemark.first.street}, ${destinoPlacemark.first.locality}';
      });
    }
  }

  Widget _rutaCard(String nombre, String origenTxt, String destinoTxt, String horariosTxt, int lugares) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nombre, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent, size: 22),
                const SizedBox(width: 8),
                Expanded(child: Text(origenTxt, style: GoogleFonts.poppins(color: Colors.white70))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.greenAccent, size: 22),
                const SizedBox(width: 8),
                Expanded(child: Text(destinoTxt, style: GoogleFonts.poppins(color: Colors.white70))),
              ],
            ),
            const Divider(color: Colors.white24, height: 30),
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white60),
                const SizedBox(width: 8),
                Expanded(child: Text('Horarios: $horariosTxt', style: GoogleFonts.poppins(color: Colors.white))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event_seat, color: Colors.white60),
                const SizedBox(width: 8),
                Text('Asientos disponibles: $lugares', style: GoogleFonts.poppins(color: Colors.white)),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text('Mis Rutas', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿No tienes ninguna ruta registrada?\nLlena el siguiente formulario.',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CapturarHorarioRuta()));
              },
              icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
              label: Text('REGISTRAR RUTA', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D66D0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            Text('Tus Rutas', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (rutaData != null && direccionOrigen != null && direccionDestino != null) ...[
              _rutaCard(nombreRuta, direccionOrigen!, direccionDestino!, horarioTexto, lugaresDisponibles),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PasajerosPendientes()));
                },
                icon: const Icon(Icons.group, color: Colors.white),
                label: Text('Ver Pasajeros', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D66D0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ] else
              Center(
                child: Text("No tienes rutas registradas.", style: GoogleFonts.poppins(color: Colors.white70)),
              ),
          ],
        ),
      ),
    );
  }
}
