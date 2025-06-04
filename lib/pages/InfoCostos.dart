import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InfoCostos extends StatefulWidget {
  const InfoCostos({super.key});

  @override
  State<InfoCostos> createState() => _InfoCostosState();
}

class _InfoCostosState extends State<InfoCostos> {
  double? tarifaBase;
  double? costoKm;
  double? costoMin;

  @override
  void initState() {
    super.initState();
    obtenerCostos();
  }

  Future<void> obtenerCostos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('costosRaiTec')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        tarifaBase = data['tarifabase']?.toDouble();
        costoKm = data['costokm']?.toDouble();
        costoMin = data['costomin']?.toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Image.asset('assets/LogoPantallas.png', height: 40),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'INFORMACIÓN DE COSTOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filaCosto('Tarifa base:', tarifaBase),
                  _filaCosto('Costo por kilómetro:', costoKm),
                  _filaCosto('Costo por minuto:', costoMin),
                  const SizedBox(height: 20),
                  const Text(
                    'El costo por kilómetros, minutos y tarifa base está sujeto a cambios sin previo aviso.\n\n'
                        'Te recomendamos estar atento a nuestras actualizaciones y comunicados para conocer cualquier modificación en nuestras tarifas.',
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _filaCosto(String label, double? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          Text(
            valor != null ? '\$${valor.toStringAsFixed(2)}' : '...',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
