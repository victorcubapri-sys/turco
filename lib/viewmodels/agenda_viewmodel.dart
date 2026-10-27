import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/turno.dart';
import '../util/formato.dart';
import 'salon_viewmodel.dart';

class AgendaViewModel extends ChangeNotifier {
  AgendaViewModel(this._salon) : _fecha = soloFecha(_salon.ahora);

  final SalonViewModel _salon;
  DateTime _fecha;
  String? _estilistaId;
  EstadoTurno? _estado;

  DateTime get fecha => _fecha;
  String? get estilistaId => _estilistaId;
  EstadoTurno? get estado => _estado;
  bool get esDomingo => _fecha.weekday == DateTime.sunday;

  List<DateTime> get diasSemana {
    final lunes = sumarDias(_fecha, -(_fecha.weekday - 1));
    return [for (var i = 0; i < 7; i++) sumarDias(lunes, i)];
  }

  List<Turno> get turnos => esDomingo
      ? const []
      : _salon.turnosDelDia(_fecha, estilistaId: _estilistaId, estado: _estado);

  ResumenDia get resumen => _salon.resumenDia(_fecha, estilistaId: _estilistaId);

  void irA(DateTime d) {
    _fecha = soloFecha(d);
    notifyListeners();
  }

  void moverSemana(int dir) => irA(sumarDias(_fecha, 7 * dir));

  void setEstilista(String? id) {
    _estilistaId = id;
    notifyListeners();
  }

  void setEstado(EstadoTurno? e) {
    _estado = e;
    notifyListeners();
  }
}
