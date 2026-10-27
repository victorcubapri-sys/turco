import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cliente.dart';
import '../models/enums.dart';
import '../util/formato.dart';
import '../viewmodels/app_state.dart';
import '../widgets/acciones.dart';
import '../widgets/avatar_inicial.dart';
import '../widgets/cliente_sheet.dart';
import '../widgets/estado_vacio.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  late final _busqueda = TextEditingController(text: clientesVm.consulta);

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _nuevo() async {
    final c = await mostrarFormularioCliente(context);
    if (c != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Cliente ${c.nombre} guardado')));
    }
  }

  Future<void> _eliminar(Cliente c) async {
    final messenger = ScaffoldMessenger.of(context);
    final bloqueo = salon.bloqueoEliminar(c.id);
    if (bloqueo != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(bloqueo),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () {
              final p = salon.programadosDeCliente(c.id);
              if (p.isNotEmpty) agenda.irA(p.last.inicio);
              if (mounted) context.go('/agenda');
            },
          ),
        ));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar a ${c.nombre}?'),
        content: const Text('Se eliminará el cliente junto con su historial de turnos completados y cancelados.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      salon.eliminarCliente(c.id);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Cliente ${c.nombre} eliminado')));
    }
  }

  void _abrirDetalle(Cliente c) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        final historial = salon.turnosDeCliente(c.id);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                AvatarInicial(c.nombre, radio: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.nombre, style: tt.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Row(children: [
                      Icon(Icons.phone, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(telefonoFmt(c.telefono), style: tt.bodyMedium),
                    ]),
                    if (c.correo != null)
                      Row(children: [
                        Icon(Icons.mail, size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(child: Text(c.correo!, style: tt.bodyMedium, overflow: TextOverflow.ellipsis)),
                      ]),
                  ]),
                ),
              ]),
              const Divider(height: 32),
              Text('Historial de turnos · ${historial.length}', style: tt.titleMedium),
              const SizedBox(height: 8),
              if (historial.isEmpty)
                Text('Aún no tiene turnos.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final t in historial)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '${ddMM(t.inicio)} · ${salon.serviciosDe(t.servicioIds).map((s) => s.nombre).join(' + ')} · ${t.estado.etiqueta}',
                            style: tt.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo turno'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    abrirNuevoTurno(context, clienteId: c.id, fecha: agenda.fecha);
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    mostrarFormularioCliente(context, cliente: c);
                  },
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: cs.error),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _eliminar(c);
                  },
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevo,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo cliente'),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([salon, clientesVm]),
        builder: (context, _) {
          final lista = clientesVm.filtrados;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _busqueda,
                onChanged: clientesVm.setConsulta,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o teléfono',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _busqueda.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _busqueda.clear();
                            clientesVm.setConsulta('');
                          },
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<Genero?>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: null, label: Text('Todos')),
                    ButtonSegment(value: Genero.mujer, label: Text('Mujeres')),
                    ButtonSegment(value: Genero.hombre, label: Text('Hombres')),
                  ],
                  selected: {clientesVm.genero},
                  onSelectionChanged: (s) => clientesVm.setGenero(s.first),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(clientesVm.resumen, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ),
            ),
            Expanded(
              child: lista.isEmpty
                  ? const Center(
                      child: SingleChildScrollView(
                        child: EstadoVacio(
                          icono: Icons.search_off,
                          titulo: 'No encontramos clientes',
                          mensaje: 'Prueba con otro nombre o teléfono, o crea un cliente nuevo.',
                        ),
                      ),
                    )
                  : ListView.separated(
                      key: const PageStorageKey('clientes_lista'),
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final c = lista[i];
                        final n = salon.turnosDeCliente(c.id).length;
                        return ListTile(
                          leading: AvatarInicial(c.nombre),
                          title: Text(c.nombre, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${telefonoFmt(c.telefono)} · ${c.genero.etiqueta}'),
                          trailing: Text('$n ${n == 1 ? 'turno' : 'turnos'}',
                              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                          onTap: () => _abrirDetalle(c),
                        );
                      },
                    ),
            ),
          ]);
        },
      ),
    );
  }
}
