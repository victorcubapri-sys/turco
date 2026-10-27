enum Categoria {
  corte('Corte'),
  color('Color'),
  barba('Barba'),
  peinado('Peinado'),
  tratamiento('Tratamiento');

  const Categoria(this.etiqueta);
  final String etiqueta;
}

enum Publico {
  mujeres('Mujeres'),
  hombres('Hombres'),
  unisex('Unisex');

  const Publico(this.etiqueta);
  final String etiqueta;
}

enum Genero {
  mujer('Mujer'),
  hombre('Hombre');

  const Genero(this.etiqueta);
  final String etiqueta;
}

enum EstadoTurno {
  programado('Programado'),
  completado('Completado'),
  cancelado('Cancelado');

  const EstadoTurno(this.etiqueta);
  final String etiqueta;
}

enum FiltroPublico {
  todos('Todos'),
  mujeres('Mujeres'),
  hombres('Hombres');

  const FiltroPublico(this.etiqueta);
  final String etiqueta;

  bool admite(Publico p) => switch (this) {
        FiltroPublico.todos => true,
        FiltroPublico.mujeres => p != Publico.hombres,
        FiltroPublico.hombres => p != Publico.mujeres,
      };

  static FiltroPublico deGenero(Genero g) =>
      g == Genero.mujer ? FiltroPublico.mujeres : FiltroPublico.hombres;
}
