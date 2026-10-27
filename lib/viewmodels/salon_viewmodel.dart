import 'package:flutter/foundation.dart';

import '../models/catalogo.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/turno.dart';
import '../util/formato.dart';

class ReglaNegocioException implements Exception {
  const ReglaNegocioException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

class ResumenDia {
  const ResumenDia(this.programados, this.completados, this.ingreso);
  final int programados;
  final int completados;
  final int ingreso;
}

T? _buscar<T>(Iterable<T> it, bool Function(T) f) {
  for (final e in it) {
    if (f(e)) return e;
  }
  return null;
}

class SalonViewModel extends ChangeNotifier {
  SalonViewModel({
    required this.servicios,
    required this.estilistas,
    required List<Cliente> clientes,
    required List<Turno> turnos,
    DateTime Function()? reloj,
  })  : _clientes = clientes,
        _turnos = turnos,
        _reloj = reloj ?? DateTime.now;

  static const int apertura = 9 * 60;
  static const int cierre = 19 * 60;
  static const int paso = 30;
  static final List<int> franjas = [for (var m = apertura; m < cierre; m += paso) m];

  final List<Servicio> servicios;
  final List<Estilista> estilistas;
  final List<Cliente> _clientes;
  final List<Turno> _turnos;
  final DateTime Function() _reloj;
  int _seq = 1000;

  DateTime get ahora => _reloj();
  List<Cliente> get clientes => List.unmodifiable(_clientes);
  List<Turno> get turnos => List.unmodifiable(_turnos);

  String _nuevoId(String p) => '$p${_seq++}';

  Servicio? servicioPorId(String id) => _buscar(servicios, (s) => s.id == id);
  Estilista? estilistaPorId(String id) => _buscar(estilistas, (e) => e.id == id);
  Cliente? clientePorId(String id) => _buscar(_clientes, (c) => c.id == id);
  Turno? turnoPorId(String id) => _buscar(_turnos, (t) => t.id == id);

  List<Servicio> serviciosDe(Iterable<String> ids) =>
      [for (final id in ids) ?servicioPorId(id)];

  // ---- Calculados ----
  int duracionMin(Iterable<String> ids) =>
      serviciosDe(ids).fold(0, (a, s) => a + s.duracionMin);
  int totalPrecio(Iterable<String> ids) =>
      serviciosDe(ids).fold(0, (a, s) => a + s.precio);
  int duracionTurno(Turno t) => duracionMin(t.servicioIds);
  int totalTurno(Turno t) => totalPrecio(t.servicioIds);
  DateTime finDe(Turno t) => t.inicio.add(Duration(minutes: duracionTurno(t)));

  // ---- Reglas de calendario ----
  bool esLaborable(DateTime d) => d.weekday != DateTime.sunday;
  bool fechaValida(DateTime d) =>
      esLaborable(d) && !soloFecha(d).isBefore(soloFecha(ahora));

  DateTime proximaFechaValida([DateTime? desde]) {
    var d = soloFecha(desde ?? ahora);
    final hoy = soloFecha(ahora);
    if (d.isBefore(hoy)) d = hoy;
    while (!esLaborable(d)) {
      d = sumarDias(d, 1);
    }
    return d;
  }

  DateTime _inicio(DateTime fecha, int minuto) =>
      DateTime(fecha.year, fecha.month, fecha.day, minuto ~/ 60, minuto % 60);

  List<Estilista> estilistasPara(Iterable<String> ids) {
    final lista = ids.toList();
    if (lista.isEmpty) return [];
    return estilistas.where((e) => lista.every(e.servicioIds.contains)).toList();
  }

