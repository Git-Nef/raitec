import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class SeguimientoViaje extends StatefulWidget {
  final String uidConductor;
  final String rutaId;

  const SeguimientoViaje({
    super.key,
    required this.uidConductor,
    required this.rutaId,
  });

  @override
  State<SeguimientoViaje> createState() => _SeguimientoViajeState();
}

class _SeguimientoViajeState extends State<SeguimientoViaje> {
  GoogleMapController? _mapController;
  Location location = Location();
  LatLng? _ubicacionActual;
  List<LatLng> _paradas = [];
  LatLng? _destinoFinal;
  LatLng? _origenRuta;
  Set<Polyline> _polilineas = {};
  Set<Marker> _marcadores = {};
  BitmapDescriptor? _autoIcono;

  @override
  void initState() {
    super.initState();
    _cargarIconoAuto();
    _obtenerDatosYCalcularRuta();
    _iniciarSeguimiento();
  }

  Future<void> _cargarIconoAuto() async {
    _autoIcono = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/auto.png',
    );
  }

  Future<void> _obtenerDatosYCalcularRuta() async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uidConductor)
        .collection('rutas')
        .doc(widget.rutaId)
        .get();

    final data = doc.data();
    if (data == null) return;

    final origen = data['origen'];
    final destino = data['destino'];
    final pasajerosSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uidConductor)
        .collection('rutas')
        .doc(widget.rutaId)
        .collection('pasajeros')
        .where('estado', isEqualTo: 'aceptado')
        .get();

    List<LatLng> paradas = pasajerosSnapshot.docs.map((doc) {
      final parada = doc['paradaPersonalizada'];
      return LatLng(parada['lat'], parada['lng']);
    }).toList();

    final origenLatLng = LatLng(origen['lat'], origen['lng']);
    paradas.sort((a, b) {
      final d1 = (a.latitude - origenLatLng.latitude).abs() +
          (a.longitude - origenLatLng.longitude).abs();
      final d2 = (b.latitude - origenLatLng.latitude).abs() +
          (b.longitude - origenLatLng.longitude).abs();
      return d1.compareTo(d2);
    });

    setState(() {
      _origenRuta = origenLatLng;
      _destinoFinal = LatLng(destino['lat'], destino['lng']);
      _paradas = paradas;
    });

    await _calcularRutaCompleta();
  }

  Future<void> _calcularRutaCompleta() async {
    if (_origenRuta == null || _destinoFinal == null) return;

    final puntos = [_origenRuta!, ..._paradas, _destinoFinal!];
    List<LatLng> rutaCompleta = [];
    Set<Marker> nuevosMarcadores = {};

    // Agrega marcador del destino final
    nuevosMarcadores.add(
      Marker(
        markerId: const MarkerId('destino'),
        position: _destinoFinal!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destino final'),
      ),
    );

    // Agrega marcadores para las paradas
    for (int i = 0; i < _paradas.length; i++) {
      nuevosMarcadores.add(
        Marker(
          markerId: MarkerId('parada_$i'),
          position: _paradas[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: 'Parada ${i + 1}'),
        ),
      );
    }

    // Construcción de la ruta
    for (int i = 0; i < puntos.length - 1; i++) {
      final origen = puntos[i];
      final destino = puntos[i + 1];

      final result = await PolylinePoints().getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origen.latitude, origen.longitude),
          destination: PointLatLng(destino.latitude, destino.longitude),
          mode: TravelMode.driving,
        ),
        googleApiKey: "AIzaSyCgGWvcgY0m3zfrswye5jZfdVz5BK4scWI",
      );
      if (result.points.isNotEmpty) {
        rutaCompleta.addAll(
          result.points.map((p) => LatLng(p.latitude, p.longitude)),
        );
      }
    }
    setState(() {
      _polilineas = {
        Polyline(
          polylineId: const PolylineId('ruta'),
          color: Colors.blue,
          width: 5,
          points: rutaCompleta,
        )
      };
      _marcadores.addAll(nuevosMarcadores);
    });
  }

  void _iniciarSeguimiento() {
    location.onLocationChanged.listen((loc) async {
      final nuevaUbicacion = LatLng(loc.latitude!, loc.longitude!);

      setState(() {
        _ubicacionActual = nuevaUbicacion;
        _marcadores.removeWhere((m) => m.markerId.value == 'conductor');
        _marcadores.add(
          Marker(
            markerId: const MarkerId('conductor'),
            position: nuevaUbicacion,
            icon: _autoIcono ?? BitmapDescriptor.defaultMarker,
            infoWindow: const InfoWindow(title: 'Tú (conductor)'),
          ),
        );
      });
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.uidConductor)
          .collection('ubicacion')
          .doc('actual')
          .set({
        'lat': loc.latitude,
        'lng': loc.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(nuevaUbicacion));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento del Viaje')),
      body: _origenRuta == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition:
        CameraPosition(target: _origenRuta!, zoom: 14),
        onMapCreated: (c) => _mapController = c,
        markers: _marcadores,
        polylines: _polilineas,
        myLocationEnabled: false,
        zoomControlsEnabled: true,
      ),
    );
  }
}
