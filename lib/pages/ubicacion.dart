import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

class Ubicacion extends StatefulWidget {
  const Ubicacion({super.key});

  @override
  State<Ubicacion> createState() => _UbicacionState();
}

class _UbicacionState extends State<Ubicacion> {
  GoogleMapController? _mapController;
  final LatLng destino = const LatLng(24.04303129543229, -104.69710006029678);
  final Location _location = Location();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Set<Marker> _marcadores = {};
  Set<Polyline> _polilineas = {};
  List<LatLng> _puntosRuta = [];
  LatLng? _ubicacionActual;
  bool _notificado = false;

  @override
  void initState() {
    super.initState();
    _inicializarNotificaciones();
    _iniciarUbicacion();
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
    AndroidNotificationDetails('canal_ruta', 'Llegada a destino',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Llegaste al destino');

    const NotificationDetails generalNotificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '¡Has llegado!',
      'Estás en tu destino final.',
      generalNotificationDetails,
    );
  }

  void _iniciarUbicacion() async {
    bool servicioHabilitado = await _location.serviceEnabled();
    if (!servicioHabilitado) {
      servicioHabilitado = await _location.requestService();
      if (!servicioHabilitado) return;
    }

    PermissionStatus permiso = await _location.hasPermission();
    if (permiso == PermissionStatus.denied) {
      permiso = await _location.requestPermission();
      if (permiso != PermissionStatus.granted) return;
    }

    final ubicacionInicial = await _location.getLocation();
    _actualizarUbicacion(ubicacionInicial);

    _location.onLocationChanged.listen((ubicacionNueva) {
      _actualizarUbicacion(ubicacionNueva);
    });
  }

  void _actualizarUbicacion(LocationData data) async {
    final nuevaUbicacion = LatLng(data.latitude!, data.longitude!);
    _ubicacionActual = nuevaUbicacion;

    _marcadores.removeWhere((m) => m.markerId == const MarkerId("actual"));
    _marcadores.add(
      Marker(
        markerId: const MarkerId("actual"),
        position: nuevaUbicacion,
        infoWindow: const InfoWindow(title: "Tú estás aquí"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLng(nuevaUbicacion));

    await _cargarRutaDesde(nuevaUbicacion);
    _verificarLlegada(nuevaUbicacion);
  }

  Future<void> _cargarRutaDesde(LatLng origenActual) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyCgGWvcgY0m3zfrswye5jZfdVz5BK4scWI", // Reemplaza con tu API key
      PointLatLng(origenActual.latitude, origenActual.longitude),
      PointLatLng(destino.latitude, destino.longitude),
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

        _marcadores.removeWhere((m) => m.markerId == const MarkerId("destino"));
        _marcadores.add(
          Marker(
            markerId: const MarkerId("destino"),
            position: destino,
            infoWindow: const InfoWindow(title: "Destino"),
          ),
        );
      });
    }
  }

  void _verificarLlegada(LatLng actual) {
    final double distancia = Geolocator.distanceBetween(
      actual.latitude,
      actual.longitude,
      destino.latitude,
      destino.longitude,
    );

    if (distancia <= 20 && !_notificado) {
      _notificado = true;
      _mostrarNotificacionLlegada();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta Dinámica en Tiempo Real')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _ubicacionActual ?? destino,
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
