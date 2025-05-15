import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          title: const Text('Viaje finalizado'),
          content:
              const Text('Los pasajeros fueron archivados en el historial.'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Ruta')),
      body: datosRuta == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resumen de tu ruta:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                      'Destino: ${datosRuta!['destino']['lat']}, ${datosRuta!['destino']['lng']}'),
                  Text(
                      'Origen: ${datosRuta!['origen']['lat']}, ${datosRuta!['origen']['lng']}'),
                  const SizedBox(height: 30),
                  const Text('¿Deseas finalizar esta ruta?',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 15),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: finalizando ? null : finalizarViaje,
                      icon: finalizando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.flag),
                      label: Text(
                          finalizando ? 'Finalizando...' : 'Finalizar viaje'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
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
