import 'package:flutter/material.dart';

import '../models/catalogo.dart';
import '../models/enums.dart';
import '../util/formato.dart';
import '../viewmodels/app_state.dart';
import '../widgets/acciones.dart';
import '../widgets/estado_vacio.dart';

class ServiciosScreen extends StatelessWidget {
  const ServiciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Servicios')),
      body: ListenableBuilder(
        listenable: serviciosVm,
        builder: (context, _) {
          final lista = serviciosVm.filtrados;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Toca un servicio para reservar',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: serviciosVm.categoria == null,
                  onSelected: (_) => serviciosVm.setCategoria(null),
                ),
                for (final c in Categoria.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(c.etiqueta),
                    selected: serviciosVm.categoria == c,
                    onSelected: (_) => serviciosVm.setCategoria(c),
                  ),
                ],
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<FiltroPublico>(
                  showSelectedIcon: false,
                  segments: [
                    for (final f in FiltroPublico.values) ButtonSegment(value: f, label: Text(f.etiqueta)),
                  ],
                  selected: {serviciosVm.publico},
                  onSelectionChanged: (s) => serviciosVm.setPublico(s.first),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, cons) {
                if (lista.isEmpty) {
                  return const Center(
                    child: SingleChildScrollView(
                      child: EstadoVacio(
                        icono: Icons.search_off,
                        titulo: 'No hay servicios con esos filtros',
                        mensaje: 'Prueba con otra categoría o público.',
                      ),
                    ),
                  );
                }
                final w = cons.maxWidth;
                final columnas = w < 600 ? 2 : (w <= 840 ? 3 : 4);
                return GridView.builder(
                  key: const PageStorageKey('servicios_grid'),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: lista.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnas,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 236,
                  ),
                  itemBuilder: (context, i) => _TarjetaServicio(servicio: lista[i]),
                );
              }),
            ),
          ]);
        },
      ),
    );
  }
}

class _TarjetaServicio extends StatelessWidget {
  const _TarjetaServicio({required this.servicio});
  final Servicio servicio;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => abrirNuevoTurno(context, servicioId: servicio.id),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.asset(
            'assets/images/${servicio.categoria.name}.png',
            height: 92,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 92,
              color: cs.secondaryContainer,
              child: Icon(Icons.content_cut, color: cs.onSecondaryContainer),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(servicio.nombre, style: tt.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Expanded(
                    child: Text('${servicio.duracionMin} min',
                        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ),
                  Text(dinero(servicio.precio), style: tt.titleMedium?.copyWith(color: cs.primary)),
                ]),
                const Spacer(),
                Text(servicio.publico.etiqueta, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
