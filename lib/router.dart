import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/agenda_screen.dart';
import 'screens/clientes_screen.dart';
import 'screens/detalle_turno_screen.dart';
import 'screens/estilistas_screen.dart';
import 'screens/servicios_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/turno_form_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class TurnoNuevoExtra {
  const TurnoNuevoExtra({this.clienteId, this.servicioId, this.fecha});
  final String? clienteId;
  final String? servicioId;
  final DateTime? fecha;
}

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/agenda',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ShellScreen(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/agenda',
            builder: (context, state) =>
                AgendaScreen(estilistaId: state.uri.queryParameters['estilista']),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/clientes', builder: (context, state) => const ClientesScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/servicios', builder: (context, state) => const ServiciosScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/estilistas', builder: (context, state) => const EstilistasScreen()),
        ]),
      ],
    ),
    GoRoute(
      path: '/turno/nuevo',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          TurnoFormScreen(extra: state.extra is TurnoNuevoExtra ? state.extra as TurnoNuevoExtra : null),
    ),
    GoRoute(
      path: '/turno/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => DetalleTurnoScreen(turnoId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/turno/:id/editar',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => TurnoFormScreen(turnoId: state.pathParameters['id']),
    ),
  ],
);
