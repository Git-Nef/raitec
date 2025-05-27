import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:raitec/pages/sesion.dart';
import 'package:raitec/pages/verRutaConductor.dart';

class MisSolicitudes extends StatefulWidget {
  const MisSolicitudes({super.key});

  @override
  State<MisSolicitudes> createState() => _MisSolicitudesState();
}

class _MisSolicitudesState extends State<MisSolicitudes> {
  final String uidPasajero = SessionManager().numControl ?? '';
  bool solicitudEncontrada = false;
  Map<String, dynamic>? datosRuta;
  Map<String, dynamic>? datosConductor;
  Map<String, dynamic>? datosPasajero;
  String? estado;
  String? metodoPago;
  String? uidConductor;

  String? direccionOrigen;
  String? direccionDestino;

  @override
  void initState() {
    super.initState();
    _buscarSolicitud();
  }

  Future<void> _buscarSolicitud() async {
    final snapshotUsuarios =
    await FirebaseFirestore.instance.collection('usuarios').get();

    for (var user in snapshotUsuarios.docs) {
      final ref = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.id)
          .collection('rutas')
          .doc('info')
          .collection('pasajeros')
          .doc(uidPasajero);

      final doc = await ref.get();
      if (doc.exists) {
        final rutaDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.id)
            .collection('rutas')
            .doc('info')
            .get();

        final origen = rutaDoc['origen'];
        final destino = rutaDoc['destino'];

        try {
          final origenPlacemark =
          await placemarkFromCoordinates(origen['lat'], origen['lng']);
          final destinoPlacemark =
          await placemarkFromCoordinates(destino['lat'], destino['lng']);

          direccionOrigen =
          '${origenPlacemark.first.street}, ${origenPlacemark.first.locality}';
          direccionDestino =
          '${destinoPlacemark.first.street}, ${destinoPlacemark.first.locality}';
        } catch (_) {
          direccionOrigen = 'Dirección no disponible';
          direccionDestino = 'Dirección no disponible';
        }

        setState(() {
          solicitudEncontrada = true;
          datosPasajero = doc.data();
          estado = doc['estado'];
          metodoPago = doc['metodoPago'];
          datosRuta = rutaDoc.data();
          datosConductor = user.data();
          uidConductor = user.id;
        });

        break;
      }
    }
  }

  Future<void> _cancelarSolicitud() async {
    if (uidConductor == null) return;

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
      'estado': 'cancelado',
      'metodoPago': metodoPago,
      'fecha': Timestamp.now(),
      'conductor': nombreConductor,
    });

    await pasajeroRef.delete();

    setState(() {
      solicitudEncontrada = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solicitud cancelada')),
    );
  }

  Future<bool> _verificarUbicacionConductorDisponible() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uidConductor)
        .collection('ubicacion')
        .doc('actual')
        .get();

    return snapshot.exists &&
        snapshot.data() != null &&
        snapshot.data()!.containsKey('lat') &&
        snapshot.data()!.containsKey('lng');
  }

  Widget _iconoEstado(String estado) {
    if (estado == 'aceptado') {
      return const Icon(Icons.check_circle, color: Colors.green, size: 50);
    } else if (estado == 'rechazado') {
      return const Icon(Icons.cancel, color: Colors.red, size: 50);
    } else {
      return const SizedBox(
        height: 50,
        width: 50,
        child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 4),
      );
    }
  }

  Widget _tarjetaSolicitudActual() {
    final horarios = datosRuta!['horarios'] as List<dynamic>?;

    final horarioTexto = horarios != null
        ? horarios.map((h) => '${h['dia']} (${h['horaInicio']})').join(', ')
        : 'Sin horario';

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tu solicitud actual',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _iconoEstado(estado!),
                const SizedBox(width: 12),
                Text(
                  'Estado: $estado',
                  style: TextStyle(
                    fontSize: 16,
                    color: estado == 'aceptado'
                        ? Colors.green
                        : estado == 'rechazado'
                        ? Colors.red
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            Text('Conductor: ${datosConductor!['nombre']}'),
            Text('Teléfono: ${datosConductor!['telefono']}'),
            Text('Correo: ${datosConductor!['email']}'),
            const SizedBox(height: 10),
            Text('Origen: $direccionOrigen'),
            Text('Destino: $direccionDestino'),
            Text('Horarios: $horarioTexto'),
            const SizedBox(height: 10),
            Text('Método de pago: $metodoPago'),
            const SizedBox(height: 20),
            if (estado == 'pendiente')
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar solicitud'),
                  onPressed: _cancelarSolicitud,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            else if (estado == 'aceptado')
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Ver ruta del conductor'),
                  onPressed: () async {
                    final disponible =
                    await _verificarUbicacionConductorDisponible();

                    if (!disponible) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Ubicación del conductor no disponible aún.')),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VerRutaConductor(
                          uidConductor: uidConductor!,
                          parada: datosPasajero!['paradaPersonalizada'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _historialSolicitudes() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uidPasajero)
          .collection('historialSolicitudes')
          .orderBy('fecha', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final docs = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Historial de solicitudes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final estado = data['estado'];
                final conductor = data['conductor'] ?? 'Desconocido';
                final fecha = (data['fecha'] as Timestamp).toDate();

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(
                      estado == 'aceptado'
                          ? Icons.check_circle
                          : estado == 'rechazado'
                          ? Icons.cancel
                          : Icons.pending,
                      color: estado == 'aceptado'
                          ? Colors.green
                          : estado == 'rechazado'
                          ? Colors.red
                          : Colors.orange,
                    ),
                    title: Text('Conductor: $conductor'),
                    subtitle: Text('Estado: $estado\n${fecha.toLocal()}'),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Solicitud de Rait'),
      ),
      body: solicitudEncontrada
          ? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tarjetaSolicitudActual(),
            const SizedBox(height: 20),
            _historialSolicitudes(),
          ],
        ),
      )
          : _historialSolicitudes(),
    );
  }
}
