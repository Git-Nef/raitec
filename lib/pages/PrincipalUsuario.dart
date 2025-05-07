import 'package:flutter/material.dart';
import 'package:raitec/pages/InfoCostos.dart';
import 'package:raitec/pages/InfoUsuario.dart';
import 'package:raitec/pages/InicioSesion.dart';
import 'package:raitec/pages/MisRutas.dart';
import 'package:raitec/pages/aspirar.dart';
import 'package:raitec/pages/InfoVehiculo.dart'; // Agregado para navegación
import 'package:raitec/pages/RegistrarVehiculo.dart'; // Agregado para navegación
import 'package:raitec/pages/sesion.dart';

class PrincipalUsuario extends StatelessWidget {
  final String numControl;
  const PrincipalUsuario({super.key, required this.numControl});

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
              Scaffold.of(context).openDrawer(); // Menú de hamburguesa
            },
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 30),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Notificaciones abiertas'))); // Icono de notificación
            },
          ),
        ],
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
            // Aquí agregamos los items para redirigir a las diferentes pantallas
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Registrar Vehículo'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RegistrarVehiculo(numControl: numControl),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Info Vehículo'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoVehiculo(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Mi Información'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoUsuario(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Mis Rutas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MisRutas(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Cerrar sesión'),
              onTap: () {
                _confirmarCerrarSesion(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                color: Colors.red, // Botón rojo
                onPressed: () {
                  _confirmarCerrarSesion(context);
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // Función para mostrar confirmación al cerrar sesión
  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content: const Text("¿Estás seguro de que quieres cerrar sesión?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: const Text("Aceptar"),
              onPressed: () {
                SessionManager().setNumControl(''); // Limpiar sesión
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const InicioSesion()),
                );
              },
            ),
          ],
        );
      },
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
