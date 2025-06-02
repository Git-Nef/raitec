import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raitec/pages/InfoUsuario.dart';
import 'package:raitec/pages/misrutas.dart';
import 'package:raitec/pages/InfoVehiculo.dart';
import 'package:raitec/pages/PrincipalUsuario.dart';
import 'package:raitec/pages/InicioSesion.dart';
import 'package:raitec/pages/sesion.dart';
import 'package:raitec/pages/HistorialViajes.dart';

class PrincipalConductor extends StatelessWidget {
  final String numControl;

  const PrincipalConductor({super.key, required this.numControl});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Modo Conductor',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
          ),
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
                    Text(
                      'Menú',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Image.asset('assets/LogoPantallas.png', height: 50),
                  ],
                ),
              ),
              _drawerItem(Icons.person, 'Mi información', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => InfoUsuario()));
              }),
              _drawerItem(Icons.directions_car, 'Mi vehículo', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => InfoVehiculo()));
              }),
              _drawerItem(Icons.map, 'Mis rutas', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MisRutas()));
              }),
              _drawerItem(Icons.history, 'Historial de viajes', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistorialViajes()));
              }),
              _drawerItem(Icons.home, 'Cambiar a pasajero', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalUsuario()));
              }),
              _drawerItem(Icons.logout, 'Cerrar sesión', () {
                _confirmarCerrarSesion(context);
              }, color: Colors.red),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Image.asset('assets/SplashScreen.png', height: 140),
                const SizedBox(height: 20),
                Text(
                  'Bienvenido al servicio de conductor de RaiTec',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                _cardOpcion(
                  icono: Icons.person,
                  texto: 'Mi información',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => InfoUsuario()),
                  ),
                ),
                _cardOpcion(
                  icono: Icons.directions_car,
                  texto: 'Mi vehículo',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => InfoVehiculo()),
                  ),
                ),
                _cardOpcion(
                  icono: Icons.map,
                  texto: 'Mis rutas',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MisRutas()),
                  ),
                ),
                _cardOpcion(
                  icono: Icons.history,
                  texto: 'Historial de viajes',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistorialViajes()),
                  ),
                ),
                _cardOpcion(
                  icono: Icons.logout,
                  texto: 'Cerrar sesión',
                  color: Colors.red,
                  onTap: () => _confirmarCerrarSesion(context),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardOpcion({
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        leading: Icon(icono, color: color, size: 28),
        title: Text(
          texto,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String text, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(
        text,
        style: GoogleFonts.poppins(color: color ?? Colors.white),
      ),
      onTap: onTap,
    );
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
        content: const Text("¿Estás seguro de que quieres cerrar sesión?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Aceptar", style: TextStyle(color: Colors.red)),
            onPressed: () {
              SessionManager().setNumControl('');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const InicioSesion()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
