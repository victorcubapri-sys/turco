 Turco

Agenda de turnos para un salón de belleza. Flutter + Dart, Android, Material 3, MVVM con `ChangeNotifier` + `ListenableBuilder`, navegación con `go_router` (única dependencia externa). Datos en memoria.

- **Application id:** `com.victorarencibiasolano.turco`
- **Nombre visible:** Turco
- **Flutter:** 3.35 o superior (Dart ^3.9)

## Preparar el proyecto (una sola vez)

Este paquete trae el código (`lib/`, `assets/`, `test/`, `pubspec.yaml`). La carpeta `android/` se genera con Flutter:

```bash
./preparar.sh        # Linux / macOS
preparar.bat         # Windows
```

Hace `flutter create . --org com.victorarencibiasolano --project-name turco --platforms=android`, pone el nombre visible "Turco" en el manifiesto y ejecuta `flutter pub get`. No sobrescribe los archivos existentes (`.gitignore`, `pubspec.yaml`, `lib/`).

## Ejecutar

```bash
flutter run
```

## Generar el APK de release

```bash
flutter build apk --release
# build/app/outputs/flutter-apk/app-release.apk
```

## Pruebas

```bash
flutter test
```

## Estructura

```
lib/
  main.dart · app.dart · router.dart
  theme/        Tema claro/oscuro M3 con Poppins
  models/       Servicio, Estilista, Cliente, Turno y enums
  data/         Datos de prueba relativos a DateTime.now()
  viewmodels/   SalonViewModel (reglas de negocio), Agenda, Clientes, Servicios, Tema
  widgets/      Widgets reutilizables y diálogos/hojas compartidas
  screens/      Agenda, Detalle, Formulario de turno, Clientes, Servicios, Estilistas
assets/fonts    Poppins (Regular, Medium y Bold usado como peso 600)
assets/images   Imagen por categoría de servicio
capturas/       Capturas de pantalla
```

## Notas

- Poppins SemiBold no estaba disponible al armar el proyecto: el peso 600 usa `Poppins-Bold.ttf`. Para el peso exacto, reemplaza el archivo por `Poppins-SemiBold.ttf` y ajusta `pubspec.yaml`.
- Se añadió `flutter_localizations` (SDK de Flutter, no es dependencia externa) para que los selectores de fecha salgan en español.
- Las imágenes de `assets/images` son marcadores de posición; reemplázalas por las del diseño manteniendo los nombres.
