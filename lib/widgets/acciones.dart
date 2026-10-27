import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/turno.dart';
import '../router.dart';
import '../util/formato.dart';
import '../viewmodels/app_state.dart';

void volver(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/agenda');
  }
}

/// Diálogo de confirmación y cancelación. Devuelve true si se canceló.
Future<bool> confirmarCancelacion(BuildContext context, Turno t) async {
  final cliente = salon.clientePorId(t.clienteId)?.nombre ?? 'este cliente';
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: const Text('¿Cancelar este turno?'),
        content: Text(
          'El horario de $cliente (${hhmm(t.inicio)} a ${hhmm(salon.finDe(t))}) quedará libre. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Volver')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancelar turno'),
          ),
        ],
      );
    },
  );
  if (ok == true) return salon.cancelarTurno(t.id);
  return false;
}

void mostrarGuardado(BuildContext context, Turno t, {bool abrirDetalle = true}) {
  agenda.irA(t.inicio);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('Turno guardado para el ${fechaCorta(t.inicio)}'),
      action: abrirDetalle
          ? SnackBarAction(label: 'Ver', onPressed: () => router.push('/turno/${t.id}'))
          : null,
    ));
}

/// Abre el formulario de nuevo turno y muestra el aviso al volver.
Future<void> abrirNuevoTurno(BuildContext context,
    {String? clienteId, String? servicioId, DateTime? fecha}) async {
  final t = await context.push<Turno>(
    '/turno/nuevo',
    extra: TurnoNuevoExtra(clienteId: clienteId, servicioId: servicioId, fecha: fecha),
  );
  if (t != null && context.mounted) {
    mostrarGuardado(context, t);
  }
}
