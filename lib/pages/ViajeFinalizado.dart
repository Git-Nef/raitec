import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:raitec/pages/PrincipalConductor.dart';
import 'package:raitec/pages/sesion.dart';

class ViajeFinalizado extends StatefulWidget {
  final String uidConductor;
  final String rutaId;

  const ViajeFinalizado({
    super.key,
    required this.uidConductor,
    required this.rutaId,
  });

  @override
  State<ViajeFinalizado> createState() => _ViajeFinalizadoState();
}

class _ViajeFinalizadoState extends State<ViajeFinalizado> {
  bool _guardando = true;
  String? _mensajeResumen;

  @override
  void initState() {
    super.initState();
    _guardarHistorialViaje();
  }

  Future<void> _guardarHistorialViaje() async {
    try {
      final rutaDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.uidConductor)
          .collection('rutas')
          .doc(widget.rutaId)
          .get();

      final conductorDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.uidConductor)
          .get();

      final pasajerosSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.uidConductor)
          .collection('rutas')
          .doc(widget.rutaId)
          .collection('pasajeros')
          .where('abordado', isEqualTo: true)
          .get();

      final List<Map<String, dynamic>> listaPasajeros = [];
      int totalPasajeros = 0;

      for (var p in pasajerosSnapshot.docs) {
        final data = p.data();
        final pasajeroId = p.id;

        final pasajeroDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(pasajeroId)
            .get();

        listaPasajeros.add({
          'uid': pasajeroId,
          'nombre': pasajeroDoc.data()?['nombre'] ?? 'Desconocido',
          'metodoPago': data['metodoPago'],
          'precio': data['precioEstimado'],
        });

        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(pasajeroId)
            .collection('historialSolicitudes')
            .add({
          'fecha': Timestamp.now(),
          'estado': 'completado',
          'conductor': conductorDoc.data()?['nombre'] ?? 'Desconocido',
          'metodoPago': data['metodoPago'],
          'precio': data['precioEstimado'],
          'origen': rutaDoc['origen'],
          'destino': rutaDoc['destino'],
          'nombreRuta': rutaDoc['nombreRuta'],
        });

        totalPasajeros++;
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.uidConductor)
          .collection('historialViajes')
          .add({
        'fecha': Timestamp.now(),
        'nombreRuta': rutaDoc['nombreRuta'],
        'origen': rutaDoc['origen'],
        'destino': rutaDoc['destino'],
        'pasajeros': listaPasajeros,
      });

      setState(() {
        _guardando = false;
        _mensajeResumen =
        'Ruta "${rutaDoc['nombreRuta']}" finalizada. Total de pasajeros: $totalPasajeros';
      });
    } catch (e) {
      setState(() {
        _guardando = false;
        _mensajeResumen = 'Error al guardar el historial del viaje: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Viaje Finalizado'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: _guardando
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Guardando historial del viaje...')
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle,
                color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              _mensajeResumen ?? 'Viaje finalizado con éxito.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrincipalConductor(
                      numControl: widget.uidConductor,
                    ),
                  ),
                      (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              label: const Text('Volver al inicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
