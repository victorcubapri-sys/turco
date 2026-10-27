import 'package:flutter/material.dart';

import 'app.dart';
import 'viewmodels/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  iniciarEstado();
  runApp(const TurcoApp());
}
