import 'package:flutter/material.dart';

class InfoCostos extends StatelessWidget {
  const InfoCostos({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.arrow_back_ios_new,
                  size: 28, color: Colors.blueGrey),
              const Icon(Icons.home_filled, size: 30, color: Colors.blueAccent),
              CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://example.com/user-photo.jpg'), // URL de ejemplo para la foto del usuario
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
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/4/44/RAITEC_logo.png',
                height: 90,
              ),
            ),
            const SizedBox(height: 20),

            // Título
            const Text(
              'INFORMACIÓN DE COSTOS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta con info de costos
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    filaInfo('Tarifa base:', '\$5.00'),
                    filaInfo('Costo por kilómetro:', '\$2.00'),
                    filaInfo('Costo por minuto:', '\$0.30'),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'El costo por kilómetros, minutos y tarifa base está sujeto a cambios sin previo aviso.\n\nTe recomendamos estar atento a nuestras actualizaciones y comunicados para conocer cualquier modificación en nuestras tarifas.',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        textAlign: TextAlign.justify,
                      ),
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
            flex: 1,
            child: Text(
              valor,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
