import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
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
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Inicia sesión como conductor',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      );
    }

    final pasajerosRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uidConductor)
        .collection('rutas')
        .doc('info')
        .collection('pasajeros');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Solicitudes de Pasajeros',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: pasajerosRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No hay pasajeros registrados.',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
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
                    return ListTile(
                      title: Text(
                        "Cargando pasajero...",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    );
                  }

                  final userData = snapshotUser.data!.data() as Map<String, dynamic>?;

                  if (userData == null) {
                    return ListTile(
                      title: Text("Pasajero no encontrado ($uidPasajero)",
                          style: GoogleFonts.poppins(color: Colors.white)),
                    );
                  }

                  final nombre = userData['nombre'] ?? 'Sin nombre';
                  final foto = userData['fotografiaUrl'] ?? null;

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade800,
                        backgroundImage: (foto != null && foto != '')
                            ? NetworkImage(foto)
                            : null,
                        child: (foto == null || foto == '')
                            ? const Icon(Icons.person,
                            size: 28, color: Colors.white)
                            : null,
                      ),
                      title: Text(
                        nombre,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('No. Control: $uidPasajero',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 13)),
                            Text('Método de pago: $metodoPago',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 13)),
                            Text('Estado: $estado',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 13)),
                          ],
                        ),
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
        label: Text(
          'Comenzar viaje',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.navigation, color: Colors.white),
        backgroundColor: Colors.blueAccent, // 🔵 ¡Aquí está el cambio!
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
      final rutaRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uidConductor)
          .collection('rutas')
          .doc('info');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(rutaRef);
        final disponibles = snapshot['lugaresDisponibles'] ?? 0;
        if (disponibles > 0) {
          transaction.update(rutaRef, {
            'lugaresDisponibles': disponibles - 1,
          });
        }
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pasajero $nuevoEstado',
            style: GoogleFonts.poppins()),
      ),
    );
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
      SnackBar(
        content: Text('Pasajero rechazado y archivado',
            style: GoogleFonts.poppins()),
      ),
    );
  }
}
