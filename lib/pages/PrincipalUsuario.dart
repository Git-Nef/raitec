import 'package:flutter/material.dart';
import 'package:raitec/pages/InfoCostos.dart';
import 'package:raitec/pages/InfoUsuario.dart';
import 'package:raitec/pages/InicioSesion.dart';
import 'package:raitec/pages/MisRutas.dart';
import 'package:raitec/pages/RutasOfrecidas.dart';
import 'package:raitec/pages/aspirar.dart';
import 'package:raitec/pages/InfoVehiculo.dart';
import 'package:raitec/pages/RegistrarVehiculo.dart';
import 'package:raitec/pages/sesion.dart';

class PrincipalUsuario extends StatelessWidget {
  final String numControl;
  const PrincipalUsuario({super.key, required this.numControl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'RaiTec',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 30, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificaciones abiertas')),
              );
            },
          ),
        ],
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset('assets/LogoPantallas.png', height: 60),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.white),
              title: const Text('Registrar Vehículo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrarVehiculo(numControl: numControl),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text('Info Vehículo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoVehiculo()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.white),
              title: const Text('Mi Información', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoUsuario()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.white),
              title: const Text('Mis Rutas', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MisRutas()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.white),
              title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
              onTap: () {
                _confirmarCerrarSesion(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Image.asset('assets/SplashScreen.png', height: 140),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bienvenido a RaiTec',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 24),
              buildBoton(context, 'BUSCAR UNA RUTA', onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RutasOfrecidas()),
                );
              }),
              const SizedBox(height: 16),
              buildBoton(context, 'COSTOS', onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoCostos()),
                );
              }),
              const SizedBox(height: 16),
              buildBoton(context, 'MI INFORMACIÓN', onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoUsuario()),
                );
              }),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '¿Quieres ser conductor?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              buildBoton(context, 'Elaborar Petición', onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Aspirar(numControl: numControl),
                  ),
                );
              }),
              const SizedBox(height: 30),
              buildBoton(context, 'CERRAR SESIÓN', color: Colors.red, onPressed: () {
                _confirmarCerrarSesion(context);
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

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
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Aceptar"),
              onPressed: () {
                SessionManager().setNumControl('');
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

  Widget buildBoton(BuildContext context, String text,
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
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
} 