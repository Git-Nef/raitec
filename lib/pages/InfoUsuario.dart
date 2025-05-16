import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raitec/pages/sesion.dart';

class InfoUsuario extends StatelessWidget {
  const InfoUsuario({super.key});

  Future<Map<String, dynamic>?> obtenerDatosUsuario() async {
    String? clave = SessionManager().numControl;
    if (clave == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(clave)
        .get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Perfil del Usuario'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: obtenerDatosUsuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No se encontraron datos del usuario.',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset('assets/logoAppbar.png', height: 100),
                const SizedBox(height: 20),
                const Text(
                  'INFORMACIÓN DE USUARIO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        filaInfo(Icons.person_outline, 'Nombre Alumno', data['nombre']),
                        filaInfo(Icons.calendar_today_outlined, 'Edad', '${data['edad']}'),
                        filaInfo(Icons.badge_outlined, 'Número de Control', data['numControl']),
                        filaInfo(Icons.school_outlined, 'Carrera', data['carrera']),
                        filaInfo(Icons.location_on_outlined, 'Dirección', data['direccion']),
                        filaInfo(Icons.phone_android_outlined, 'Teléfono', data['telefono']),
                        filaInfo(Icons.flag_outlined, 'Nacionalidad', data['nacionalidad']),
                        filaInfo(Icons.cake_outlined, 'Nacimiento', data['fechaNacimiento']),
                        filaInfo(Icons.phone_forwarded_outlined, 'Tel. Emergencia', data['telefonoEmergencia']),
                        filaInfo(Icons.email_outlined, 'Email', data['email']),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: columnaImagen(
                                label: 'Fotografía',
                                imageUrl: data['fotografiaUrl'],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: columnaImagen(
                                label: 'Firma Estudiante',
                                imageUrl: data['firmaUrl'],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 28, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.home_outlined, size: 28, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget filaInfo(IconData icono, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icono, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget columnaImagen({required String label, required String imageUrl}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
