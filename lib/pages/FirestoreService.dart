import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crear usuario (pasajero o conductor)
  Future<void> crearUsuario(String uid, Map<String, dynamic> data) async {
    await _db.collection('usuarios').doc(uid).set(data);
  }

  /// Subir documento individual del conductor (horario, kardex, licencia, etc.)
  Future<void> subirDocumento(
      String uid, String tipo, String urlArchivo) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .collection('documentos')
        .doc(tipo)
        .set({'url': urlArchivo});
  }

  /// Guardar información del vehículo como subcolección de usuario
  Future<void> guardarVehiculo(String uid, Map<String, dynamic> data) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .collection('vehiculo')
        .doc('info')
        .set(data);
  }

  /// Crear ruta (nivel global)
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

  /// Actualizar datos del usuario
  Future<void> actualizarUsuario(String uid, Map<String, dynamic> data) async {
    await _db.collection('usuarios').doc(uid).update(data);
  }

  /// Obtener documentos del conductor
  Stream<QuerySnapshot> obtenerDocumentos(String uid) {
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('documentos')
        .snapshots();
  }

  /// Obtener información del vehículo del usuario
  Future<DocumentSnapshot> obtenerVehiculo(String uid) async {
    return await _db
        .collection('usuarios')
        .doc(uid)
        .collection('vehiculo')
        .doc('info')
        .get();
  }

  /// Eliminar ruta
  Future<void> eliminarRuta(String rutaId) async {
    await _db.collection('rutas').doc(rutaId).delete();
  }
}
