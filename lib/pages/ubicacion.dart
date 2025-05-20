import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  void initState() {
    super.initState();
    _solicitarPermisosNotificacion();
    _inicializarNotificaciones();
    _cargarRutaDesde(widget.origen);
    _escucharAceptacion();
  }

  void _solicitarPermisosNotificacion() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
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
      'Notificaciones de RaiTec',
      channelDescription: 'Notificaciones sobre el estado del viaje',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails generalNotificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      titulo,
      cuerpo,
      notificationDetails,
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
            color: Colors.blueAccent,
            width: 5,
            points: _puntosRuta,
          )
        };

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
            if (conductorDoc.data()?['fotografiaUrl'] != null)
              Image.network(conductorDoc['fotografiaUrl'], height: 80),
            Text('Nombre: ${conductorDoc['nombre']}'),
            const SizedBox(height: 8),
            Text('Vehículo: ${vehiculoDoc['marca']} ${vehiculoDoc['modelo']}'),
            Text('Placas: ${vehiculoDoc['matricula']}'),
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

  Future<void> _calcularPrecioDesdeParada() async {
    if (_paradaSeleccionada == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(
            _paradaSeleccionada!.latitude, _paradaSeleccionada!.longitude),
        destination:
        PointLatLng(widget.destino.latitude, widget.destino.longitude),
        mode: TravelMode.driving,
      ),
      googleApiKey: "AIzaSyCgGWvcgY0m3zfrswye5jZfdVz5BK4scWI",
    );

    final distanciaTotal = Geolocator.distanceBetween(
      _paradaSeleccionada!.latitude,
      _paradaSeleccionada!.longitude,
      widget.destino.latitude,
      widget.destino.longitude,
    );
    setState(() {
      _distanciaKm = distanciaTotal / 1000;
      _tiempoMin = (_distanciaKm! / 0.7 * 60).round();
      _costoCalculado = (_distanciaKm! * 5).clamp(10, 100);
    });
  }

  Future<void> _pedirRait() async {
    if (_paradaSeleccionada == null || !_paradaEsValida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una parada válida')),
      );
      return;
    }

    await _calcularPrecioDesdeParada();

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