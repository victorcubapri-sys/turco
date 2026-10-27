const diasCorto = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const diasLargo = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
const meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
];

String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
String dosDig(int n) => n.toString().padLeft(2, '0');
String hhmm(DateTime d) => '${dosDig(d.hour)}:${dosDig(d.minute)}';
String minutosAHora(int m) => '${dosDig(m ~/ 60)}:${dosDig(m % 60)}';
String fechaLarga(DateTime d) => '${diasLargo[d.weekday - 1]} ${d.day} de ${meses[d.month - 1]} de ${d.year}';
String fechaCorta(DateTime d) => '${diasCorto[d.weekday - 1].toLowerCase()} ${d.day} de ${meses[d.month - 1]}';
String ddMM(DateTime d) => '${dosDig(d.day)}/${dosDig(d.month)}';
String ddMMyyyy(DateTime d) => '${ddMM(d)}/${d.year}';
String mesAnio(DateTime d) => '${cap(meses[d.month - 1])} ${d.year}';
String dinero(num v) => '\$ $v';

String duracionTxt(int min) {
  final h = min ~/ 60, m = min % 60;
  if (h == 0) return '$m min';
  if (m == 0) return '$h h';
  return '$h h $m min';
}

String telefonoFmt(String t) =>
    t.length == 8 ? '${t.substring(0, 2)} ${t.substring(2, 5)} ${t.substring(5)}' : t;

DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime sumarDias(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
bool mismoDia(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String normaliza(String s) {
  const de = 'áàäâéèëêíìïîóòöôúùüûñ';
  const a = 'aaaaeeeeiiiioooouuuun';
  var r = s.toLowerCase();
  for (var i = 0; i < de.length; i++) {
    r = r.replaceAll(de[i], a[i]);
  }
  return r.trim();
}
