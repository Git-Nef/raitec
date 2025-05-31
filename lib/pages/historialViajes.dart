import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Historial de Viajes'),
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
            return const Center(child: Text('Ocurrió un error'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final viajes = snapshot.data!.docs;
          if (viajes.isEmpty) {
            return const Center(child: Text('No hay viajes aún'));
          }

          return ListView.builder(
            itemCount: viajes.length,
            itemBuilder: (context, index) {
              final viaje = viajes[index].data() as Map<String, dynamic>;
              final nombreRuta = viaje['nombreRuta'] ?? 'Ruta sin nombre';
              final fecha = viaje['fecha']?.toDate() ?? DateTime.now();
              final origen = viaje['origen'];
              final pasajeros = List<Map<String, dynamic>>.from(viaje['pasajeros'] ?? []);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreRuta,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Fecha: ${DateFormat('dd/MM/yyyy hh:mm a').format(fecha)}'),
                      if (origen != null)
                        Text(
                          'Origen: (${origen['lat']?.toStringAsFixed(4)}, ${origen['lng']?.toStringAsFixed(4)})',
                        ),
                      const SizedBox(height: 12),
                      const Text('Pasajeros:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...pasajeros.map((pasajero) {
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.person),
                          title: Text(pasajero['nombre'] ?? 'Sin nombre'),
                          subtitle: Text('Método: ${pasajero['metodoPago'] ?? '-'}'),
                          trailing: Text('\$${(pasajero['precio'] ?? 0).toStringAsFixed(2)}'),
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
