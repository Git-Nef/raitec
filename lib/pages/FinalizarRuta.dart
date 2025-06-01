import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raitec/pages/sesion.dart';

class FinalizarRuta extends StatefulWidget {
  const FinalizarRuta({super.key});

  @override
  State<FinalizarRuta> createState() => _FinalizarRutaState();
}

class _FinalizarRutaState extends State<FinalizarRuta> {
  final String uidConductor = SessionManager().numControl ?? '';
  bool finalizando = false;
  Map<String, dynamic>? datosRuta;

  @override
  void initState() {
    super.initState();
    _cargarRuta();
  }

  Future<void> _cargarRuta() async {
    final rutaRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uidConductor)
        .collection('rutas')
        .doc('info');

    final snapshot = await rutaRef.get();
    if (snapshot.exists) {
      setState(() {
        datosRuta = snapshot.data();
      });
    }
  }

  Future<void> finalizarViaje() async {
    setState(() => finalizando = true);

    final pasajerosRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uidConductor)
        .collection('rutas')
        .doc('info')
        .collection('pasajeros');

    final snapshot = await pasajerosRef.get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['estado'] == 'aceptado') {
        final uidPasajero = doc.id;
        final metodoPago = data['metodoPago'];

        final conductorDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uidConductor)
            .get();
        final nombreConductor = conductorDoc.data()?['nombre'] ?? 'Desconocido';

        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uidPasajero)
            .collection('historialSolicitudes')
            .add({
          'estado': 'finalizado',
          'metodoPago': metodoPago,
          'fecha': Timestamp.now(),
          'conductor': nombreConductor,
        });
      }

      await pasajerosRef.doc(doc.id).delete();
    }

    setState(() => finalizando = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Viaje finalizado',
              style: GoogleFonts.poppins(color: Colors.white)),
          content: Text('Los pasajeros fueron archivados en el historial.',
              style: GoogleFonts.poppins(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Aceptar', style: TextStyle(color: Color(0xFF0D66D0))),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Finalizar Ruta', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: datosRuta == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen de tu ruta:',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.greenAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Destino: ${datosRuta!['destino']['lat']}, ${datosRuta!['destino']['lng']}',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Origen: ${datosRuta!['origen']['lat']}, ${datosRuta!['origen']['lng']}',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text('¿Deseas finalizar esta ruta?',
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.white)),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: finalizando ? null : finalizarViaje,
                icon: finalizando
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.flag),
                label: Text(
                  finalizando ? 'Finalizando...' : 'Finalizar viaje',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D66D0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
