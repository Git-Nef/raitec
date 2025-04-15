import 'package:flutter/material.dart';

class InfoVehiculo extends StatelessWidget {
  const InfoVehiculo({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> vehiculo = {
      'Marca': 'Toyota',
      'Modelo': 'Corolla',
      'Año': '2020',
      'Matrícula': 'ABC-1234',
      'Color': 'Rojo',
      'Seguro': 'GNP Seguros',
      'Asientos': '5',
      'Nacionalidad': 'Mexicana',
      'Características': 'Bluetooth, Aire Acondicionado, ABS',
      'Foto':
          'https://upload.wikimedia.org/wikipedia/commons/9/9e/2019_Toyota_Corolla_Icon_Tech_VVT-i_HEV_CVT_1.8_Front.jpg',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Información del Vehículo',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Logo
            Image.asset('assets/logoRT.png', height: 90),
            const SizedBox(height: 24),

            _infoFila(context, ['Marca del Coche', 'Modelo', 'Año'],
                [vehiculo['Marca']!, vehiculo['Modelo']!, vehiculo['Año']!]),
            const SizedBox(height: 8),
            _infoFila(context, ['Matrícula', 'Color del Coche'],
                [vehiculo['Matrícula']!, vehiculo['Color']!]),
            const SizedBox(height: 8),
            _infoFila(context, ['Seguro del Vehículo', 'Número de Asientos'],
                [vehiculo['Seguro']!, vehiculo['Asientos']!]),
            const SizedBox(height: 8),
            _infoFila(context, ['Nacionalidad', 'Características'],
                [vehiculo['Nacionalidad']!, vehiculo['Características']!]),
            const SizedBox(height: 24),

            // Fotografía
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      vehiculo['Foto']!,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
