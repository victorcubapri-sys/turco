import 'package:flutter/foundation.dart';

import '../models/catalogo.dart';
import '../models/enums.dart';
import 'salon_viewmodel.dart';

class ServiciosViewModel extends ChangeNotifier {
  ServiciosViewModel(this._salon);

  final SalonViewModel _salon;
  Categoria? _categoria;
  FiltroPublico _publico = FiltroPublico.todos;

  Categoria? get categoria => _categoria;
  FiltroPublico get publico => _publico;

  void setCategoria(Categoria? c) {
    _categoria = c;
    notifyListeners();
  }

  void setPublico(FiltroPublico p) {
    _publico = p;
    notifyListeners();
  }

  List<Servicio> get filtrados => _salon.servicios
      .where((s) => (_categoria == null || s.categoria == _categoria) && _publico.admite(s.publico))
      .toList();
}