  /// Devuelve null si la franja está libre; si no, el motivo.
  String? motivoNoDisponible({
    required DateTime fecha,
    required int minutoInicio,
    required List<String> servicioIds,
    required String estilistaId,
    String? clienteId,
    String? excluirTurnoId,
  }) {
    if (!esLaborable(fecha)) return 'El salón está cerrado los domingos.';
    final inicio = _inicio(fecha, minutoInicio);
    if (inicio.isBefore(ahora)) return 'No se puede reservar en el pasado.';
    final dur = duracionMin(servicioIds);
    if (minutoInicio + dur > cierre) return 'El turno terminaría después de las 19:00.';
    final est = estilistaPorId(estilistaId);
    if (est == null || !servicioIds.every(est.servicioIds.contains)) {
      return 'El estilista no realiza todos los servicios elegidos.';
    }
    final fin = inicio.add(Duration(minutes: dur));
    for (final t in _turnos) {
      if (!t.esProgramado || t.id == excluirTurnoId) continue;
      final mismoActor = t.estilistaId == estilistaId || (clienteId != null && t.clienteId == clienteId);
      if (mismoActor && inicio.isBefore(finDe(t)) && t.inicio.isBefore(fin)) {
        return 'Ese horario ya está ocupado.';
      }
    }
    return null;
  }

  // ---- Turnos ----
  String? _limpiarNotas(String? n) {
    final t = n?.trim() ?? '';
    if (t.length > 500) throw const ReglaNegocioException('Las notas admiten máximo 500 caracteres.');
    return t.isEmpty ? null : t;
  }

  void _validar({
    required String? clienteId,
    required String? estilistaId,
    required List<String> servicioIds,
    required DateTime fecha,
    required int minutoInicio,
    String? excluir,
  }) {
    if (clienteId == null || clientePorId(clienteId) == null) {
      throw const ReglaNegocioException('Selecciona un cliente.');
    }
    if (servicioIds.isEmpty) throw const ReglaNegocioException('Elige al menos un servicio.');
    if (estilistaId == null) throw const ReglaNegocioException('Selecciona un estilista.');
    final m = motivoNoDisponible(
      fecha: fecha, minutoInicio: minutoInicio, servicioIds: servicioIds,
      estilistaId: estilistaId, clienteId: clienteId, excluirTurnoId: excluir,
    );
    if (m != null) throw ReglaNegocioException(m);
  }

  Turno crearTurno({
    required String clienteId,
    required String estilistaId,
    required List<String> servicioIds,
    required DateTime fecha,
    required int minutoInicio,
    String? notas,
  }) {
    _validar(clienteId: clienteId, estilistaId: estilistaId, servicioIds: servicioIds, fecha: fecha, minutoInicio: minutoInicio);
    final n = ahora;
    final t = Turno(
      id: _nuevoId('t'), clienteId: clienteId, estilistaId: estilistaId,
      servicioIds: List.of(servicioIds), inicio: _inicio(fecha, minutoInicio),
      notas: _limpiarNotas(notas), creado: n, modificado: n,
    );
    _turnos.add(t);
    notifyListeners();
    return t;
  }

  Turno editarTurno(
    String id, {
    required String estilistaId,
    required List<String> servicioIds,
    required DateTime fecha,
    required int minutoInicio,
    String? notas,
  }) {
    final t = turnoPorId(id);
    if (t == null) throw const ReglaNegocioException('El turno no existe.');
    if (!t.esProgramado) throw const ReglaNegocioException('Solo se pueden editar turnos programados.');
    _validar(clienteId: t.clienteId, estilistaId: estilistaId, servicioIds: servicioIds, fecha: fecha, minutoInicio: minutoInicio, excluir: id);
    t
      ..estilistaId = estilistaId
      ..servicioIds = List.of(servicioIds)
      ..inicio = _inicio(fecha, minutoInicio)
      ..notas = _limpiarNotas(notas)
      ..modificado = ahora;
    notifyListeners();
    return t;
  }

  bool completarTurno(String id) => _cambiarEstado(id, EstadoTurno.completado);
  bool cancelarTurno(String id) => _cambiarEstado(id, EstadoTurno.cancelado);

  bool _cambiarEstado(String id, EstadoTurno nuevo) {
    final t = turnoPorId(id);
    if (t == null || !t.esProgramado) return false;
    t
      ..estado = nuevo
      ..modificado = ahora;
    notifyListeners();
    return true;
  }

