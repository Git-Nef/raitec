import 'package:flutter/material.dart';
import 'package:raitec/DataType/data.dart';

class InfoUsuario extends StatelessWidget {
  const InfoUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    final estudiante = estudianteEjemplo;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.arrow_back_ios_new, size: 28, color: Colors.blueGrey),
              Icon(Icons.home_filled, size: 30, color: Colors.blueAccent),
              CircleAvatar(
                backgroundImage: NetworkImage(estudiante.fotografiaUrl),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo
            Center(
              child: Image.asset(
                'assets/logoAppbar.png',
                height: 150,
              ),
            ),
            const SizedBox(height: 20),

            // Título
            const Text(
              'INFORMACIÓN DE USUARIO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta con info
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    filaInfo('Nombre Alumno', estudiante.nombre),
                    filaInfo('Edad', '${estudiante.edad}'),
                    filaInfo('Número de Control', estudiante.numControl),
                    filaInfo('Carrera', estudiante.carrera),
                    filaInfo('Dirección', estudiante.direccion),
                    filaInfo('Teléfono', estudiante.telefono),
                    filaInfo('Nacionalidad', estudiante.nacionalidad),
                    filaInfo('Fecha de Nacimiento', estudiante.fechaNacimiento),
                    filaInfo(
                        'Teléfono Emergencia', estudiante.telefonoEmergencia),

                    const SizedBox(height: 16),

                    // Foto y firma
                    Row(
                      children: [
                        Expanded(
                          child: columnaImagen(
                            label: 'Fotografía',
                            imageUrl: estudiante.fotografiaUrl,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: columnaImagen(
                            label: 'Firma Estudiante',
                            imageUrl: estudiante.firmaUrl,
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor,
              style: const TextStyle(fontSize: 16),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
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
