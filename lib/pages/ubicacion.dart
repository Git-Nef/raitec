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

  LatLng? _paradaSeleccionada;
  bool _paradaEsValida = false;
  bool _mostrarOpciones = false;
  String _metodoPago = 'Efectivo';

  double? _distanciaKm;
  int? _tiempoMin;
  double? _costoCalculado;

  final double _distanciaMaxPermitida = 300; // más flexible

  @override
  void initState() {
    super.initState();
    _inicializarNotificaciones();
    _cargarRutaDesde(widget.origen);
    _escucharAceptacion();
  }

  void _inicializarNotificaciones() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void _mostrarNotificacion(String titulo, String cuerpo) async {
    const androidDetails = AndroidNotificationDetails(
      'notificaciones_rait',
      'Notificaciones de RaiTec',
      importance: Importance.max,
      priority: Priority.high,
    );
    const generalNotificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      titulo,
      cuerpo,
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

      final distanciaTotal = Geolocator.distanceBetween(
        origen.latitude,
        origen.longitude,
        widget.destino.latitude,
        widget.destino.longitude,
      );
      _distanciaKm = (distanciaTotal / 1000);
      _tiempoMin = (_distanciaKm! / 0.7 * 60).round(); // a 40 km/h
      _costoCalculado = (_distanciaKm! * 5).clamp(10, 100);

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
    }
  }

  void _escucharAceptacion() {
    FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uidConductor)
        .collection('rutas')
        .doc(widget.rutaId)
        .collection('pasajeros')
        .doc(widget.uidPasajero)
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data()?['estado'] == 'aceptado') {
        _mostrarNotificacion('¡Conductor en camino!',
            'Tu conductor ha aceptado la solicitud y va hacia tu parada.');

        _mostrarDatosConductor();
      }
    });
  }

  void _mostrarDatosConductor() async {
    final conductorDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uidConductor)
        .get();
    final vehiculoDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uidConductor)
        .collection('vehiculo')
        .doc('info')
        .get();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Información del Conductor"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (conductorDoc.data()?['fotoUrl'] != null)
              Image.network(conductorDoc['fotoUrl'], height: 80),
            Text('Nombre: ${conductorDoc['nombre']}'),
            const SizedBox(height: 8),
            Text('Vehículo: ${vehiculoDoc['marca']} ${vehiculoDoc['modelo']}'),
            Text('Placas: ${vehiculoDoc['placas']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          )
        ],
      ),
    );
  }

  bool _estaCercaDeLaRuta(LatLng punto) {
    for (final p in _puntosRuta) {
      final d = Geolocator.distanceBetween(
        punto.latitude,
        punto.longitude,
        p.latitude,
        p.longitude,
      );
      if (d <= _distanciaMaxPermitida) return true;
    }
    return false;
  }

  Future<void> _pedirRait() async {
    if (_paradaSeleccionada == null || !_paradaEsValida) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selecciona una parada válida sobre la ruta')));
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uidConductor)
        .collection('rutas')
        .doc(widget.rutaId)
        .collection('pasajeros')
        .doc(widget.uidPasajero);

    await ref.set({
      'estado': 'pendiente',
      'metodoPago': _metodoPago,
      'fechaUnion': Timestamp.now(),
      'paradaPersonalizada': {
        'lat': _paradaSeleccionada!.latitude,
        'lng': _paradaSeleccionada!.longitude,
      },
      'distanciaKm': _distanciaKm,
      'tiempoEstimadoMin': _tiempoMin,
      'precioEstimado': _costoCalculado,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Petición enviada al conductor!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nombreRuta)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: widget.origen, zoom: 14),
            onMapCreated: (c) => _mapController = c,
            markers: {
              ..._marcadores,
              if (_paradaSeleccionada != null)
                Marker(
                  markerId: const MarkerId("parada"),
                  position: _paradaSeleccionada!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    _paradaEsValida
                        ? BitmapDescriptor.hueGreen
                        : BitmapDescriptor.hueOrange,
                  ),
                )
            },
            polylines: _polilineas,
            myLocationEnabled: false,
            onTap: (LatLng pos) {
              final valido = _estaCercaDeLaRuta(pos);
              setState(() {
                _paradaSeleccionada = pos;
                _paradaEsValida = valido;
              });
            },
          ),
          if (_mostrarOpciones)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_distanciaKm != null &&
                        _tiempoMin != null &&
                        _costoCalculado != null)
                      Column(
                        children: [
                          Text(
                              'Distancia: ${_distanciaKm!.toStringAsFixed(2)} km'),
                          Text('Tiempo estimado: $_tiempoMin minutos'),
                          Text(
                              'Precio estimado: \$${_costoCalculado!.toStringAsFixed(2)} MXN'),
                          const SizedBox(height: 10),
                        ],
                      ),
                    const Text('Selecciona tu método de pago'),
                    const SizedBox(height: 8),
                    _metodoPagoOption('Efectivo'),
                    _metodoPagoOption('Tarjeta'),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Pedir Rait'),
                      onPressed: _pedirRait,
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
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _metodoPago == metodo
              ? Colors.blue.shade100
              : Colors.grey.shade200,
          border: Border.all(
              color: _metodoPago == metodo ? Colors.blue : Colors.grey,
              width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            Center(child: Text(metodo, style: const TextStyle(fontSize: 16))),
      ),
    );
  }
}
