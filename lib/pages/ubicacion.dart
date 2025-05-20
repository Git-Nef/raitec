import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class Ubicacion extends StatefulWidget {
  final LatLng origen;
  final LatLng destino;
  final String? nombreRuta;

  const Ubicacion({
    super.key,
    required this.origen,
    required this.destino,
    this.nombreRuta,
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
  double _precioCalculado = 0;

  final double tarifaBase = 5.0;
  final double costoPorKm = 2.0;
  final double costoPorMinuto = 0.30;

  @override
  void initState() {
    super.initState();
    _inicializarNotificaciones();
    _cargarRutaDesde(widget.origen);
  }

  void _inicializarNotificaciones() async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void _mostrarNotificacionLlegada() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'canal_ruta',
      'Llegada a destino',
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.blue,
    );

    const NotificationDetails generalNotificationDetails =
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
      "AIzaSyCgGWvcgY0m3zfrswye5jZfdVz5BK4scWI", // Reemplaza con tu API Key
      PointLatLng(origen.latitude, origen.longitude),
      PointLatLng(widget.destino.latitude, widget.destino.longitude),
    );

    if (result.points.isNotEmpty) {
      _puntosRuta = result.points.map((punto) => LatLng(punto.latitude, punto.longitude)).toList();

      double distanciaTotal = 0;
      for (int i = 0; i < _puntosRuta.length - 1; i++) {
        distanciaTotal += Geolocator.distanceBetween(
              _puntosRuta[i].latitude,
              _puntosRuta[i].longitude,
              _puntosRuta[i + 1].latitude,
              _puntosRuta[i + 1].longitude,
            ) / 1000;
      }

      double tiempoEstimado = distanciaTotal / 0.333;

      setState(() {
        _precioCalculado = tarifaBase + (distanciaTotal * costoPorKm) + (tiempoEstimado * costoPorMinuto);
        _precioCalculado = double.parse(_precioCalculado.toStringAsFixed(2));

        _polilineas.clear();
        _polilineas.add(
          Polyline(
            polylineId: const PolylineId("ruta"),
            color: Colors.blueAccent,
            width: 5,
            points: _puntosRuta,
          ),
        );

        _marcadores = {
          Marker(
            markerId: const MarkerId("origen"),
            position: widget.origen,
            infoWindow: const InfoWindow(title: "Origen"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
          Marker(
            markerId: const MarkerId("destino"),
            position: widget.destino,
            infoWindow: const InfoWindow(title: "Destino"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        };
      });

      _verificarLlegada(origen);
    }
  }

  void _verificarLlegada(LatLng actual) {
    final double distancia = Geolocator.distanceBetween(
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

  void _mostrarModalPedirRait() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.75,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Resumen del viaje', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: const Text('Punto de partida'),
                  subtitle: Text(widget.origen.toString()),
                ),
                ListTile(
                  leading: const Icon(Icons.flag, color: Colors.red),
                  title: const Text('Destino'),
                  subtitle: Text(widget.destino.toString()),
                ),
                const Divider(height: 32),
                const Text('Costo estimado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Tarifa base: \$${tarifaBase.toStringAsFixed(2)}'),
                Text('Total estimado: \$${_precioCalculado.toStringAsFixed(2)}'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('¡Rait solicitado por \$${_precioCalculado.toStringAsFixed(2)}! 🚗💨'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar Rait'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.nombreRuta ?? 'Ruta en mapa',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.origen,
          zoom: 14,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: _marcadores,
        polylines: _polilineas,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
      bottomSheet: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Efectivo',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _mostrarModalPedirRait,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pedir Rait - \$${_precioCalculado.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.directions_car, color: Colors.black),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
