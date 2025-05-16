import 'package:flutter/material.dart';
import 'package:raitec/pages/InfoUsuario.dart';
import 'package:raitec/pages/misrutas.dart';
import 'package:raitec/pages/InfoVehiculo.dart';
import 'package:raitec/pages/PrincipalUsuario.dart';
import 'package:raitec/pages/Registro.dart';
import 'package:raitec/pages/ISConductores.dart';
import 'package:raitec/pages/InicioSesion.dart';
import 'package:raitec/pages/sesion.dart';

class PrincipalConductor extends StatelessWidget {
  final String numControl;

  const PrincipalConductor({super.key, required this.numControl});

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
          'RaiTec - Conductor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No hay notificaciones nuevas')),
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
                  const Text('Menú',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 10),
                  Image.asset('assets/LogoPantallas.png', height: 50),
                ],
              ),
            ),
            _drawerItem(Icons.person, 'Mi información', () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => InfoUsuario()));
            }),
            _drawerItem(Icons.directions_car, 'Mi vehículo', () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => InfoVehiculo()));
            }),
            _drawerItem(Icons.map, 'Mis rutas', () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => MisRutas()));
            }),
            _drawerItem(Icons.swap_horiz, 'Cambiar a usuario', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PrincipalUsuario(numControl: numControl)),
              );
            }),
            _drawerItem(Icons.app_registration, 'Registro', () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Registro()));
            }),
            _drawerItem(Icons.verified_user, 'Identifícate', () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ISConductores()));
            }),
            _drawerItem(Icons.logout, 'Cerrar sesión', () {
              _confirmarCerrarSesion(context);
            }, color: Colors.redAccent),
          ],
        ),
      ),
      body: SafeArea(
<<<<<<< HEAD
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Center(
                child: Image.asset(
                  'assets/SplashScreen.png',
                  height: 180,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bienvenido al servicio de conductor de RaiTec',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              buildButton('Mi información', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoUsuario()),
                );
              }),
              const SizedBox(height: 24),
              buildButton('Mi vehículo', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoVehiculo()),
                );
              }),
              const SizedBox(height: 24),
              buildButton('Mis rutas', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MisRutas()),
                );
              }),
              const SizedBox(height: 40),
              buildButton('CERRAR SESIÓN', () {
                _confirmarCerrarSesion(context);
              }, color: Colors.red),
              const SizedBox(height: 40),
=======
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset('assets/SplashScreen.png', height: 140)),
              const SizedBox(height: 20),
              const Text(
                'Bienvenido conductor',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Administra tu información, vehículo y rutas fácilmente.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              _actionCard(
                context,
                icon: Icons.person_outline,
                text: 'Mi información',
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => InfoUsuario())),
              ),
              _actionCard(
                context,
                icon: Icons.directions_car,
                text: 'Mi vehículo',
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => InfoVehiculo())),
              ),
              _actionCard(
                context,
                icon: Icons.map_outlined,
                text: 'Mis rutas',
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => MisRutas())),
              ),
              const Spacer(),
              _actionCard(
                context,
                icon: Icons.logout,
                text: 'Cerrar sesión',
                color: Colors.red,
                onTap: () => _confirmarCerrarSesion(context),
              ),
              const SizedBox(height: 20),
>>>>>>> neftali
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard(BuildContext context,
      {required IconData icon,
        required String text,
        required VoidCallback onTap,
        Color color = Colors.blueAccent}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmación"),
        content: const Text("¿Estás seguro de que quieres cerrar sesión?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Aceptar"),
            onPressed: () {
              SessionManager().setNumControl('');
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const InicioSesion()));
            },
          ),
        ],
      ),
    );
  }
}
