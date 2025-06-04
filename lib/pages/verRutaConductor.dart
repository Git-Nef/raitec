import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:raitec/pages/resumen.dart';

class VerRutaConductor extends StatefulWidget {
  final String uidConductor;
  final Map<String, dynamic> parada;

  const VerRutaConductor({
    super.key,
    required this.uidConductor,
    required this.parada,
  });

  @override
  State<VerRutaConductor> createState() => _VerRutaConductorState();
}

class _VerRutaConductorState extends State<VerRutaConductor> {
  GoogleMapController? _mapController;
  LatLng? _ubicacionConductor;
  LatLng? _destinoFinal;
  Set<Marker> _marcadores = {};
  bool _cargando = true;
  BitmapDescriptor? _iconoAuto;
  bool _navegado = false;

  @override
  void initState() {
    super.initState();
    _cargarIconoAuto();
    _cargarDestinoDesdeFirestore();
    _escucharUbicacionConductor();
  }

  Future<void> _cargarIconoAuto() async {
    final icono = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/auto.png',
    );
    setState(() {
      _iconoAuto = icono;
    });
  }

  Future<void> _cargarDestinoDesdeFirestore() async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uidConductor)
        .collection('rutas')
        .doc('info')
        .get();

    if (doc.exists && doc.data() != null) {
      final destino = doc.data()!['destino'];
      setState(() {
        _destinoFinal = LatLng(destino['lat'], destino['lng']);
      });
    }
  }

  void _escucharUbicacionConductor() {
    FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uidConductor)
        .collection('ubicacion')
        .doc('actual')
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data() != null && _destinoFinal != null) {
        final data = doc.data()!;
        final nuevaUbicacion = LatLng(data['lat'], data['lng']);

        setState(() {
          _ubicacionConductor = nuevaUbicacion;
          _cargando = false;
          _actualizarMarcadores();
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(nuevaUbicacion),
        );

        _verificarLlegadaAlDestino(nuevaUbicacion);
      }
    });
  }

  void _verificarLlegadaAlDestino(LatLng ubicacionActual) {
    if (_destinoFinal == null) return;

    final distancia = Geolocator.distanceBetween(
      ubicacionActual.latitude,
      ubicacionActual.longitude,
      _destinoFinal!.latitude,
      _destinoFinal!.longitude,
    );

    if (distancia < 30 && !_navegado) {
      _navegado = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResumenYCalificacion(uidConductor: widget.uidConductor),
        ),
      );
    }
  }

  void _actualizarMarcadores() {
    final paradaLatLng = LatLng(
      widget.parada['lat'],
      widget.parada['lng'],
    );

    final marcadores = <Marker>{
      Marker(
        markerId: const MarkerId('parada'),
        position: paradaLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Tu parada'),
      ),
    };

    if (_destinoFinal != null) {
      marcadores.add(
        Marker(
          markerId: const MarkerId('destino_final'),
          position: _destinoFinal!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Destino final'),
        ),
      );
    }

    if (_ubicacionConductor != null && _iconoAuto != null) {
      marcadores.add(
        Marker(
          markerId: const MarkerId('conductor'),
          position: _ubicacionConductor!,
          icon: _iconoAuto!,
          infoWindow: const InfoWindow(title: 'Conductor'),
        ),
      );
    }

    setState(() {
      _marcadores = marcadores;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paradaLatLng = LatLng(
      widget.parada['lat'],
      widget.parada['lng'],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta del Conductor'),
      ),
      body: _cargando || _iconoAuto == null || _destinoFinal == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _ubicacionConductor ?? paradaLatLng,
          zoom: 14,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: _marcadores,
        myLocationEnabled: false,
        zoomControlsEnabled: true,
      ),
    );
  }
}
