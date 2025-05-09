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
    final String? numControl =
        SessionManager().numControl; // Obtenemos la clave del usuario
    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(numControl)
        .collection('vehiculo')
        .doc('info');

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          centerTitle: true,
          title: Image.asset(
            'assets/LogoPantallas.png',
            height: 90,
          ),
        ),
        drawer: Drawer(
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Image.asset('assets/LogoPantallas.png', height: 60),
                  ],
                ),
              ),
              // Aquí puedes agregar los ListTile para navegación
            ],
          ),
        ),
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: docRef.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("No hay datos del vehículo."));
            }

            final data = snapshot.data!.data()!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    '¿No tienes ningún vehículo registrado? Llena el siguiente formulario',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción para registrar vehículo
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrarVehiculo(
                                numControl: numControl!), // Pasando numControl
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Registrar Vehículo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _infoFila(context, [
                    'Marca del Coche',
                    'Modelo',
                    'Año'
                  ], [
                    data['marca'] ?? 'N/A',
                    data['modelo'] ?? 'N/A',
                    data['anio'] ?? 'N/A',
                  ]),
                  const SizedBox(height: 8),
                  _infoFila(context, [
                    'Matrícula',
                    'Color del Coche'
                  ], [
                    data['matricula'] ?? 'N/A',
                    data['color'] ?? 'N/A',
                  ]),
                  const SizedBox(height: 8),
                  _infoFila(context, [
                    'Seguro del Vehículo',
                    'Número de Asientos'
                  ], [
                    data['seguro'] ?? 'N/A',
                    data['asientos'] ?? 'N/A',
                  ]),
                  const SizedBox(height: 8),
                  _infoFila(context, [
                    'Características'
                  ], [
                    data['caracteristicas'] ?? 'N/A',
                  ]),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'FOTOGRAFÍA DEL VEHÍCULO',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
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
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.lightBlue,
          elevation: 8,
          child: SizedBox(
            height: 70,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          size: 42, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Este botón navega hacia atrás
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: const Icon(Icons.home, size: 42, color: Colors.white),
                    onPressed: () {
                      // Redirige a la pantalla principal
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrincipalUsuario(
                                numControl: SessionManager().numControl!)),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                      icon: const Icon(Icons.account_circle,
                          size: 42, color: Colors.white),
                      onPressed: () {
                        // Redirige a la pantalla de información del usuario
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InfoUsuario()),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _infoFila(
      BuildContext context, List<String> labels, List<String> values) {
    return Column(
      children: [
        Row(
          children: labels
              .map((text) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ))
              .toList(),
        ),
        Row(
          children: values
              .map((text) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey.shade300),
                          right: BorderSide(color: Colors.grey.shade300),
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
