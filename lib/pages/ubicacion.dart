import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

class Ubicacion extends StatefulWidget {
  const Ubicacion({super.key});

  @override
  State<Ubicacion> createState() => _UbicacionState();
}

class _UbicacionState extends State<Ubicacion> {
  GoogleMapController? _mapController;
  final LatLng origen = const LatLng(24.042495005950993, -104.69688386375522);
  final LatLng destino = const LatLng(24.03281575903686, -104.64678790491564);

  Set<Marker> _marcadores = {};
  Set<Polyline> _polilineas = {};
  List<LatLng> _puntosRuta = [];

  final Location _location = Location();
  LatLng? _ubicacionActual;

  @override
  void initState() {
    super.initState();
    _cargarRuta();
    _iniciarUbicacion();
  }

  void _iniciarUbicacion() async {
    bool servicioHabilitado;
    PermissionStatus permiso;

    servicioHabilitado = await _location.serviceEnabled();
    if (!servicioHabilitado) {
      servicioHabilitado = await _location.requestService();
      if (!servicioHabilitado) return;
    }

    permiso = await _location.hasPermission();
    if (permiso == PermissionStatus.denied) {
      permiso = await _location.requestPermission();
      if (permiso != PermissionStatus.granted) return;
    }

    final ubicacion = await _location.getLocation();
    _actualizarUbicacion(ubicacion);

    _location.onLocationChanged.listen((ubicacionNueva) {
      _actualizarUbicacion(ubicacionNueva);
    });
  }

  void _actualizarUbicacion(LocationData data) {
    final nuevaPosicion = LatLng(data.latitude!, data.longitude!);
    setState(() {
      _ubicacionActual = nuevaPosicion;
      _marcadores.removeWhere((m) => m.markerId == const MarkerId("actual"));
      _marcadores.add(
        Marker(
          markerId: const MarkerId("actual"),
          position: nuevaPosicion,
          infoWindow: const InfoWindow(title: "Ubicación actual"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(nuevaPosicion));
  }

  void _cargarRuta() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyCgGWvcgY0m3zfrswye5jZfdVz5BK4scWI", // 👈 Reemplaza con tu clave real
      PointLatLng(origen.latitude, origen.longitude),
      PointLatLng(destino.latitude, destino.longitude),
    );

    if (result.points.isNotEmpty) {
      _puntosRuta = result.points
          .map((punto) => LatLng(punto.latitude, punto.longitude))
          .toList();

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
      appBar: AppBar(title: const Text('Ubicación en Tiempo Real')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _ubicacionActual ?? origen,
          zoom: 14,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: _marcadores,
        polylines: _polilineas,
        myLocationEnabled: false,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
