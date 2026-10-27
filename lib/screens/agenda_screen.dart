import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../models/turno.dart';
import '../util/formato.dart';
import '../viewmodels/app_state.dart';
import '../widgets/acciones.dart';
import '../widgets/estado_chip.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/resumen_card.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key, this.estilistaId});
  final String? estilistaId;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  static const double _anchoDia = 64;
  final _tira = ScrollController();

  @override
  void initState() {
    super.initState();
    _aplicarFiltroInicial();
    agenda.addListener(_centrarDia);
    WidgetsBinding.instance.addPostFrameCallback((_) => _centrarDia());
  }

  @override
  void didUpdateWidget(covariant AgendaScreen old) {
    super.didUpdateWidget(old);
    if (widget.estilistaId != old.estilistaId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _aplicarFiltroInicial());
    }
  }

  void _aplicarFiltroInicial() {
    final id = widget.estilistaId;
    if (id != null && salon.estilistaPorId(id) != null && agenda.estilistaId != id) {
      agenda.setEstilista(id);
    }
  }

  void _centrarDia() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_tira.hasClients) return;
      final idx = agenda.fecha.weekday - 1;
      final destino = (idx * (_anchoDia + 8) - (_tira.position.viewportDimension - _anchoDia) / 2)
          .clamp(0.0, _tira.position.maxScrollExtent);
      _tira.animateTo(destino, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    agenda.removeListener(_centrarDia);
    _tira.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final r = await showDatePicker(
      context: context,
      initialDate: agenda.fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Elegir fecha',
    );
    if (r != null) agenda.irA(r);
  }

  Future<void> _nuevoTurno() => abrirNuevoTurno(context, fecha: agenda.fecha);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Icon(Icons.content_cut, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Turco'),
        ]),
        actions: [
          ListenableBuilder(
            listenable: temaVm,
            builder: (context, _) => PopupMenuButton<ThemeMode>(
              icon: const Icon(Icons.brightness_6),
              tooltip: 'Tema',
              initialValue: temaVm.modo,
              onSelected: temaVm.setModo,
              itemBuilder: (_) => const [
                PopupMenuItem(value: ThemeMode.system, child: Text('Sistema')),
                PopupMenuItem(value: ThemeMode.light, child: Text('Claro')),
                PopupMenuItem(value: ThemeMode.dark, child: Text('Oscuro')),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoTurno,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo turno'),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([salon, agenda]),
        builder: (context, _) {
          final lista = agenda.turnos;
          return ListView.builder(
            key: const PageStorageKey('agenda_lista'),
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: 1 + (lista.isEmpty ? 1 : lista.length),
            itemBuilder: (context, i) {
              if (i == 0) return _encabezado(context);
              if (lista.isEmpty) return _vacio();
              return _TarjetaTurno(turno: lista[i - 1]);
            },
          );
        },
      ),
    );
  }

  Widget _vacio() {
    if (agenda.esDomingo) {
      return const EstadoVacio(
        icono: Icons.event_busy,
        titulo: 'Domingo: salón cerrado',
        mensaje: 'Elige otro día para ver o crear turnos.',
      );
    }
    return const EstadoVacio(
      icono: Icons.search_off,
      titulo: 'No hay turnos para este día',
      mensaje: 'Crea el primer turno con el botón de abajo o cambia los filtros.',
    );
  }

  Widget _encabezado(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final r = agenda.resumen;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Semana anterior',
              onPressed: () => agenda.moverSemana(-1),
            ),
            Expanded(
              child: Text(mesAnio(agenda.fecha), textAlign: TextAlign.center, style: tt.titleLarge),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Semana siguiente',
              onPressed: () => agenda.moverSemana(1),
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.calendar_month),
              tooltip: 'Elegir fecha',
              onPressed: _elegirFecha,
            ),
          ]),
          SizedBox(
            height: 76,
            child: ListView.builder(
              controller: _tira,
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, i) {
                final d = agenda.diasSemana[i];
                final sel = mismoDia(d, agenda.fecha);
                final domingo = d.weekday == DateTime.sunday;
                final fondo = sel ? cs.primaryContainer : cs.surfaceContainer;
                final texto = sel ? cs.onPrimaryContainer : cs.onSurface;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: fondo,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => agenda.irA(d),
                      child: SizedBox(
                        width: _anchoDia,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(diasCorto[i], style: tt.labelSmall?.copyWith(color: texto)),
                            const SizedBox(height: 4),
                            Text('${d.day}', style: tt.titleMedium?.copyWith(color: texto)),
                            if (domingo) Icon(Icons.lock, size: 12, color: texto),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ResumenCard(valor: '${r.programados}', etiqueta: 'Programados')),
            const SizedBox(width: 8),
            Expanded(child: ResumenCard(valor: '${r.completados}', etiqueta: 'Completados')),
            const SizedBox(width: 8),
            Expanded(child: ResumenCard(valor: dinero(r.ingreso), etiqueta: 'Ingreso est.')),
          ]),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: agenda.estilistaId == null,
                onSelected: (_) => agenda.setEstilista(null),
              ),
              for (final e in salon.estilistas) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(e.nombre),
                  selected: agenda.estilistaId == e.id,
                  onSelected: (_) => agenda.setEstilista(e.id),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<EstadoTurno?>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: null, label: Text('Todos')),
                ButtonSegment(value: EstadoTurno.programado, label: Text('Program.')),
                ButtonSegment(value: EstadoTurno.completado, label: Text('Complet.')),
                ButtonSegment(value: EstadoTurno.cancelado, label: Text('Cancel.')),
              ],
              selected: {agenda.estado},
              onSelectionChanged: (s) => agenda.setEstado(s.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaTurno extends StatelessWidget {
  const _TarjetaTurno({required this.turno});
  final Turno turno;

  void _acciones(BuildContext context) {
    final cliente = salon.clientePorId(turno.clienteId)?.nombre ?? '';
    final servicios = salon.serviciosDe(turno.servicioIds).map((s) => s.nombre).join(' + ');
    final estilista = salon.estilistaPorId(turno.estilistaId)?.nombre ?? '';
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('$cliente · ${hhmm(turno.inicio)}'),
              subtitle: Text('$servicios · $estilista'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Marcar como completado'),
              onTap: () {
                Navigator.of(ctx).pop();
                salon.completarTurno(turno.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Theme.of(ctx).colorScheme.error),
              title: const Text('Cancelar turno'),
              onTap: () {
                Navigator.of(ctx).pop();
                confirmarCancelacion(context, turno);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cliente = salon.clientePorId(turno.clienteId)?.nombre ?? 'Cliente';
    final servicios = salon.serviciosDe(turno.servicioIds).map((s) => s.nombre).join(' + ');
    final estilista = salon.estilistaPorId(turno.estilistaId)?.nombre ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/turno/${turno.id}'),
          onLongPress: turno.esProgramado ? () => _acciones(context) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 52,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hhmm(turno.inicio), style: tt.titleMedium),
                      Text(hhmm(salon.finDe(turno)),
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cliente, style: tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(servicios,
                          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.person, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(estilista,
                              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                EstadoChip(turno.estado),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
