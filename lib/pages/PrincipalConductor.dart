import 'package:flutter/material.dart';
import 'package:raitec/pages/InfoUsuario.dart';
import 'package:raitec/pages/misrutas.dart';
import 'package:raitec/pages/InfoVehiculo.dart';
import 'package:raitec/pages/PrincipalUsuario.dart';
import 'package:raitec/pages/Registro.dart';
import 'package:raitec/pages/ISConductores.dart';

class PrincipalConductor extends StatelessWidget {
  const PrincipalConductor({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // Acción para notificaciones
            },
          ),
        ],
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Bienvenido al servicio de conductor de RaiTec',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),

            // Botón 1
            buildButton('Mi información', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoUsuario()),
              );
            }),

            const SizedBox(height: 24),

            // Botón 2
            buildButton('Mi vehículo', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoVehiculo()),
              );
            }),

            const SizedBox(height: 24),

            // Botón 3
            buildButton('Mis rutas', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MisRutas()),
              );
            }),
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

  // Botón reutilizable
  Widget buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
