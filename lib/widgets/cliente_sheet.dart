import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cliente.dart';
import '../models/enums.dart';
import '../viewmodels/app_state.dart';
import '../viewmodels/salon_viewmodel.dart';

/// Hoja de alta/edición de cliente. Devuelve el cliente guardado o null.
Future<Cliente?> mostrarFormularioCliente(BuildContext context, {Cliente? cliente}) {
  return showModalBottomSheet<Cliente>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _FormularioCliente(cliente: cliente),
  );
}

class _FormularioCliente extends StatefulWidget {
  const _FormularioCliente({this.cliente});
  final Cliente? cliente;

  @override
  State<_FormularioCliente> createState() => _FormularioClienteState();
}

class _FormularioClienteState extends State<_FormularioCliente> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.cliente?.nombre);
  late final _telefono = TextEditingController(text: widget.cliente?.telefono);
  late final _correo = TextEditingController(text: widget.cliente?.correo);
  late Genero? _genero = widget.cliente?.genero;
  final _fnNombre = FocusNode();
  final _fnTelefono = FocusNode();
  final _fnGenero = FocusNode();
  final _fnCorreo = FocusNode();
  FocusNode? _primerError;

  @override
  void dispose() {
    for (final c in [_nombre, _telefono, _correo]) {
      c.dispose();
    }
    for (final f in [_fnNombre, _fnTelefono, _fnGenero, _fnCorreo]) {
      f.dispose();
    }
    super.dispose();
  }

  String? _reg(FocusNode f, String? error) {
    if (error != null) _primerError ??= f;
    return error;
  }

  void _guardar() {
    _primerError = null;
    if (!_form.currentState!.validate()) {
      _primerError?.requestFocus();
      return;
    }
    try {
      final existente = widget.cliente;
      final Cliente resultado;
      if (existente == null) {
        resultado = salon.crearCliente(
          nombre: _nombre.text, telefono: _telefono.text, genero: _genero!, correo: _correo.text);
      } else {
        salon.editarCliente(existente.id,
            nombre: _nombre.text, telefono: _telefono.text, genero: _genero!, correo: _correo.text);
        resultado = existente;
      }
      Navigator.of(context).pop(resultado);
    } on ReglaNegocioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Form(
          key: _form,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.cliente == null ? 'Nuevo cliente' : 'Editar cliente', style: tt.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombre,
                focusNode: _fnNombre,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person)),
                validator: (v) => _reg(_fnNombre, salon.validarNombre(v)),
                onFieldSubmitted: (_) => _fnTelefono.requestFocus(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefono,
                focusNode: _fnTelefono,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone)),
                validator: (v) => _reg(_fnTelefono, salon.validarTelefono(v, excluirId: widget.cliente?.id)),
                onFieldSubmitted: (_) => _fnGenero.requestFocus(),
              ),
              const SizedBox(height: 12),
              FormField<Genero>(
                initialValue: _genero,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (_) => _reg(_fnGenero, _genero == null ? 'Selecciona un género' : null),
                builder: (st) => Focus(
                  focusNode: _fnGenero,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Género', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<Genero>(
                        emptySelectionAllowed: true,
                        showSelectedIcon: false,
                        segments: [
                          for (final g in Genero.values) ButtonSegment(value: g, label: Text(g.etiqueta)),
                        ],
                        selected: _genero == null ? <Genero>{} : {_genero!},
                        onSelectionChanged: (s) {
                          setState(() => _genero = s.isEmpty ? null : s.first);
                          st.didChange(_genero);
                        },
                      ),
                    ),
                    if (st.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(st.errorText!, style: tt.bodySmall?.copyWith(color: cs.error)),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correo,
                focusNode: _fnCorreo,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Correo (opcional)', prefixIcon: Icon(Icons.mail)),
                validator: (v) => _reg(_fnCorreo, salon.validarCorreo(v)),
                onFieldSubmitted: (_) => _guardar(),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: _guardar, child: const Text('Guardar cliente'))),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
