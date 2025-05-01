import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crear usuario (pasajero o conductor)
  Future<void> crearUsuario(String uid, Map<String, dynamic> data) async {
    await _db.collection('usuarios').doc(uid).set(data);
  }

  /// Registrar vehículo
  Future<void> registrarVehiculo(Map<String, dynamic> data) async {
    await _db.collection('vehiculos').add(data);
  }

  /// Subir documentos del conductor
  Future<void> subirDocumentosConductor(
      String uid, Map<String, dynamic> data) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .collection('documentos')
        .add(data);
  }

  /// Crear ruta
  Future<void> crearRuta(Map<String, dynamic> data) async {
    await _db.collection('rutas').add(data);
  }

  /// Obtener todas las rutas disponibles (Stream para usar con StreamBuilder)
  Stream<QuerySnapshot> obtenerRutasDisponibles() {
    return _db
        .collection('rutas')
        .orderBy('fechaPublicacion', descending: true)
        .snapshots();
  }

  /// Obtener información de un usuario
  Future<DocumentSnapshot> obtenerUsuario(String uid) async {
    return await _db.collection('usuarios').doc(uid).get();
  }

  /// Obtener vehículos por usuario
  Stream<QuerySnapshot> obtenerVehiculosUsuario(String uid) {
    return _db
        .collection('vehiculos')
        .where('idUsuario', isEqualTo: uid)
        .snapshots();
  }

  /// Actualizar datos de un usuario
  Future<void> actualizarUsuario(String uid, Map<String, dynamic> data) async {
    await _db.collection('usuarios').doc(uid).update(data);
  }

  /// Eliminar un vehículo
  Future<void> eliminarVehiculo(String vehiculoId) async {
    await _db.collection('vehiculos').doc(vehiculoId).delete();
  }

  /// Eliminar ruta
  Future<void> eliminarRuta(String rutaId) async {
    await _db.collection('rutas').doc(rutaId).delete();
  }
}
