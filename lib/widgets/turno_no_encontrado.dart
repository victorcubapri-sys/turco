import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'acciones.dart';
import 'estado_vacio.dart';

class TurnoNoEncontrado extends StatelessWidget {
  const TurnoNoEncontrado({super.key, this.titulo = 'Detalle del turno'});
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => volver(context)),
        title: Text(titulo),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: EstadoVacio(
            icono: Icons.event_busy,
            titulo: 'No encontramos este turno',
            mensaje: 'El turno no existe o ya no está disponible.',
            accion: FilledButton(
              onPressed: () => context.go('/agenda'),
              child: const Text('Volver a la agenda'),
            ),
          ),
        ),
      ),
    );
  }
}
