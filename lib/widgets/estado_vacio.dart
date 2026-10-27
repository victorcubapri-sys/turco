import 'package:flutter/material.dart';

class EstadoVacio extends StatelessWidget {
  const EstadoVacio({super.key, required this.icono, required this.titulo, this.mensaje, this.accion});
  final IconData icono;
  final String titulo;
  final String? mensaje;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: cs.secondaryContainer, shape: BoxShape.circle),
            child: Icon(icono, size: 44, color: cs.onSecondaryContainer),
          ),
          const SizedBox(height: 16),
          Text(titulo, style: tt.titleMedium, textAlign: TextAlign.center),
          if (mensaje != null) ...[
            const SizedBox(height: 8),
            Text(mensaje!,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
          if (accion != null) ...[const SizedBox(height: 16), accion!],
        ],
      ),
    );
  }
}
