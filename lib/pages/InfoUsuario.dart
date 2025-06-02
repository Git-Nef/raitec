import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raitec/pages/sesion.dart';

class InfoUsuario extends StatelessWidget {
  const InfoUsuario({super.key});

  Future<Map<String, dynamic>?> obtenerDatosUsuario() async {
    String? clave = SessionManager().numControl;
    if (clave == null) return null;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(clave).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[900],
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 28, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: obtenerDatosUsuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'No se encontraron datos del usuario.',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset('assets/logoAppbar.png', height: 120),
                const SizedBox(height: 20),
                Text(
                  'INFORMACIÓN DE USUARIO',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.grey[850],
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        filaInfo('Nombre Alumno', data['nombre']),
                        filaInfo('Edad', '${data['edad']}'),
                        filaInfo('Número de Control', data['numControl']),
                        filaInfo('Carrera', data['carrera']),
                        filaInfo('Dirección', data['direccion']),
                        filaInfo('Teléfono', data['telefono']),
                        filaInfo('Nacionalidad', data['nacionalidad']),
                        filaInfo('Fecha de Nacimiento', data['fechaNacimiento']),
                        filaInfo('Tel. Emergencia', data['telefonoEmergencia']),
                        filaInfo('Email', data['email']),
                        const SizedBox(height: 16),
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
    );
  }

  Widget filaInfo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget columnaImagen({required String label, required String imageUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(imageUrl, height: 100),
        ),
      ],
    );
  }
}
