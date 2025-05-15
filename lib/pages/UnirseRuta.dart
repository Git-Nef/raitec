import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnirseRuta extends StatefulWidget {
  final String rutaId;
  final Map<String, dynamic> datosRuta;
  final String uidConductor;
  final String uidPasajero;

  const UnirseRuta({
    super.key,
    required this.rutaId,
    required this.datosRuta,
    required this.uidConductor,
    required this.uidPasajero,
  });

  @override
  State<UnirseRuta> createState() => _UnirseRutaState();
}

class _UnirseRutaState extends State<UnirseRuta> {
  bool uniendose = false;
  bool mostrarMetodosPago = false;
  String metodoPago = 'Efectivo';

  Future<void> _unirseComoPasajero() async {
    setState(() => uniendose = true);

    try {
      final rutaDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.uidConductor)
          .collection('rutas')
          .doc(widget.rutaId)
          .get();

      if (!rutaDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruta no encontrada')),
        );
        setState(() => uniendose = false);
        return;
      }

      final data = rutaDoc.data()!;
      final lugaresDisponibles = data['lugaresDisponibles'] ?? 0;

      final pasajerosRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.uidConductor)
          .collection('rutas')
          .doc(widget.rutaId)
          .collection('pasajeros');

      final pasajerosSnapshot = await pasajerosRef.get();
      final yaExiste = await pasajerosRef.doc(widget.uidPasajero).get();

      if (yaExiste.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya estás unido a esta ruta')),
        );
        setState(() => uniendose = false);
        return;
      }

      if (pasajerosSnapshot.docs.length >= lugaresDisponibles) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruta llena')),
        );
        setState(() => uniendose = false);
        return;
      }

      await pasajerosRef.doc(widget.uidPasajero).set({
        'estado': 'pendiente',
        'metodoPago': metodoPago,
        'fechaUnion': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Petición enviada al conductor!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e')),
      );
    }

    setState(() => uniendose = false);
  }

  @override
  Widget build(BuildContext context) {
    final ruta = widget.datosRuta;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unirse a Ruta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                title: Text('Origen: ${ruta['origen']}'),
                subtitle: Text('Destino: ${ruta['destino']}'),
                trailing: Text('Lugares: ${ruta['lugaresDisponibles']}'),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              child: ListTile(
                title: Text('Conductor: ${ruta['nombreConductor']}'),
                subtitle: Text('Horario: ${ruta['horario']}'),
              ),
            ),
            const Spacer(),

            /// Selector de método de pago
            GestureDetector(
              onTap: () {
                setState(() => mostrarMetodosPago = !mostrarMetodosPago);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Método de pago: $metodoPago',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),

            if (mostrarMetodosPago)
              Column(
                children: [
                  _buildMetodoPagoOption('Efectivo'),
                  const SizedBox(height: 8),
                  _buildMetodoPagoOption('Tarjeta'),
                  const SizedBox(height: 16),
                ],
              ),

            /// Botón para unirse a la ruta
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car),
              label: uniendose
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pedir Rait'),
              onPressed: uniendose ? null : _unirseComoPasajero,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetodoPagoOption(String metodo) {
    return GestureDetector(
      onTap: () {
        setState(() {
          metodoPago = metodo;
          mostrarMetodosPago = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: metodoPago == metodo
              ? Colors.blue.shade100
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: metodoPago == metodo ? Colors.blue : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            metodo,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
