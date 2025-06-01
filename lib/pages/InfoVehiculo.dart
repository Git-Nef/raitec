import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raitec/pages/RegistrarVehiculo.dart';
import 'package:raitec/pages/sesion.dart';

class InfoVehiculo extends StatelessWidget {
  const InfoVehiculo({super.key});

  @override
  Widget build(BuildContext context) {
    final String? numControl = SessionManager().numControl;
    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(numControl)
        .collection('vehiculo')
        .doc('info');

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: docRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "No hay datos del vehículo.",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!.data()!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿No tienes ningún vehículo registrado?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrarVehiculo(numControl: numControl!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: Text(
                      'Registrar Vehículo',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _infoFila(context, ['Marca ', 'Modelo', 'Año'], [
                  data['marca'] ?? 'N/A',
                  data['modelo'] ?? 'N/A',
                  data['anio'] ?? 'N/A',
                ]),
                const SizedBox(height: 8),
                _infoFila(context, ['Matrícula', 'Color del Coche'], [
                  data['matricula'] ?? 'N/A',
                  data['color'] ?? 'N/A',
                ]),
                const SizedBox(height: 8),
                _infoFila(context, ['Seguro del Vehículo', 'Número de Asientos'], [
                  data['seguro'] ?? 'N/A',
                  data['asientos']?.toString() ?? 'N/A',
                ]),
                const SizedBox(height: 8),
                _infoFila(context, ['Características'], [
                  data['caracteristicas'] ?? 'N/A',
                ]),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[900],
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'FOTOGRAFÍA DEL VEHÍCULO',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data['fotoUrl'] ??
                              'https://via.placeholder.com/300x180.png?text=Sin+Foto',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 28, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoFila(BuildContext context, List<String> labels, List<String> values) {
    return Column(
      children: [
        Row(
          children: labels
              .map(
                (text) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
              .toList(),
        ),
        Row(
          children: values
              .map(
                (text) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade700),
                    right: BorderSide(color: Colors.grey.shade700),
                    bottom: BorderSide(color: Colors.grey.shade700),
                  ),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }
}
