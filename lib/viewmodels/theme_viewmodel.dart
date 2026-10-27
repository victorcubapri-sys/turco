import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode _modo = ThemeMode.system;
  ThemeMode get modo => _modo;

  void setModo(ThemeMode m) {
    if (m == _modo) return;
    _modo = m;
    notifyListeners();
  }
}
