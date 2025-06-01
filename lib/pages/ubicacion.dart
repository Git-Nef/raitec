import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

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

  final double _distanciaMaxPermitida = 300;

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
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (_) {},
    );
  }

  void _mostrarNotificacion(String titulo, String cuerpo) async {
    const androidDetails = AndroidNotificationDetails(
      'canal_ruta',
      'Notificaciones de RaiTec',
      channelDescription: 'Notificaciones sobre el estado del viaje',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableLights: true,
      color: Colors.blue,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(0, titulo, cuerpo, notificationDetails);
  }

  Future<void> _cargarRutaDesde(LatLng origen) async {
    final result = await PolylinePoints().getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(origen.latitude, origen.longitude),
        destination: PointLatLng(widget.destino.latitude, widget.destino.longitude),
        mode: TravelMode.driving,
      ),
      googleApiKey: "AIzaSyCgGWvcgY0m3zfrswye5jZfdVz5BK4scWI",
    );

    if (result.points.isNotEmpty) {
      _puntosRuta = result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

      setState(() {
        _polilineas = {
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
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
          Marker(
            markerId: const MarkerId("destino"),
            position: widget.destino,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
        backgroundColor: Colors.grey[900],
        title: Text("Información del Conductor", style: GoogleFonts.poppins(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (conductorDoc.data()?['fotografiaUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(conductorDoc['fotografiaUrl'], height: 80),
              ),
            const SizedBox(height: 8),
            Text('Nombre: ${conductorDoc['nombre']}',
                style: GoogleFonts.poppins(color: Colors.white)),
            Text(
              'Vehículo: ${vehiculoDoc['marca']} ${vehiculoDoc['modelo']}',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            Text('Placas: ${vehiculoDoc['matricula']}',
                style: GoogleFonts.poppins(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.blue)),
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

    final distanciaTotal = Geolocator.distanceBetween(
      _paradaSeleccionada!.latitude,
      _paradaSeleccionada!.longitude,
      widget.destino.latitude,
      widget.destino.longitude,
    );

    setState(() {
      _distanciaKm = distanciaTotal / 1000;
      const velocidadKmH = 40.0;
      _tiempoMin = ((_distanciaKm! / velocidadKmH) * 60).round();
      _costoCalculado = (_distanciaKm! * 5).clamp(10, 100);
    });
  }

  Future<void> _pedirRait() async {
    if (_paradaSeleccionada == null || !_paradaEsValida) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[400],
          content: Text('Selecciona una parada válida',
              style: GoogleFonts.poppins(color: Colors.white)),
        ),
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
      SnackBar(
        backgroundColor: Colors.black87,
        content: Text('¡Petición enviada al conductor!',
            style: GoogleFonts.poppins(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.nombreRuta,
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: widget.origen, zoom: 14),
            onMapCreated: (controller) => _mapController = controller,
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
                ),
            },
            polylines: _polilineas,
            myLocationEnabled: false,
            onTap: (pos) async {
              final valido = _estaCercaDeLaRuta(pos);
              setState(() {
                _paradaSeleccionada = pos;
                _paradaEsValida = valido;
              });
              if (valido) await _calcularPrecioDesdeParada();
              else setState(() {
                _distanciaKm = null;
                _tiempoMin = null;
                _costoCalculado = null;
              });
            },
          ),
          if (_mostrarOpciones)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_distanciaKm != null)
                      Column(
                        children: [
                          Text('Distancia: ${_distanciaKm!.toStringAsFixed(2)} km',
                              style: GoogleFonts.poppins()),
                          Text('Tiempo: $_tiempoMin min',
                              style: GoogleFonts.poppins()),
                          Text('Precio: \$${_costoCalculado!.toStringAsFixed(2)} MXN',
                              style: GoogleFonts.poppins()),
                          const SizedBox(height: 10),
                        ],
                      ),
                    Text('Selecciona tu método de pago',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _metodoPagoOption('Efectivo'),
                    _metodoPagoOption('Tarjeta'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: (_paradaEsValida && _costoCalculado != null) ? _pedirRait : null,
                      icon: const Icon(Icons.send),
                      label: Text('Pedir Rait', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !_mostrarOpciones
          ? FloatingActionButton.extended(
        onPressed: () => setState(() => _mostrarOpciones = true),
        label: Text('PEDIR RAIT', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _metodoPago == metodo ? Colors.blue.shade100 : Colors.grey.shade200,
          border: Border.all(
              color: _metodoPago == metodo ? Colors.blue : Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(metodo,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
