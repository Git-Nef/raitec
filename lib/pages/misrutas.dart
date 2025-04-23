import 'package:flutter/material.dart';

class MisRutas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Image.asset(
          'assets/logo_raitec.png',
          height: 40,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: Drawer(), // Si tienes un Drawer personalizado
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '¿No tienes ninguna ruta registrada?\nLlena el siguiente formulario.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Acción para registrar ruta
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D66D0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 6,
              ),
              child: const Text(
                'REGISTRAR RUTA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 35),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'TUS RUTAS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _rutaCard(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        elevation: 8,
        color: Colors.white,
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.black54),
              Icon(Icons.home_filled, size: 28, color: Color(0xFF0D66D0)),
              CircleAvatar(
                backgroundImage: AssetImage('assets/foto_usuario.png'),
                radius: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rutaCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/foto_usuario.png'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'RUTA: GUSTAVO DÍAZ ORDAZ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0D66D0),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text('Luis Angel Maldonado Reyes',
                      style: TextStyle(fontSize: 14)),
                  Text('21041298@utdurango.edu.mx',
                      style: TextStyle(fontSize: 13)),
                  Text('(+52) 618-322-5070', style: TextStyle(fontSize: 13)),
                  Text('Lunes a Jueves de 13:00 P.M a 14:00 P.M',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
