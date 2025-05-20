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
            icon: const Icon(Icons.notifications_none, color: Colors.white),
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
                  const Text('Menú',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 10),
                  Image.asset('assets/LogoPantallas.png', height: 50),
                ],
              ),
            ),
            _drawerItem(Icons.directions_car, 'Registrar Vehículo', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistrarVehiculo(numControl: numControl),
                ),
              );
            }),
            _drawerItem(Icons.info, 'Info Vehículo', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoVehiculo()),
              );
            }),
            _drawerItem(Icons.account_circle, 'Mi Información', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoUsuario()),
              );
            }),
            _drawerItem(Icons.map, 'Mis Rutas', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MisRutas()),
              );
            }),
            _drawerItem(Icons.logout, 'Cerrar sesión', () {
              _confirmarCerrarSesion(context);
            }, color: Colors.redAccent),
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
              _actionCard(
                context,
                icon: Icons.search,
                text: 'Buscar una ruta',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RutasOfrecidas())),
              ),
              _actionCard(
                context,
                icon: Icons.attach_money,
                text: 'Costos',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InfoCostos())),
              ),
              _actionCard(
                context,
                icon: Icons.person,
                text: 'Mi información',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InfoUsuario())),
              ),
              const SizedBox(height: 30),
              const Text(
                '¿Quieres ser conductor?',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              _actionCard(
                context,
                icon: Icons.drive_eta,
                text: 'Elaborar petición',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Aspirar(numControl: numControl)),
                ),
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
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const InicioSesion()));
            },
          ),
        ],
      ),
    );
  }
}
