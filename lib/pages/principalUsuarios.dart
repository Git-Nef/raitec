import 'package:flutter/material.dart';

class PrincipalUsuarios extends StatelessWidget {
  const PrincipalUsuarios({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications, size: 30),
                        onPressed: () {
                          // Acción para notificaciones
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Image.asset(
                      'assets/logoRT.png', // asegúrate que esta imagen esté en assets
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'BIENVENIDO A RaiTec',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botones principales
                  buildBoton('BUSCAR UNA RUTA'),
                  const SizedBox(height: 16),
                  buildBoton('COSTOS'),
                  const SizedBox(height: 16),
                  buildBoton('MI INFORMACIÓN'),
                  const Spacer(),
                  buildBoton('CERRAR SESIÓN', color: Colors.lightBlueAccent),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Barra inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.grey[400],
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.home, size: 32),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/user.jpg'), // tu imagen de usuario
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBoton(String texto, {Color color = Colors.blue}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 16,
            letterSpacing: 1.5,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
