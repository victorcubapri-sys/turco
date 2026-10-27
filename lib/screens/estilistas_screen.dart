import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/catalogo.dart';
import '../viewmodels/app_state.dart';
import '../widgets/avatar_inicial.dart';

class EstilistasScreen extends StatelessWidget {
  const EstilistasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: ListenableBuilder(
        listenable: salon,
        builder: (context, _) {
          final n = salon.estilistas.length;
          final h = salon.programadosHoy;
          return CustomScrollView(
            key: const PageStorageKey('estilistas_scroll'),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
                  title: Text('Estilistas', style: tt.titleLarge?.copyWith(color: cs.onSurface)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Text(
                    '$n profesionales · $h ${h == 1 ? 'turno programado' : 'turnos programados'} hoy',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.builder(
                  itemCount: n,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TarjetaEstilista(estilista: salon.estilistas[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaEstilista extends StatelessWidget {
  const _TarjetaEstilista({required this.estilista});
  final Estilista estilista;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final categorias = salon
        .serviciosDe(estilista.servicioIds)
        .map((s) => s.categoria)
        .toSet()
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final hoy = salon.turnosHoyDe(estilista.id);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          agenda.irA(salon.ahora);
          agenda.setEstilista(estilista.id);
          context.go('/agenda?estilista=${estilista.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            AvatarInicial(estilista.avatar, radio: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(estilista.nombre, style: tt.titleMedium),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 0, children: [
                  for (final c in categorias)
                    Chip(
                      label: Text(c.etiqueta),
                      labelStyle: tt.labelSmall,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ]),
                const SizedBox(height: 6),
                Text(
                  hoy == 0 ? 'Sin turnos hoy' : '$hoy ${hoy == 1 ? 'turno' : 'turnos'} hoy',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ]),
            ),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ]),
        ),
      ),
    );
  }
}
