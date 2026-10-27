import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../models/turno.dart';
import '../router.dart';
import '../util/formato.dart';
import '../viewmodels/app_state.dart';
import '../viewmodels/salon_viewmodel.dart';
import '../widgets/cliente_sheet.dart';
import '../widgets/turno_no_encontrado.dart';

class TurnoFormScreen extends StatefulWidget {
  const TurnoFormScreen({super.key, this.turnoId, this.extra});
  final String? turnoId;
  final TurnoNuevoExtra? extra;

  @override
  State<TurnoFormScreen> createState() => _TurnoFormScreenState();
}

class _TurnoFormScreenState extends State<TurnoFormScreen> {
  final _form = GlobalKey<FormState>();
  final _notas = TextEditingController();
  final _fnCliente = FocusNode();
  final _fnServicios = FocusNode();
  final _fnEstilista = FocusNode();
  final _fnFecha = FocusNode();
  final _fnHora = FocusNode();
  FocusNode? _primerError;

  Turno? _original;
  String? _clienteId;
  FiltroPublico _filtro = FiltroPublico.todos;
  final Set<String> _servicios = {};
  String? _estilistaId;
  DateTime? _fecha;
  int? _hora;
  bool _dirty = false;
  bool _permitirSalir = false;

  bool get _editando => widget.turnoId != null;

  @override
  void initState() {
    super.initState();
    final id = widget.turnoId;
    if (id != null) {
      final t = salon.turnoPorId(id);
      if (t != null && t.esProgramado) {
        _original = t;
        _clienteId = t.clienteId;
        _servicios.addAll(t.servicioIds);
        _estilistaId = t.estilistaId;
        _fecha = soloFecha(t.inicio);
        _hora = t.inicio.hour * 60 + t.inicio.minute;
        _notas.text = t.notas ?? '';
      }
    } else {
      final x = widget.extra;
      _clienteId = x?.clienteId;
      final sid = x?.servicioId;
      if (sid != null && salon.servicioPorId(sid) != null) _servicios.add(sid);
      final f = x?.fecha;
      if (f != null && salon.fechaValida(f)) _fecha = soloFecha(f);
    }
    final c = _clienteId == null ? null : salon.clientePorId(_clienteId!);
    if (c != null) _filtro = FiltroPublico.deGenero(c.genero);
  }

  @override
  void dispose() {
    _notas.dispose();
    for (final f in [_fnCliente, _fnServicios, _fnEstilista, _fnFecha, _fnHora]) {
      f.dispose();
    }
    super.dispose();
  }

  // ---- estado ----
  void _mut(VoidCallback f) => setState(() {
        f();
        _dirty = true;
      });

  String? _reg(FocusNode f, String? error) {
    if (error != null) _primerError ??= f;
    return error;
  }

  String? _motivo(int minuto) {
    final f = _fecha;
    final e = _estilistaId;
    if (f == null || e == null || _servicios.isEmpty) return 'Faltan datos';
    return salon.motivoNoDisponible(
      fecha: f,
      minutoInicio: minuto,
      servicioIds: _servicios.toList(),
      estilistaId: e,
      clienteId: _clienteId,
      excluirTurnoId: widget.turnoId,
    );
  }

  void _revalidarHora() {
    if (_hora != null && _motivo(_hora!) != null) _hora = null;
  }

