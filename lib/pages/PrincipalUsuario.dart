import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raitec/pages/InfoCostos.dart';
import 'package:raitec/pages/InfoUsuario.dart';
import 'package:raitec/pages/InicioSesion.dart';
import 'package:raitec/pages/MisRutas.dart';
import 'package:raitec/pages/RutasOfrecidas.dart';
import 'package:raitec/pages/aspirar.dart';
import 'package:raitec/pages/InfoVehiculo.dart';
import 'package:raitec/pages/RegistrarVehiculo.dart';
import 'package:raitec/pages/sesion.dart';
import 'package:raitec/pages/PrincipalConductor.dart';

class PrincipalUsuario extends StatefulWidget {
  const PrincipalUsuario({super.key});

  @override
  State<PrincipalUsuario> createState() => _PrincipalUsuarioState();
}

class _PrincipalUsuarioState extends State<PrincipalUsuario> {
  String? numControl = SessionManager().numControl;
  bool esConductor = false;

  @override
  void initState() {
    super.initState();
    _verificarSiEsConductor();
  }

  Future<void> _verificarSiEsConductor() async {
    if (numControl == null || numControl!.isEmpty) return;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(numControl).get();
    if (doc.exists) {
      setState(() {
        esConductor = doc.data()?['esConductor'] == true;
      });
    }
  }

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
            'RaiTec',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
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
                    Text('Menú',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Image.asset('assets/LogoPantallas.png', height: 50),
                  ],
                ),
              ),
              _drawerItem(Icons.account_circle, 'Mi Información', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => InfoUsuario()));
              }),
              if (esConductor)
                _drawerItem(Icons.directions_car, 'Vista Conductor', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrincipalConductor(numControl: numControl ?? ''),
                    ),
                  );
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
                  'Bienvenido a RaiTec',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 30),
                _cardOpcion(
                  icono: Icons.search,
                  texto: 'Buscar una ruta',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RutasOfrecidas()));
                  },
                ),
                _cardOpcion(
                  icono: Icons.attach_money,
                  texto: 'Costos',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => InfoCostos()));
                  },
                ),
                _cardOpcion(
                  icono: Icons.person_outline,
                  texto: 'Mi información',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => InfoUsuario()));
                  },
                ),
                if (!esConductor) ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '¿Quieres ser conductor?',
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _cardOpcion(
                    icono: Icons.assignment,
                    texto: 'Elaborar petición',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Aspirar(numControl: numControl ?? '')),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 30),
                _cardOpcion(
                  icono: Icons.logout,
                  texto: 'Cerrar sesión',
                  onTap: () => _confirmarCerrarSesion(context),
                  color: Colors.red,
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
        style: GoogleFonts.poppins(color: color ?? Colors.white, fontSize: 15),
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
