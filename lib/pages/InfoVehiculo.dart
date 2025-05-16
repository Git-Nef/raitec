import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raitec/pages/InfoUsuario.dart';
import 'package:raitec/pages/PrincipalUsuario.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: Image.asset('assets/LogoPantallas.png', height: 60),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menú',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Image.asset('assets/LogoPantallas.png', height: 50),
                ],
              ),
            ),
            // Agrega más opciones si lo deseas
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: docRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("No hay datos del vehículo.",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final data = snapshot.data!.data()!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información del vehículo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrarVehiculo(numControl: numControl!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text(
                    'Registrar Vehículo',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _infoFila(['Marca', 'Modelo', 'Año'], [
                  data['marca'] ?? 'N/A',
                  data['modelo'] ?? 'N/A',
                  data['anio'] ?? 'N/A',
                ]),
                const SizedBox(height: 10),
                _infoFila(['Matrícula', 'Color'], [
                  data['matricula'] ?? 'N/A',
                  data['color'] ?? 'N/A',
                ]),
                const SizedBox(height: 10),
                _infoFila(['Seguro', 'Asientos'], [
                  data['seguro'] ?? 'N/A',
                  data['asientos'] ?? 'N/A',
                ]),
                const SizedBox(height: 10),
                _infoFila(['Características'], [
                  data['caracteristicas'] ?? 'N/A',
                ]),
                const SizedBox(height: 24),
                Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'FOTOGRAFÍA DEL VEHÍCULO',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            data['fotoUrl'] ??
                                'https://via.placeholder.com/300x180.png?text=Sin+Foto',
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
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
        elevation: 10,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 28, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.home_outlined,
                    size: 28, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PrincipalUsuario(numControl: numControl!),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline,
                    size: 28, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InfoUsuario()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoFila(List<String> labels, List<String> values) {
    return Column(
      children: [
        Row(
          children: labels
              .map((label) => Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ))
              .toList(),
        ),
        const SizedBox(height: 4),
        Row(
          children: values
              .map((value) => Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[800],
              ),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ))
              .toList(),
        ),
      ],
    );
  }
}
