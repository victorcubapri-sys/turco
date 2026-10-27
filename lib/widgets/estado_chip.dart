import 'package:flutter/material.dart';

import '../models/enums.dart';

class EstadoChip extends StatelessWidget {
  const EstadoChip(this.estado, {super.key});
  final EstadoTurno estado;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, texto) = switch (estado) {
      EstadoTurno.programado => (cs.primaryContainer, cs.onPrimaryContainer),
      EstadoTurno.completado => (cs.tertiaryContainer, cs.onTertiaryContainer),
      EstadoTurno.cancelado => (cs.errorContainer, cs.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(8)),
      child: Text(
        estado.etiqueta,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: texto),
      ),
    );
  }
}
