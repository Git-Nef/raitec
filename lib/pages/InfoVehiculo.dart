import 'package:flutter/material.dart';
import 'package:raitec/pages/InfoUsuario.dart';
import 'package:raitec/pages/misrutas.dart';
import 'package:raitec/pages/PrincipalUsuario.dart';
import 'package:raitec/pages/Registro.dart';
import 'package:raitec/pages/ISConductores.dart';

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
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menú',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/LogoPantallas.png',
                    height: 60,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi información'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoUsuario()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Mi vehículo'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoVehiculo()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Mis rutas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MisRutas()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Principal Usuario'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrincipalUsuario(
                            numControl: '',
                          )),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Registro'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Registro()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_eta),
              title: const Text('Identifícate'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ISConductores()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Texto llamativo
            const Text(
              '¿No tienes ningún vehículo registrado? Llena el siguiente formulario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),

            // Botón bonito
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Acción para registrar vehículo
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

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
            const SizedBox(height: 32),
          ],
        ),
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
                      // Acción de perfil
                    },
                  ),
                ),
              ),

              // Ícono de Home centrado
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: const Icon(Icons.home, size: 42, color: Colors.white),
                  onPressed: () {
                    // Acción de Home
                  },
                ),
              ),

              // Ícono de Perfil a la derecha
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.account_circle,
                        size: 42, color: Colors.white),
                    onPressed: () {
                      // Acción de perfil
                    },
                  ),
                ),
              ),
            ],
          ),
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
