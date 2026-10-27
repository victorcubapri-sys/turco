import 'package:flutter/material.dart';

class AvatarInicial extends StatelessWidget {
  const AvatarInicial(this.texto, {super.key, this.radio = 20});
  final String texto;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inicial = texto.isEmpty ? '?' : texto.substring(0, texto.length >= 2 && texto == texto.toUpperCase() ? 2 : 1).toUpperCase();
    return CircleAvatar(
      radius: radio,
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      child: Text(inicial, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onPrimaryContainer)),
    );
  }
}
