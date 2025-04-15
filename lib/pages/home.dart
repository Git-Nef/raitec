import 'package:flutter/material.dart';

class Home extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Raitec"),
      ),
      body: Center(
        child: Column(
          children: [

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Subir Foto'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Ver Datos'),
        ]),
    );
  }

}