  List<Turno> turnosDelDia(DateTime fecha, {String? estilistaId, EstadoTurno? estado}) {
    final r = _turnos
        .where((t) =>
            mismoDia(t.inicio, fecha) &&
            (estilistaId == null || t.estilistaId == estilistaId) &&
            (estado == null || t.estado == estado))
        .toList()
      ..sort((a, b) => a.inicio.compareTo(b.inicio));
    return r;
  }

  ResumenDia resumenDia(DateTime fecha, {String? estilistaId}) {
    final dia = turnosDelDia(fecha, estilistaId: estilistaId);
    final prog = dia.where((t) => t.estado == EstadoTurno.programado).length;
    final comp = dia.where((t) => t.estado == EstadoTurno.completado).length;
    final ingreso = dia
        .where((t) => t.estado != EstadoTurno.cancelado)
        .fold(0, (a, t) => a + totalTurno(t));
    return ResumenDia(prog, comp, ingreso);
  }

  int turnosHoyDe(String estilistaId) => turnosDelDia(ahora, estilistaId: estilistaId)
      .where((t) => t.estado != EstadoTurno.cancelado)
      .length;

  int get programadosHoy =>
      turnosDelDia(ahora).where((t) => t.esProgramado).length;

  List<Turno> turnosDeCliente(String clienteId) =>
      _turnos.where((t) => t.clienteId == clienteId).toList()
        ..sort((a, b) => b.inicio.compareTo(a.inicio));

  List<Turno> programadosDeCliente(String clienteId) =>
      turnosDeCliente(clienteId).where((t) => t.esProgramado).toList();

  // ---- Clientes ----
  String? validarNombre(String? v) {
    final n = (v ?? '').trim();
    return (n.length < 3 || n.length > 60) ? 'Escribe entre 3 y 60 caracteres' : null;
  }

  String? validarTelefono(String? v, {String? excluirId}) {
    final t = (v ?? '').trim();
    if (!RegExp(r'^\d{8}$').hasMatch(t)) return 'Debe tener exactamente 8 dígitos';
    if (_clientes.any((c) => c.telefono == t && c.id != excluirId)) {
      return 'Ya existe un cliente con este teléfono';
    }
    return null;
  }

  String? validarCorreo(String? v) {
    final c = (v ?? '').trim();
    if (c.isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(c) ? null : 'Escribe un correo válido';
  }

  Cliente crearCliente({
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    final e = validarNombre(nombre) ?? validarTelefono(telefono) ?? validarCorreo(correo);
    if (e != null) throw ReglaNegocioException(e);
    final c = Cliente(
      id: _nuevoId('c'), nombre: nombre.trim(), telefono: telefono.trim(), genero: genero,
      correo: (correo?.trim().isEmpty ?? true) ? null : correo!.trim(), fechaRegistro: ahora,
    );
    _clientes.add(c);
    notifyListeners();
    return c;
  }

  void editarCliente(
    String id, {
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    final c = clientePorId(id);
    if (c == null) return;
    final e = validarNombre(nombre) ?? validarTelefono(telefono, excluirId: id) ?? validarCorreo(correo);
    if (e != null) throw ReglaNegocioException(e);
    c
      ..nombre = nombre.trim()
      ..telefono = telefono.trim()
      ..genero = genero
      ..correo = (correo?.trim().isEmpty ?? true) ? null : correo!.trim();
    notifyListeners();
  }

  /// Mensaje de bloqueo si el cliente no se puede eliminar; null si sí.
  String? bloqueoEliminar(String clienteId) {
    final c = clientePorId(clienteId);
    final n = programadosDeCliente(clienteId).length;
    if (c == null || n == 0) return null;
    return 'No se puede eliminar: ${c.nombre} tiene $n ${n == 1 ? 'turno programado' : 'turnos programados'}.';
  }

  void eliminarCliente(String id) {
    final m = bloqueoEliminar(id);
    if (m != null) throw ReglaNegocioException(m);
    _turnos.removeWhere((t) => t.clienteId == id);
    _clientes.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
