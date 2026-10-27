import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/turno.dart';
import '../models/enums.dart';
import '../util/formato.dart';
import '../viewmodels/app_state.dart';
import '../widgets/acciones.dart';
import '../widgets/avatar_inicial.dart';
import '../widgets/estado_chip.dart';
import '../widgets/turno_no_encontrado.dart';

class DetalleTurnoScreen extends StatelessWidget {
  const DetalleTurnoScreen({super.key, required this.turnoId});
  final String turnoId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: salon,
      builder: (context, _) {
        final t = salon.turnoPorId(turnoId);
        if (t == null) return const TurnoNoEncontrado();
        return _Contenido(turno: t);
      },
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.turno});
  final Turno turno;

  Future<void> _editar(BuildContext context) async {
    final r = await context.push<Turno>('/turno/${turno.id}/editar');
    if (r != null && context.mounted) mostrarGuardado(context, r, abrirDetalle: false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cliente = salon.clientePorId(turno.clienteId);
    final estilista = salon.estilistaPorId(turno.estilistaId);
    final servicios = salon.serviciosDe(turno.servicioIds);
    final dur = salon.duracionTurno(turno);
    final notas = turno.notas;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => volver(context)),
        title: const Text('Detalle del turno'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  AvatarInicial(cliente?.nombre ?? '?', radio: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cliente?.nombre ?? 'Cliente', style: tt.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (cliente != null)
                          Row(children: [
                            Icon(Icons.phone, size: 14, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(telefonoFmt(cliente.telefono),
                                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                          ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  EstadoChip(turno.estado),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _Fila(Icons.calendar_month, 'Fecha', fechaLarga(turno.inicio)),
                  const SizedBox(height: 12),
                  _Fila(Icons.schedule, 'Hora',
                      '${hhmm(turno.inicio)} a ${hhmm(salon.finDe(turno))} (${duracionTxt(dur)})'),
                  const SizedBox(height: 12),
                  _Fila(Icons.person, 'Estilista', estilista?.nombre ?? '-'),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Text('Servicios', style: tt.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  for (final s in servicios)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Expanded(child: Text(s.nombre, style: tt.bodyMedium)),
                        Text('${s.duracionMin} min', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                        const SizedBox(width: 16),
                        Text(dinero(s.precio), style: tt.bodyMedium),
                      ]),
                    ),
                  const Divider(),
                  Row(children: [
                    Expanded(child: Text('Total', style: tt.titleMedium)),
                    Text(dinero(salon.totalTurno(turno)), style: tt.titleMedium),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Text('Notas', style: tt.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 140),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        (notas == null || notas.isEmpty) ? 'Sin notas' : notas,
                        style: tt.bodyMedium?.copyWith(
                            color: (notas == null || notas.isEmpty) ? cs.onSurfaceVariant : cs.onSurface),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Creado el ${ddMMyyyy(turno.creado)} · Modificado el ${ddMMyyyy(turno.modificado)}',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (turno.esProgramado)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _editar(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                  FilledButton.icon(
                    onPressed: () => salon.completarTurno(turno.id),
                    icon: const Icon(Icons.check),
                    label: const Text('Completar'),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
                    onPressed: () => confirmarCancelacion(context, turno),
                    icon: const Icon(Icons.block),
                    label: const Text('Cancelar'),
                  ),
                ],
              )
            else
              Row(children: [
                Icon(Icons.lock, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    turno.estado == EstadoTurno.completado
                        ? 'Turno completado: solo lectura'
                        : 'Turno cancelado: solo lectura',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.icono, this.etiqueta, this.valor);
  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icono, size: 20, color: cs.primary),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(etiqueta, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          Text(valor, style: tt.bodyMedium),
        ]),
      ),
    ]);
  }
}
