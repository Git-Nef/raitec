import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final snapshotUsuarios = await FirebaseFirestore.instance.collection('usuarios').get();

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
          final origenPlacemark = await placemarkFromCoordinates(origen['lat'], origen['lng']);
          final destinoPlacemark = await placemarkFromCoordinates(destino['lat'], destino['lng']);

          direccionOrigen = '${origenPlacemark.first.street}, ${origenPlacemark.first.locality}';
          direccionDestino = '${destinoPlacemark.first.street}, ${destinoPlacemark.first.locality}';
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
      SnackBar(
        content: Text('Solicitud cancelada', style: GoogleFonts.poppins()),
      ),
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
      return const Icon(Icons.check_circle, color: Colors.green, size: 40);
    } else if (estado == 'rechazado') {
      return const Icon(Icons.cancel, color: Colors.red, size: 40);
    } else {
      return const SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 3),
      );
    }
  }

  Widget _tarjetaSolicitudActual() {
    final horarios = datosRuta!['horarios'] as List<dynamic>?;

    final horarioTexto = horarios != null
        ? horarios.map((h) => '${h['dia']} (${h['horaInicio']})').join(', ')
        : 'Sin horario';

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu solicitud actual',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              children: [
                _iconoEstado(estado!),
                const SizedBox(width: 12),
                Text(
                  'Estado: $estado',
                  style: GoogleFonts.poppins(
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
            const Divider(height: 30, color: Colors.white24),
            Text('Conductor: ${datosConductor!['nombre']}', style: GoogleFonts.poppins(color: Colors.white70)),
            Text('Teléfono: ${datosConductor!['telefono']}', style: GoogleFonts.poppins(color: Colors.white70)),
            Text('Correo: ${datosConductor!['email']}', style: GoogleFonts.poppins(color: Colors.white70)),
            const SizedBox(height: 10),
            Text('Origen: $direccionOrigen', style: GoogleFonts.poppins(color: Colors.white70)),
            Text('Destino: $direccionDestino', style: GoogleFonts.poppins(color: Colors.white70)),
            Text('Horarios: $horarioTexto', style: GoogleFonts.poppins(color: Colors.white70)),
            const SizedBox(height: 10),
            Text('Método de pago: $metodoPago', style: GoogleFonts.poppins(color: Colors.white70)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            else if (estado == 'aceptado')
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Ver ruta del conductor'),
                  onPressed: () async {
                    final disponible = await _verificarUbicacionConductorDisponible();

                    if (!disponible) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ubicación del conductor no disponible aún.',
                            style: GoogleFonts.poppins())),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Text(
                'No hay solicitudes todavía 🕊️',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Historial de solicitudes',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final estado = data['estado'];
                final conductor = data['conductor'] ?? 'Desconocido';
                final fecha = (data['fecha'] as Timestamp).toDate();

                return Card(
                  color: Colors.grey[850],
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    title: Text('Conductor: $conductor',
                        style: GoogleFonts.poppins(color: Colors.white)),
                    subtitle: Text('Estado: $estado\n${fecha.toLocal()}',
                        style: GoogleFonts.poppins(color: Colors.white70)),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Mi Solicitud de Rait', style: GoogleFonts.poppins(color: Colors.white)),
        centerTitle: true,
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
