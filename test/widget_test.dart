import 'package:flutter_test/flutter_test.dart';
import 'package:turco/app.dart';
import 'package:turco/viewmodels/app_state.dart';

void main() {
  testWidgets('La app arranca en la agenda', (tester) async {
    iniciarEstado();
    await tester.pumpWidget(const TurcoApp());
    await tester.pumpAndSettle();
    expect(find.text('Turco'), findsWidgets);
    expect(find.text('Nuevo turno'), findsOneWidget);
  });

  test('Reglas: sin solapes entre turnos programados', () {
    iniciarEstado();
    final prog = salon.turnos.where((t) => t.esProgramado).toList();
    for (final a in prog) {
      for (final b in prog) {
        if (a.id == b.id) continue;
        final mismo = a.estilistaId == b.estilistaId || a.clienteId == b.clienteId;
        final choca = a.inicio.isBefore(salon.finDe(b)) && b.inicio.isBefore(salon.finDe(a));
        expect(mismo && choca, isFalse);
      }
    }
  });
}
