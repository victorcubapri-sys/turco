import '../models/catalogo.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/turno.dart';
import '../util/formato.dart';

class DatosIniciales {
  DatosIniciales(this.servicios, this.estilistas, this.clientes, this.turnos);
  final List<Servicio> servicios;
  final List<Estilista> estilistas;
  final List<Cliente> clientes;
  final List<Turno> turnos;
}

class DatosPrueba {
  DatosPrueba._();

  static const _notaEjemplo =
      'Prefiere la máquina en el número 2 a los lados. Llega siempre diez minutos antes y pide agua.';

  static DatosIniciales crear(DateTime ahora) {
    final servicios = <Servicio>[
      const Servicio(id: 'sv1', nombre: 'Corte mujer', categoria: Categoria.corte, duracionMin: 60, precio: 30, publico: Publico.mujeres),
      const Servicio(id: 'sv2', nombre: 'Corte caballero', categoria: Categoria.corte, duracionMin: 45, precio: 25, publico: Publico.hombres),
      const Servicio(id: 'sv3', nombre: 'Corte clásico', categoria: Categoria.corte, duracionMin: 30, precio: 18, publico: Publico.hombres),
      const Servicio(id: 'sv4', nombre: 'Color completo', categoria: Categoria.color, duracionMin: 120, precio: 70, publico: Publico.mujeres),
      const Servicio(id: 'sv5', nombre: 'Retoque de raíz', categoria: Categoria.color, duracionMin: 60, precio: 35, publico: Publico.mujeres),
      const Servicio(id: 'sv6', nombre: 'Barba', categoria: Categoria.barba, duracionMin: 45, precio: 20, publico: Publico.hombres),
      const Servicio(id: 'sv7', nombre: 'Afeitado', categoria: Categoria.barba, duracionMin: 30, precio: 15, publico: Publico.hombres),
      const Servicio(id: 'sv8', nombre: 'Arreglo de barba', categoria: Categoria.barba, duracionMin: 30, precio: 12, publico: Publico.hombres),
      const Servicio(id: 'sv9', nombre: 'Peinado evento', categoria: Categoria.peinado, duracionMin: 60, precio: 40, publico: Publico.unisex),
      const Servicio(id: 'sv10', nombre: 'Hidratación', categoria: Categoria.tratamiento, duracionMin: 45, precio: 28, publico: Publico.unisex),
      const Servicio(id: 'sv11', nombre: 'Keratina', categoria: Categoria.tratamiento, duracionMin: 120, precio: 80, publico: Publico.unisex),
      const Servicio(id: 'sv12', nombre: 'Brushing', categoria: Categoria.peinado, duracionMin: 30, precio: 15, publico: Publico.mujeres),
    ];
    String s(int i) => 'sv$i';

    final estilistas = <Estilista>[
      Estilista(id: 'e1', nombre: 'Marta Salazar', avatar: 'MS', servicioIds: [s(1), s(4), s(5)]),
      Estilista(id: 'e2', nombre: 'Pedro Vega', avatar: 'PV', servicioIds: [s(2), s(3), s(6), s(7), s(8)]),
      Estilista(id: 'e3', nombre: 'Lucía Torres', avatar: 'LT', servicioIds: [s(10), s(11), s(1), s(2), s(3)]),
      Estilista(id: 'e4', nombre: 'Rafael Núñez', avatar: 'RN', servicioIds: [s(6), s(7), s(8), s(2), s(3)]),
      Estilista(id: 'e5', nombre: 'Camila Ortega', avatar: 'CO', servicioIds: [s(9), s(12), s(4), s(5)]),
    ];

    final registro = sumarDias(ahora, -120);
    Cliente c(int n, String nombre, String tel, Genero g, [String? correo]) => Cliente(
          id: 'c$n', nombre: nombre, telefono: tel, genero: g, correo: correo,
          fechaRegistro: sumarDias(registro, n * 3),
        );
    final clientes = <Cliente>[
      c(1, 'Laura Gómez', '52111222', Genero.mujer, 'laura.gomez@correo.com'),
      c(2, 'Carlos Ruiz', '52345678', Genero.hombre, 'carlos.ruiz@correo.com'),
      c(3, 'Ana Martín', '52333444', Genero.mujer),
      c(4, 'Diego Pérez', '52555666', Genero.hombre),
      c(5, 'Sofía Díaz', '52777888', Genero.mujer, 'sofia.diaz@correo.com'),
      c(6, 'Javier Soto', '52999000', Genero.hombre),
      c(7, 'Marta Peña', '52121314', Genero.mujer),
      c(8, 'Andrés Molina', '52151617', Genero.hombre),
      c(9, 'Valeria Cruz', '52181920', Genero.mujer, 'valeria.cruz@correo.com'),
      c(10, 'Tomás Herrera', '52212223', Genero.hombre),
    ];

    final hoy = soloFecha(ahora);
    final base = hoy.weekday == DateTime.sunday ? sumarDias(hoy, 1) : hoy;
    DateTime habil(DateTime d, int paso) {
      var r = sumarDias(d, paso);
      if (r.weekday == DateTime.sunday) r = sumarDias(r, paso);
      return r;
    }

    final p1 = habil(base, -1), p2 = habil(p1, -1), p3 = habil(p2, -1);
    final f1 = habil(base, 1), f2 = habil(f1, 1), f3 = habil(f2, 1);
    final dias = [p3, p2, p1, base, f1, f2, f3];

    final notaLarga = List.filled(4, _notaEjemplo).join(' ');
    var n = 0;
    Turno t(int dia, int cli, int est, List<int> ss, int min,
        {String? notas, EstadoTurno? estado}) {
      final d = dias[dia];
      final inicio = DateTime(d.year, d.month, d.day, min ~/ 60, min % 60);
      final e = estado ??
          (inicio.isBefore(ahora) ? EstadoTurno.completado : EstadoTurno.programado);
      n++;
      final creado = sumarDias(inicio, -3);
      return Turno(
        id: 't$n', clienteId: 'c$cli', estilistaId: 'e$est',
        servicioIds: [for (final i in ss) s(i)], inicio: inicio, notas: notas, estado: e,
        creado: creado,
        modificado: e == EstadoTurno.programado ? creado : inicio,
      );
    }

    const comp = EstadoTurno.completado;
    const canc = EstadoTurno.cancelado;
    final turnos = <Turno>[
      t(0, 1, 1, [1], 9 * 60 + 30, notas: 'Quiere un corte más corto que la vez anterior.', estado: comp),
      t(0, 2, 2, [2, 6], 10 * 60, estado: comp),
      t(1, 3, 5, [9], 15 * 60, notas: 'Peinado para una boda.', estado: comp),
      t(1, 4, 4, [3], 11 * 60, notas: 'Avisó que no podía asistir.', estado: canc),
      t(2, 5, 3, [1, 10, 11], 9 * 60, notas: 'Tiene el cuero cabelludo sensible.', estado: comp),
      t(2, 7, 1, [4], 14 * 60, estado: canc),
      t(3, 2, 2, [2], 10 * 60, notas: _notaEjemplo),
      t(3, 1, 1, [1], 11 * 60 + 30),
      t(3, 3, 3, [10], 12 * 60, notas: 'Primera hidratación.'),
      t(3, 4, 2, [6], 14 * 60),
      t(3, 5, 5, [9], 16 * 60 + 30, notas: 'Trae fotos de referencia.'),
      t(4, 8, 2, [3, 8], 9 * 60, notas: 'Prefiere atención rápida.'),
      t(4, 9, 1, [4], 15 * 60, notas: notaLarga),
      t(5, 10, 4, [2], 10 * 60 + 30),
      t(5, 7, 5, [12], 18 * 60 + 30, notas: 'Última cita del día.'),
      t(6, 1, 3, [11], 14 * 60, notas: 'Keratina: no lavar el cabello 48 h antes.'),
    ];

    return DatosIniciales(servicios, estilistas, clientes, turnos);
  }
}
