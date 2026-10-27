import '../data/datos_prueba.dart';
import 'agenda_viewmodel.dart';
import 'clientes_viewmodel.dart';
import 'salon_viewmodel.dart';
import 'servicios_viewmodel.dart';
import 'theme_viewmodel.dart';

late SalonViewModel salon;
late AgendaViewModel agenda;
late ClientesViewModel clientesVm;
late ServiciosViewModel serviciosVm;
late ThemeViewModel temaVm;

void iniciarEstado() {
  final d = DatosPrueba.crear(DateTime.now());
  salon = SalonViewModel(
    servicios: d.servicios,
    estilistas: d.estilistas,
    clientes: d.clientes,
    turnos: d.turnos,
  );
  agenda = AgendaViewModel(salon);
  clientesVm = ClientesViewModel(salon);
  serviciosVm = ServiciosViewModel(salon);
  temaVm = ThemeViewModel();
}