  void _alCambiarServicios() {
    if (_estilistaId != null && !salon.estilistasPara(_servicios).any((e) => e.id == _estilistaId)) {
      _estilistaId = null;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('El estilista elegido ya no realiza todos los servicios. Selecciona otro.'),
        ));
    }
    _revalidarHora();
  }

  Future<void> _elegirFecha(VoidCallback cambio) async {
    final hoy = soloFecha(salon.ahora);
    final r = await showDatePicker(
      context: context,
      initialDate: salon.proximaFechaValida(_fecha),
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      selectableDayPredicate: salon.esLaborable,
      helpText: 'Elegir fecha',
    );
    if (r != null) {
      _mut(() {
        _fecha = soloFecha(r);
        _revalidarHora();
      });
      cambio();
    }
  }

  // ---- salida ----
  Future<bool> _confirmarDescarte() async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Descartar los cambios?'),
        content: const Text('Tienes cambios sin guardar en este turno. Si sales ahora se perderán.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Seguir editando')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Descartar')),
        ],
      ),
    );
    return r == true;
  }

  void _salir(Turno? resultado) {
    setState(() => _permitirSalir = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop(resultado);
    });
  }

  Future<void> _intentarSalir() async {
    if (!_dirty) {
      _salir(null);
      return;
    }
    if (await _confirmarDescarte() && mounted) _salir(null);
  }

  void _guardar() {
    _primerError = null;
    if (!_form.currentState!.validate()) {
      final f = _primerError;
      if (f != null) {
        f.requestFocus();
        final ctx = f.context;
        if (ctx != null) {
          Scrollable.ensureVisible(ctx, alignment: 0.1, duration: const Duration(milliseconds: 250));
        }
      }
      return;
    }
    try {
      final notas = _notas.text;
      final Turno t = _editando
          ? salon.editarTurno(widget.turnoId!,
              estilistaId: _estilistaId!,
              servicioIds: _servicios.toList(),
              fecha: _fecha!,
              minutoInicio: _hora!,
              notas: notas)
          : salon.crearTurno(
              clienteId: _clienteId!,
              estilistaId: _estilistaId!,
              servicioIds: _servicios.toList(),
              fecha: _fecha!,
              minutoInicio: _hora!,
              notas: notas);
      _salir(t);
    } on ReglaNegocioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
      setState(_revalidarHora);
    }
  }

  // ---- UI ----
  Widget _campo({
    required FocusNode fn,
    required String? Function() validar,
    required Widget Function(VoidCallback cambio, String? error) contenido,
  }) {
    return FormField<int>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) => _reg(fn, validar()),
      builder: (st) => Focus(
        focusNode: fn,
        child: contenido(() => st.didChange(DateTime.now().microsecondsSinceEpoch), st.errorText),
      ),
    );
  }

  Widget _error(String? e) {
    if (e == null) return const SizedBox.shrink();
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(e, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.error)),
    );
  }

  Widget _titulo(String s) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(s, style: Theme.of(context).textTheme.titleMedium),
      );

  @override
  Widget build(BuildContext context) {
    if (_editando && _original == null) return const TurnoNoEncontrado(titulo: 'Editar turno');
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final tecladoAbierto = MediaQuery.viewInsetsOf(context).bottom > 0;
    final clientes = [...salon.clientes]..sort((a, b) => normaliza(a.nombre).compareTo(normaliza(b.nombre)));
    final opcionesEstilista = salon.estilistasPara(_servicios);

    return PopScope(
      canPop: !_dirty || _permitirSalir,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmarDescarte() && mounted) _salir(null);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _intentarSalir),
          title: Text(_editando ? 'Editar turno' : 'Nuevo turno'),
        ),
        body: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Form(
                key: _form,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey('cliente-$_clienteId'),
                    focusNode: _fnCliente,
                    isExpanded: true,
                    initialValue: _clienteId,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(labelText: 'Cliente', prefixIcon: Icon(Icons.person)),
                    items: [
                      for (final c in clientes)
                        DropdownMenuItem(value: c.id, child: Text(c.nombre, overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: _editando
                        ? null
                        : (v) => _mut(() {
                              _clienteId = v;
                              final c = v == null ? null : salon.clientePorId(v);
                              if (c != null) _filtro = FiltroPublico.deGenero(c.genero);
                              _revalidarHora();
                            }),
                    validator: (v) => _reg(_fnCliente, v == null ? 'Selecciona un cliente' : null),
                  ),
                  if (!_editando)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text('Crear cliente nuevo'),
                        onPressed: () async {
                          final c = await mostrarFormularioCliente(context);
                          if (c != null && mounted) {
                            _mut(() {
                              _clienteId = c.id;
                              _filtro = FiltroPublico.deGenero(c.genero);
                              _revalidarHora();
                            });
                          }
                        },
                      ),
                    ),
                  _titulo('Servicios para'),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<FiltroPublico>(
                      showSelectedIcon: false,
                      segments: [
                        for (final f in FiltroPublico.values) ButtonSegment(value: f, label: Text(f.etiqueta)),
                      ],
                      selected: {_filtro},
                      onSelectionChanged: (s) => setState(() => _filtro = s.first),
                    ),
                  ),
                  _titulo('Servicios'),
                  _campo(
                    fn: _fnServicios,
                    validar: () => _servicios.isEmpty ? 'Elige al menos un servicio' : null,
                    contenido: (cambio, error) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      for (final cat in Categoria.values) ...[
                        ..._chipsCategoria(cat, cambio),
                      ],
                      _error(error),
                    ]),
                  ),
                  _titulo('Estilista'),
                  DropdownButtonFormField<String>(
                    key: ValueKey('est-$_estilistaId-${opcionesEstilista.map((e) => e.id).join()}'),
                    focusNode: _fnEstilista,
                    isExpanded: true,
                    initialValue: _estilistaId,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    hint: _servicios.isEmpty ? const Text('Primero elige los servicios') : const Text('Selecciona un estilista'),
                    decoration: const InputDecoration(
                      labelText: 'Estilista',
                      prefixIcon: Icon(Icons.person),
                      helperText: 'Solo se muestran estilistas que realizan todos los servicios elegidos.',
                      helperMaxLines: 2,
                    ),
                    items: [
                      for (final e in opcionesEstilista)
                        DropdownMenuItem(value: e.id, child: Text(e.nombre, overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: opcionesEstilista.isEmpty
                        ? null
                        : (v) => _mut(() {
                              _estilistaId = v;
                              _revalidarHora();
                            }),
                    validator: (v) => _reg(_fnEstilista, v == null ? 'Selecciona un estilista' : null),
                  ),
                  _titulo('Fecha'),
                  _campo(
                    fn: _fnFecha,
                    validar: () {
                      final f = _fecha;
                      if (f == null) return 'Selecciona una fecha';
                      return salon.fechaValida(f) ? null : 'Elige una fecha válida (no domingos)';
                    },
                    contenido: (cambio, error) => InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _elegirFecha(cambio),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          prefixIcon: const Icon(Icons.calendar_month),
                          errorText: error,
                        ),
                        child: Text(_fecha == null ? 'Selecciona una fecha' : fechaLarga(_fecha!)),
                      ),
                    ),
                  ),
                  _titulo('Hora de inicio'),
                  _campo(
                    fn: _fnHora,
                    validar: () => _hora == null ? 'Elige una hora para el turno' : null,
                    contenido: _seccionHora,
                  ),
                  _titulo('Notas (opcional)'),
                  TextFormField(
                    controller: _notas,
                    maxLength: 500,
                    minLines: 3,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(alignLabelWithHint: true, hintText: 'Preferencias, indicaciones...'),
                    onChanged: (_) {
                      if (!_dirty) setState(() => _dirty = true);
                    },
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) =>
                        Text('$currentLength / $maxLength', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ),
                ]),
              ),
            ),
          ),
          if (!tecladoAbierto) _resumen(),
        ]),
      ),
    );
  }

  List<Widget> _chipsCategoria(Categoria cat, VoidCallback cambio) {
    final lista = salon.servicios
        .where((s) => s.categoria == cat && (_filtro.admite(s.publico) || _servicios.contains(s.id)))
        .toList();
    if (lista.isEmpty) return [];
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(cat.etiqueta.toUpperCase(), style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ),
      Wrap(spacing: 8, runSpacing: 4, children: [
        for (final s in lista)
          FilterChip(
            label: Text('${s.nombre} · ${dinero(s.precio)}'),
            selected: _servicios.contains(s.id),
            onSelected: (v) {
              _mut(() {
                v ? _servicios.add(s.id) : _servicios.remove(s.id);
                _alCambiarServicios();
              });
              cambio();
            },
          ),
      ]),
    ];
  }

  Widget _leyenda(String texto, Color fondo, Color borde) {
    final cs = Theme.of(context).colorScheme;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borde),
        ),
      ),
      const SizedBox(width: 6),
      Text(texto, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
    ]);
  }

  Widget _seccionHora(VoidCallback cambio, String? error) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final f = _fecha;
    final listo = f != null && _estilistaId != null && _servicios.isNotEmpty && salon.fechaValida(f);
    final libres = listo ? SalonViewModel.franjas.where((m) => _motivo(m) == null).length : 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 16, runSpacing: 4, children: [
        _leyenda('Libre', cs.surface, cs.outline),
        _leyenda('No disponible', cs.surfaceContainer, cs.surfaceContainer),
        _leyenda('Elegida', cs.primaryContainer, cs.primary),
      ]),
      const SizedBox(height: 10),
      if (!listo)
        Text('Elige servicios, estilista y fecha para ver los horarios.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))
      else ...[
        if (libres == 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('No hay horarios libres para este día. Prueba con otra fecha o estilista.',
                style: tt.bodyMedium?.copyWith(color: cs.error)),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: SalonViewModel.franjas.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 40,
          ),
          itemBuilder: (context, i) {
            final m = SalonViewModel.franjas[i];
            final libre = _motivo(m) == null;
            final sel = _hora == m;
            final fondo = sel ? cs.primaryContainer : (libre ? cs.surface : cs.surfaceContainer);
            final borde = sel ? cs.primary : (libre ? cs.outline : cs.surfaceContainer);
            final texto = sel
                ? cs.onPrimaryContainer
                : (libre ? cs.onSurface : cs.onSurface.withValues(alpha: 0.38));
            return Material(
              color: fondo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: borde),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: libre
                    ? () {
                        _mut(() => _hora = m);
                        cambio();
                      }
                    : null,
                child: Center(
                  child: Text(
                    minutosAHora(m),
                    style: tt.bodyMedium?.copyWith(
                      color: texto,
                      decoration: libre || sel ? null : TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
      _error(error),
    ]);
  }

  Widget _resumen() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dur = salon.duracionMin(_servicios);
    final fin = (_hora != null && dur > 0) ? minutosAHora(_hora! + dur) : '--:--';
    Widget dato(IconData i, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 18, color: cs.primary),
          const SizedBox(width: 6),
          Text(t, style: tt.titleMedium),
        ]);
    return Material(
      color: cs.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 4,
              children: [
                dato(Icons.schedule, duracionTxt(dur)),
                dato(Icons.flag, 'Fin $fin'),
                dato(Icons.payments, dinero(salon.totalPrecio(_servicios))),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: _intentarSalir, child: const Text('Cancelar'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: _guardar, child: const Text('Guardar turno'))),
            ]),
          ]),
        ),
      ),
    );
  }
}
