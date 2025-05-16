import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ubicacion extends StatefulWidget {
  final LatLng origen;
  final LatLng destino;
  final String nombreRuta;
  final String rutaId;
  final String uidConductor;
  final String uidPasajero;
  final Map<String, dynamic> datosRuta;

  const Ubicacion({
    super.key,
    required this.origen,
    required this.destino,
    required this.nombreRuta,
    required this.rutaId,
    required this.uidConductor,
    required this.uidPasajero,
    required this.datosRuta,
  });

  @override
  State<Ubicacion> createState() => _UbicacionState();
}

class _UbicacionState extends State<Ubicacion> {
  GoogleMapController? _mapController;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Set<Marker> _marcadores = {};
  Set<Polyline> _polilineas = {};
  List<LatLng> _puntosRuta = [];

  bool _notificado = false;
  bool _uniendose = false;
  String _metodoPago = 'Efectivo';
  bool _mostrarOpciones = false;

  LatLng? _paradaSeleccionada;
  bool _paradaEsValida = false;

  double _distanciaTotalKm = 0.0;
  double _tiempoEstimadoMin = 0.0;

  final double _distanciaMaxPermitida = 400;

  @override
  void initState() {
    super.initState();
    _inicializarNotificaciones();
    _cargarRutaDesde(widget.origen);
  }

  void _inicializarNotificaciones() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void _mostrarNotificacionLlegada() async {
    const androidDetails = AndroidNotificationDetails(
      'canal_ruta',
      'Llegada a destino',
      importance: Importance.max,
      priority: Priority.high,
    );
    const generalNotificationDetails =
        NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      '¡Has llegado!',
      'Estás en tu destino final.',
      generalNotificationDetails,
    );
  }

  Future<void> _cargarRutaDesde(LatLng origen) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyCgGWvcgY0m3zfrswye5jZfdVz5BK4scWI",
      PointLatLng(origen.latitude, origen.longitude),
      PointLatLng(widget.destino.latitude, widget.destino.longitude),
    );

    if (result.points.isNotEmpty) {
      _puntosRuta =
          result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

      _distanciaTotalKm = 0;
      for (int i = 0; i < _puntosRuta.length - 1; i++) {
        _distanciaTotalKm += Geolocator.distanceBetween(
              _puntosRuta[i].latitude,
              _puntosRuta[i].longitude,
              _puntosRuta[i + 1].latitude,
              _puntosRuta[i + 1].longitude,
            ) /
            1000;
      }
      _tiempoEstimadoMin = (_distanciaTotalKm / 30) * 60;

      setState(() {
        _polilineas.clear();
        _polilineas.add(Polyline(
          polylineId: const PolylineId("ruta"),
          color: Colors.blue,
          width: 5,
          points: _puntosRuta,
        ));

        _marcadores = {
          Marker(
            markerId: const MarkerId("origen"),
            position: widget.origen,
            infoWindow: const InfoWindow(title: "Origen"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
          Marker(
            markerId: const MarkerId("destino"),
            position: widget.destino,
            infoWindow: const InfoWindow(title: "Destino"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        };
      });

      _verificarLlegada(origen);
    }
  }

  void _verificarLlegada(LatLng actual) {
    final distancia = Geolocator.distanceBetween(
      actual.latitude,
      actual.longitude,
      widget.destino.latitude,
      widget.destino.longitude,
    );

    if (distancia <= 20 && !_notificado) {
      _notificado = true;
      _mostrarNotificacionLlegada();
    }
  }

  Future<void> _pedirRait() async {
    if (_paradaSeleccionada == null || !_paradaEsValida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Selecciona una parada válida tocando cerca de la ruta')),
      );
      return;
    }

    setState(() => _uniendose = true);

    try {
      final ref = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.uidConductor)
          .collection('rutas')
          .doc(widget.rutaId)
          .collection('pasajeros')
          .doc(widget.uidPasajero);

      final existe = await ref.get();
      if (existe.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya estás unido a esta ruta')),
        );
        setState(() => _uniendose = false);
        return;
      }

      await ref.set({
        'estado': 'pendiente',
        'metodoPago': _metodoPago,
        'fechaUnion': Timestamp.now(),
        'paradaPersonalizada': {
          'lat': _paradaSeleccionada!.latitude,
          'lng': _paradaSeleccionada!.longitude,
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Petición enviada al conductor!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _uniendose = false);
  }

  bool _estaCercaDeLaRuta(LatLng punto) {
    for (final rutaPunto in _puntosRuta) {
      final distancia = Geolocator.distanceBetween(
        punto.latitude,
        punto.longitude,
        rutaPunto.latitude,
        rutaPunto.longitude,
      );
      if (distancia <= _distanciaMaxPermitida) {
        return true;
      }
    }
    return false;
  }

  void _centrarRuta() {
    if (_puntosRuta.isEmpty || _mapController == null) return;

    final bounds = LatLngBounds(
      southwest: _puntosRuta.reduce((a, b) =>
          LatLng(min(a.latitude, b.latitude), min(a.longitude, b.longitude))),
      northeast: _puntosRuta.reduce((a, b) =>
          LatLng(max(a.latitude, b.latitude), max(a.longitude, b.longitude))),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreRuta),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: widget.origen, zoom: 14),
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              ..._marcadores,
              if (_paradaSeleccionada != null)
                Marker(
                  markerId: const MarkerId("parada"),
                  position: _paradaSeleccionada!,
                  infoWindow: const InfoWindow(title: "Tu parada"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(_paradaEsValida
                      ? BitmapDescriptor.hueGreen
                      : BitmapDescriptor.hueOrange),
                ),
            },
            polylines: _polilineas,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            onTap: (LatLng posicion) {
              final esValida = _estaCercaDeLaRuta(posicion);
              setState(() {
                _paradaSeleccionada = posicion;
                _paradaEsValida = esValida;
              });

              if (!esValida) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Esa parada está fuera de la ruta. Selecciona una más cercana.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
          ),
          Positioned(
            top: 15,
            left: 10,
            right: 10,
            child: Card(
              color: Colors.white.withOpacity(0.9),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Distancia: ${_distanciaTotalKm.toStringAsFixed(2)} km • Estimado: ${_tiempoEstimadoMin.toStringAsFixed(0)} min',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 10,
            child: FloatingActionButton(
              mini: true,
              onPressed: _centrarRuta,
              backgroundColor: Colors.white,
              child: const Icon(Icons.center_focus_strong, color: Colors.blue),
            ),
          ),
          if (_mostrarOpciones)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Selecciona tu método de pago:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _metodoPagoOption('Efectivo'),
                    const SizedBox(height: 8),
                    _metodoPagoOption('Tarjeta'),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: _uniendose
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.send),
                      label: const Text('Pedir Rait'),
                      onPressed: _uniendose ? null : _pedirRait,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !_mostrarOpciones
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _mostrarOpciones = true),
              label: const Text('PEDIR RAIT'),
              icon: const Icon(Icons.directions_car),
              backgroundColor: Colors.blueAccent,
            )
          : null,
    );
  }

  Widget _metodoPagoOption(String metodo) {
    return GestureDetector(
      onTap: () => setState(() => _metodoPago = metodo),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _metodoPago == metodo
              ? Colors.blue.shade100
              : Colors.grey.shade100,
          border: Border.all(
            color: _metodoPago == metodo ? Colors.blue : Colors.grey,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            Center(child: Text(metodo, style: const TextStyle(fontSize: 16))),
      ),
    );
  }
}
