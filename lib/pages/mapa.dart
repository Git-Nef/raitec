import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  GoogleMapController? _mapController;
  final LatLng origen = const LatLng(24.042495005950993, -104.69688386375522); // CDMX centro
  final LatLng destino = const LatLng(24.03281575903686, -104.64678790491564); // Punto cercano

  Set<Marker> _marcadores = {};
  Set<Polyline> _polilineas = {};
  List<LatLng> _puntosRuta = [];

  @override
  void initState() {
    super.initState();
    _cargarRuta();
  }

  void _cargarRuta() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyCgGWvcgY0m3zfrswye5jZfdVz5BK4scWI", // 👈 Reemplaza esto con tu API Key real
      PointLatLng(origen.latitude, origen.longitude),
      PointLatLng(destino.latitude, destino.longitude),
    );

    if (result.points.isNotEmpty) {
      _puntosRuta.clear();
      for (var punto in result.points) {
        _puntosRuta.add(LatLng(punto.latitude, punto.longitude));
      }

      setState(() {
        _polilineas.add(
          Polyline(
            polylineId: const PolylineId("ruta"),
            color: Colors.blue,
            width: 5,
            points: _puntosRuta,
          ),
        );

        _marcadores.addAll([
          Marker(markerId: const MarkerId("origen"), position: origen),
          Marker(markerId: const MarkerId("destino"), position: destino),
        ]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta en Google Maps')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: origen, zoom: 14),
        onMapCreated: (controller) => _mapController = controller,
        markers: _marcadores,
        polylines: _polilineas,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
