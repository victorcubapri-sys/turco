import 'enums.dart';

class Cliente {
  Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.genero,
    this.correo,
    required this.fechaRegistro,
  });

  final String id;
  String nombre;
  String telefono;
  Genero genero;
  String? correo;
  final DateTime fechaRegistro;
}
