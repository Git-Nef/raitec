import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:raitec/pages/ViajeFinalizado.dart';

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
  StreamSubscription<LocationData>? _locationSubscription;
  LatLng? _ubicacionActual;
  List<LatLng> _paradas = [];
  LatLng? _destinoFinal;
  LatLng? _origenRuta;
  Set<Polyline> _polilineas = {};
  Set<Marker> _marcadores = {};
  BitmapDescriptor? _autoIcono;
  Map<String, LatLng> _paradasConPasajero = {}; // uidPasajero -> LatLng
  Set<String> _confirmados = {}; // uidPasajero
  bool _dialogoMostrado = false;
  bool _viajeFinalizado = false;

  @override
  void initState() {
    super.initState();
    _cargarIconoAuto();
    _obtenerDatosYCalcularRuta();
    _iniciarSeguimiento();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
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

    List<LatLng> paradas = [];
    for (var doc in pasajerosSnapshot.docs) {
      final data = doc.data();
      final uidPasajero = doc.id;
      final parada = data['paradaPersonalizada'];
      final latLng = LatLng(parada['lat'], parada['lng']);
      paradas.add(latLng);
      _paradasConPasajero[uidPasajero] = latLng;
    }

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

    nuevosMarcadores.add(
      Marker(
        markerId: const MarkerId('destino'),
        position: _destinoFinal!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destino final'),
      ),
    );

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
    _locationSubscription = location.onLocationChanged.listen((loc) async {
      if (!mounted) return;

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

      for (final entry in _paradasConPasajero.entries) {
        final uidPasajero = entry.key;
        final parada = entry.value;
        final distancia = Geolocator.distanceBetween(
          nuevaUbicacion.latitude,
          nuevaUbicacion.longitude,
          parada.latitude,
          parada.longitude,
        );

        if (distancia < 15 && !_confirmados.contains(uidPasajero) && !_dialogoMostrado) {
          _dialogoMostrado = true;
          _mostrarDialogoConfirmacion(uidPasajero);
          break;
        }
      }

      if (_destinoFinal != null && !_viajeFinalizado) {
        final distanciaADestino = Geolocator.distanceBetween(
          nuevaUbicacion.latitude,
          nuevaUbicacion.longitude,
          _destinoFinal!.latitude,
          _destinoFinal!.longitude,
        );

        if (distanciaADestino < 30) {
          _viajeFinalizado = true;
          _finalizarViaje();
        }
      }

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

  void _finalizarViaje() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ViajeFinalizado(
          uidConductor: widget.uidConductor,
          rutaId: widget.rutaId,
        ),
      ),
    );
  }

  void _mostrarDialogoConfirmacion(String uidPasajero) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar abordaje'),
        content: const Text('¿El pasajero ya abordó el vehículo?'),
        actions: [
          TextButton(
            onPressed: () {
              _dialogoMostrado = false;
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _confirmados.add(uidPasajero);
              _dialogoMostrado = false;

              await FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(widget.uidConductor)
                  .collection('rutas')
                  .doc(widget.rutaId)
                  .collection('pasajeros')
                  .doc(uidPasajero)
                  .update({'abordado': true});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pasajero marcado como abordado')),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
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
