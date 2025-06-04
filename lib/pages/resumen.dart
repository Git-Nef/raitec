import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ResumenYCalificacion extends StatefulWidget {
  final String uidConductor;

  const ResumenYCalificacion({super.key, required this.uidConductor});

  @override
  State<ResumenYCalificacion> createState() => _ResumenYCalificacionState();
}

class _ResumenYCalificacionState extends State<ResumenYCalificacion> {
  double _calificacion = 3.0;
  bool _enviado = false;

  Future<void> _guardarCalificacion() async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uidConductor)
        .collection('calificaciones')
        .add({
      'calificacion': _calificacion,
      'fecha': Timestamp.now(),
    });

    setState(() {
      _enviado = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Gracias por tu calificación!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Resumen del Viaje'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
              const SizedBox(height: 20),
              Text(
                '¡Tu viaje ha finalizado!',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                '¿Cómo calificarías a tu conductor?',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Slider(
                value: _calificacion,
                onChanged: _enviado ? null : (valor) {
                  setState(() {
                    _calificacion = valor;
                  });
                },
                min: 1,
                max: 5,
                divisions: 4,
                label: _calificacion.toString(),
                activeColor: Colors.blueAccent,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _enviado ? null : _guardarCalificacion,
                child: Text(
                  _enviado ? 'Enviado' : 'Enviar calificación',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
