import 'package:flutter/material.dart';
import 'package:raitec/pages/InfoCostos.dart';
import 'package:raitec/pages/InfoUsuario.dart';
import 'package:raitec/pages/InicioSesion.dart';
import 'package:raitec/pages/MisRutas.dart';
import 'package:raitec/pages/aspirar.dart';

class PrincipalUsuario extends StatelessWidget {
  final String numControl;
  const PrincipalUsuario({super.key, required this.numControl});

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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Notificaciones abiertas')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Image.asset(
                      'assets/SplashScreen.png',
                      height: 180,
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

                  // Botones principales con eventos
                  buildBoton(
                    'BUSCAR UNA RUTA',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MisRutas()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildBoton(
                    'COSTOS',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InfoCostos()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildBoton(
                    'MI INFORMACIÓN',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InfoUsuario()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '¿Quieres ser conductor?',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildBoton(
                    'Elaborar Petición',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Aspirar(numControl: numControl),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  buildBoton(
                    'CERRAR SESIÓN',
                    color: Colors.lightBlueAccent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const InicioSesion()),
                      );
                    },
                  ),
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Inicio seleccionado')),
                        );
                      },
                      icon: const Icon(Icons.home, size: 32),
                    ),
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/user.jpg'),
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

  Widget buildBoton(String texto,
      {Color color = Colors.blue, VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
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
