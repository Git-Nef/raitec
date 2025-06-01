import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:raitec/pages/sesion.dart';

class HistorialViajes extends StatefulWidget {
  const HistorialViajes({super.key});

  @override
  State<HistorialViajes> createState() => _HistorialViajesState();
}

class _HistorialViajesState extends State<HistorialViajes> {
  final String clave = SessionManager().numControl ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Historial de Viajes',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(clave)
            .collection('historialViajes')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Ocurrió un error', style: GoogleFonts.poppins(color: Colors.redAccent)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final viajes = snapshot.data!.docs;
          if (viajes.isEmpty) {
            return Center(
              child: Text('No hay viajes aún', style: GoogleFonts.poppins(color: Colors.white70)),
            );
          }

          return ListView.builder(
            itemCount: viajes.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemBuilder: (context, index) {
              final viaje = viajes[index].data() as Map<String, dynamic>;
              final nombreRuta = viaje['nombreRuta'] ?? 'Ruta sin nombre';
              final fecha = viaje['fecha']?.toDate() ?? DateTime.now();
              final origen = viaje['origen'];
              final pasajeros = List<Map<String, dynamic>>.from(viaje['pasajeros'] ?? []);

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreRuta,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy hh:mm a').format(fecha)}',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                      if (origen != null)
                        Text(
                          'Origen: (${origen['lat']?.toStringAsFixed(4)}, ${origen['lng']?.toStringAsFixed(4)})',
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      const SizedBox(height: 14),
                      Text(
                        'Pasajeros:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...pasajeros.map((pasajero) {
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.person, color: Colors.white70),
                          title: Text(
                            pasajero['nombre'] ?? 'Sin nombre',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Método: ${pasajero['metodoPago'] ?? '-'}',
                            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                          ),
                          trailing: Text(
                            '\$${(pasajero['precio'] ?? 0).toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
