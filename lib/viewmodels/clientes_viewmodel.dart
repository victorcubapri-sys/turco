import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../models/enums.dart';
import '../util/formato.dart';
import 'salon_viewmodel.dart';

class ClientesViewModel extends ChangeNotifier {
  ClientesViewModel(this._salon);

  final SalonViewModel _salon;
  String _consulta = '';
  Genero? _genero;

  String get consulta => _consulta;
  Genero? get genero => _genero;

  void setConsulta(String q) {
    _consulta = q;
    notifyListeners();
  }

  void setGenero(Genero? g) {
    _genero = g;
    notifyListeners();
  }

  List<Cliente> get filtrados {
    final q = normaliza(_consulta);
    final digitos = _consulta.replaceAll(RegExp(r'\D'), '');
    final r = _salon.clientes.where((c) {
      if (_genero != null && c.genero != _genero) return false;
      if (q.isEmpty) return true;
      return normaliza(c.nombre).contains(q) ||
          (digitos.isNotEmpty && c.telefono.contains(digitos));
    }).toList()
      ..sort((a, b) => normaliza(a.nombre).compareTo(normaliza(b.nombre)));
    return r;
  }

  String get resumen {
    final l = filtrados;
    final m = l.where((c) => c.genero == Genero.mujer).length;
    final h = l.length - m;
    return '${l.length} ${l.length == 1 ? 'cliente' : 'clientes'} · $m ${m == 1 ? 'mujer' : 'mujeres'} · $h ${h == 1 ? 'hombre' : 'hombres'}';
  }
}
