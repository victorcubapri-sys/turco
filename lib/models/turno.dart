import 'enums.dart';

class Turno {
  Turno({
    required this.id,
    required this.clienteId,
    required this.estilistaId,
    required this.servicioIds,
    required this.inicio,
    this.notas,
    this.estado = EstadoTurno.programado,
    required this.creado,
    required this.modificado,
  });

  final String id;
  final String clienteId;
  String estilistaId;
  List<String> servicioIds;
  DateTime inicio;
  String? notas;
  EstadoTurno estado;
  final DateTime creado;
  DateTime modificado;

  bool get esProgramado => estado == EstadoTurno.programado;
}
