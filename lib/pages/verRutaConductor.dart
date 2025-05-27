import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Set<Marker> _marcadores = {};
  bool _cargando = true;
  BitmapDescriptor? _iconoAuto;

  @override
  void initState() {
    super.initState();
    _cargarIconoAuto();
    _escucharUbicacionConductor();
  }

  Future<void> _cargarIconoAuto() async {
    final icono = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/auto.png', // Asegúrate que el nombre y la ruta coincidan
    );
    setState(() {
      _iconoAuto = icono;
    });
  }

  void _escucharUbicacionConductor() {
    FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uidConductor)
        .collection('ubicacion')
        .doc('actual')
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data() != null) {
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
      }
    });
  }

  void _actualizarMarcadores() {
    final paradaLatLng = LatLng(
      widget.parada['lat'],
      widget.parada['lng'],
    );

    _marcadores = {
      Marker(
        markerId: const MarkerId('parada'),
        position: paradaLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Tu parada'),
      ),
    };

    if (_ubicacionConductor != null && _iconoAuto != null) {
      _marcadores.add(
        Marker(
          markerId: const MarkerId('conductor'),
          position: _ubicacionConductor!,
          icon: _iconoAuto!,
          infoWindow: const InfoWindow(title: 'Conductor'),
        ),
      );
    }
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
      body: _cargando || _iconoAuto == null
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
