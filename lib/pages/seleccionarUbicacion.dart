import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class SeleccionarUbicacion extends StatefulWidget {
  const SeleccionarUbicacion({super.key});

  @override
  State<SeleccionarUbicacion> createState() => _SeleccionarUbicacionState();
}

class _SeleccionarUbicacionState extends State<SeleccionarUbicacion> {
  GoogleMapController? _mapController;
  LatLng? _ubicacionSeleccionada;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _determinarUbicacionInicial();
  }

  Future<void> _determinarUbicacionInicial() async {
    bool habilitado = await _location.serviceEnabled();
    if (!habilitado) {
      habilitado = await _location.requestService();
      if (!habilitado) return;
    }

    PermissionStatus permiso = await _location.hasPermission();
    if (permiso == PermissionStatus.denied) {
      permiso = await _location.requestPermission();
      if (permiso != PermissionStatus.granted) return;
    }

    final ubicacion = await _location.getLocation();
    final latLng = LatLng(ubicacion.latitude!, ubicacion.longitude!);

    setState(() {
      _ubicacionSeleccionada = latLng;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  void _alTocarMapa(LatLng posicion) {
    setState(() {
      _ubicacionSeleccionada = posicion;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(posicion));
  }

  void _confirmarUbicacion() {
    if (_ubicacionSeleccionada != null) {
      Navigator.pop(context, _ubicacionSeleccionada);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Selecciona tu punto de partida',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: _ubicacionSeleccionada == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _ubicacionSeleccionada!,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _alTocarMapa,
            markers: {
              Marker(
                markerId: const MarkerId('origen'),
                position: _ubicacionSeleccionada!,
                infoWindow: const InfoWindow(title: 'Tu punto de partida'),
              ),
            },
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _confirmarUbicacion,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text(
                'Confirmar ubicación',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
