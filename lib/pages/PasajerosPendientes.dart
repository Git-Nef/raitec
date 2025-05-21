import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raitec/pages/sesion.dart';
import 'package:raitec/pages/SeguimientoViaje.dart';

class PasajerosPendientes extends StatefulWidget {
  const PasajerosPendientes({super.key});

  @override
  State<PasajerosPendientes> createState() => _PasajerosPendientesState();
}

class _PasajerosPendientesState extends State<PasajerosPendientes> {
  final String uidConductor = SessionManager().numControl ?? '';

  @override
  Widget build(BuildContext context) {
    if (uidConductor.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Inicia sesión como conductor')),
      );
    }

    final pasajerosRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uidConductor)
        .collection('rutas')
        .doc('info')
        .collection('pasajeros');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Pasajeros'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: pasajerosRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No hay pasajeros registrados.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final pasajeroDoc = docs[index];
              final uidPasajero = pasajeroDoc.id;
              final estado = pasajeroDoc['estado'];
              final metodoPago = pasajeroDoc['metodoPago'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(uidPasajero)
                    .get(),
                builder: (context, snapshotUser) {
                  if (!snapshotUser.hasData) {
                    return const ListTile(title: Text("Cargando pasajero..."));
                  }

                  final userData =
                      snapshotUser.data!.data() as Map<String, dynamic>?;

                  if (userData == null) {
                    return ListTile(
                        title: Text("Pasajero no encontrado ($uidPasajero)"));
                  }

                  final nombre = userData['nombre'] ?? 'Sin nombre';
                  final foto = userData['fotografiaUrl'] ?? null;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: (foto != null && foto != '')
                            ? NetworkImage(foto)
                            : null,
                        child: (foto == null || foto == '')
                            ? const Icon(Icons.person,
                                size: 28, color: Colors.grey)
                            : null,
                      ),
                      title: Text(nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('No. Control: $uidPasajero'),
                          Text('Método de pago: $metodoPago'),
                          Text('Estado: $estado'),
                        ],
                      ),
                      trailing: estado == 'pendiente'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  onPressed: () =>
                                      _cambiarEstado(uidPasajero, 'aceptado'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  onPressed: () => _rechazarPasajero(
                                      uidPasajero, metodoPago),
                                ),
                              ],
                            )
                          : Icon(
                              estado == 'aceptado'
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: estado == 'aceptado'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeguimientoViaje(
                uidConductor: uidConductor,
                rutaId: 'info',
              ),
            ),
          );
        },
        label: const Text('Comenzar Viaje'),
        icon: const Icon(Icons.directions_car),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _cambiarEstado(String uidPasajero, String nuevoEstado) async {
    final ref = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uidConductor)
        .collection('rutas')
        .doc('info')
        .collection('pasajeros')
        .doc(uidPasajero);

    await ref.update({'estado': nuevoEstado});

    if (nuevoEstado == 'aceptado') {
      await _restarAsiento(uidConductor);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pasajero $nuevoEstado')),
    );
  }

  Future<void> _restarAsiento(String uid) async {
    final rutaRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('rutas')
        .doc('info');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(rutaRef);
      final disponibles = snapshot.get('lugaresDisponibles') as int;

      if (disponibles > 0) {
        transaction.update(rutaRef, {
          'lugaresDisponibles': disponibles - 1,
        });
      }
    });
  }

  Future<void> _rechazarPasajero(String uidPasajero, String metodoPago) async {
    final pasajeroRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uidConductor)
        .collection('rutas')
        .doc('info')
        .collection('pasajeros')
        .doc(uidPasajero);

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
      'estado': 'rechazado',
      'metodoPago': metodoPago,
      'fecha': Timestamp.now(),
      'conductor': nombreConductor,
    });

    await pasajeroRef.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pasajero rechazado y archivado')),
    );
  }
}
