class Estudiante {
  final String nombre;
  final int edad;
  final String numControl;
  final String carrera;
  final String direccion;
  final String telefono;
  final String nacionalidad;
  final String fechaNacimiento;
  final String telefonoEmergencia;
  final String fotografiaUrl;
  final String firmaUrl;

  Estudiante({
    required this.nombre,
    required this.edad,
    required this.numControl,
    required this.carrera,
    required this.direccion,
    required this.telefono,
    required this.nacionalidad,
    required this.fechaNacimiento,
    required this.telefonoEmergencia,
    required this.fotografiaUrl,
    required this.firmaUrl,
  });
}

final estudianteEjemplo = Estudiante(
  nombre: 'Ana López',
  edad: 21,
  numControl: '20201234',
  carrera: 'Ingeniería en Sistemas',
  direccion: 'Av. Siempre Viva 742',
  telefono: '555-1234-567',
  nacionalidad: 'Mexicana',
  fechaNacimiento: '2003-05-14',
  telefonoEmergencia: '555-7654-321',
  fotografiaUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
  firmaUrl: 'https://via.placeholder.com/150x50?text=Firma',
);
