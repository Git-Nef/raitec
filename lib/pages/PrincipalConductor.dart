import 'package:flutter/material.dart';
import 'package:raitec/pages/InfoUsuario.dart';
import 'package:raitec/pages/InfoVehiculo.dart';

class PrincipalConductor extends StatelessWidget {
  const PrincipalConductor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // Acción para abrir el menú
          },
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
              // Acción para "Mi información"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoUsuario()),
              );
            }),

            const SizedBox(height: 24),

            // Botón 2
            buildButton('Mi vehículo', () {
              // Acción para "Mi vehículo"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoVehiculo()),
              );
            }),

            const SizedBox(height: 24),

            // Botón 3
            buildButton('Mis rutas', () {
              // Acción para "Mis rutas"
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
