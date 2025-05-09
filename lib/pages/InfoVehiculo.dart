import 'package:flutter/material.dart';
import 'package:raitec/pages/InfoUsuario.dart';
import 'package:raitec/pages/misrutas.dart';
import 'package:raitec/pages/PrincipalUsuario.dart';
import 'package:raitec/pages/Registro.dart';
import 'package:raitec/pages/ISConductores.dart';

class InfoVehiculo extends StatelessWidget {
  const InfoVehiculo({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> vehiculo = {
      'Marca': 'Toyota',
      'Modelo': 'Corolla',
      'Año': '2020',
      'Matrícula': 'ABC-1234',
      'Color': 'Rojo',
      'Seguro': 'GNP Seguros',
      'Asientos': '5',
      'Nacionalidad': 'Mexicana',
      'Características': 'Bluetooth, Aire Acondicionado, ABS',
      'Foto':
          'https://upload.wikimedia.org/wikipedia/commons/9/9e/2019_Toyota_Corolla_Icon_Tech_VVT-i_HEV_CVT_1.8_Front.jpg',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 42, color: Colors.white),
                    onPressed: () {
                      // Acción de perfil
                    },
                  ),
                ),
              ),

              // Ícono de Home centrado
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: const Icon(Icons.home, size: 42, color: Colors.white),
                  onPressed: () {
                    // Acción de Home
                  },
                ),
              ),

              // Ícono de Perfil a la derecha
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.account_circle,
                        size: 42, color: Colors.white),
                    onPressed: () {
                      // Acción de perfil
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoFila(
      BuildContext context, List<String> labels, List<String> values) {
    return Column(
      children: [
        Row(
          children: labels
              .map((text) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ))
              .toList(),
        ),
        Row(
          children: values
              .map((text) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey.shade300),
                          right: BorderSide(color: Colors.grey.shade300),
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
