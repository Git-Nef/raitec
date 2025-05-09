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
  final String email;

  // Información de costos
  final double tarifaBase;
  final double costoPorKilometro;
  final double costoPorMinuto;

  // Información del vehículo
  final String marcaCoche;
  final String modeloCoche;
  final String anioCoche;
  final String matricula;
  final String colorCoche;
  final String seguroVehiculo;
  final int numeroAsientos;
  final String caracteristicas;
  final String fotoVehiculoUrl;

  // Información de la ruta
  final String ruta;
  final String conductor;
  final String emailConductor;
  final String telefonoConductor;
  final String horarioRuta;
  final double precioRuta;

  Estudiante({
    required this.nombre,
    required this.email,
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
    required this.tarifaBase,
    required this.costoPorKilometro,
    required this.costoPorMinuto,
    required this.marcaCoche,
    required this.modeloCoche,
    required this.anioCoche,
    required this.matricula,
    required this.colorCoche,
    required this.seguroVehiculo,
    required this.numeroAsientos,
    required this.caracteristicas,
    required this.fotoVehiculoUrl,


    required this.ruta,
    required this.conductor,
    required this.emailConductor,
    required this.telefonoConductor,
    required this.horarioRuta,
    required this.precioRuta,
  });
}


final estudianteEjemplo = Estudiante(
  nombre: 'Ana López',
  email: 'ejemplo@gmail.com',
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

  tarifaBase: 5.00,
  costoPorKilometro: 2.00,
  costoPorMinuto: 0.30,

  marcaCoche: 'Nissan',
  modeloCoche: 'Versa',
  anioCoche: '2020',
  matricula: 'ABC-123',
  colorCoche: 'Rojo',
  seguroVehiculo: 'GNP',
  numeroAsientos: 4,
  caracteristicas: 'Aire acondicionado, bluetooth',
  fotoVehiculoUrl: 'https://via.placeholder.com/150x100?text=Vehiculo',

  ruta: 'RUTA: GUSTAVO DÍAZ ORDAZ',
  conductor: 'Luis Ángel Maldonado Reyes',
  emailConductor: 'luisangel@rutas.edu.mx',
  telefonoConductor: '618-222-5009',
  horarioRuta: 'Lunes a Jueves de 13:00 PM a 14:00 PM',
  precioRuta: 30,
);
