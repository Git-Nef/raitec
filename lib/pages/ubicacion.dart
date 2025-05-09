import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

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
      "AIzaSyCgGWvcgY0m3zfrswye5jZfdVz5BK4scWI", // reemplaza con tu propia API key
      PointLatLng(origen.latitude, origen.longitude),
      PointLatLng(widget.destino.latitude, widget.destino.longitude),
    );

    if (result.points.isNotEmpty) {
      _puntosRuta = result.points
          .map((punto) => LatLng(punto.latitude, punto.longitude))
          .toList();

      setState(() {
        _polilineas.clear();
        _polilineas.add(
          Polyline(
            polylineId: const PolylineId("ruta"),
            color: Colors.blue,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreRuta ?? 'Ruta en mapa'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.origen,
          zoom: 14,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: _marcadores,
        polylines: _polilineas,
        myLocationEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}
