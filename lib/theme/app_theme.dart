import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _semilla = Color(0xFF00695C);
  static const _blanco = Color(0xFFFFFFFF);

  static final ColorScheme _esquemaClaro = ColorScheme.fromSeed(
    seedColor: _semilla,
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF006A60),
    onPrimary: _blanco,
    primaryContainer: const Color(0xFF9EF2E4),
    onPrimaryContainer: const Color(0xFF00201C),
    secondaryContainer: const Color(0xFFCCE8E2),
    onSecondaryContainer: const Color(0xFF05201C),
    tertiary: const Color(0xFF456179),
    onTertiary: _blanco,
    tertiaryContainer: const Color(0xFFCDE5FF),
    onTertiaryContainer: const Color(0xFF001D32),
    error: const Color(0xFFBA1A1A),
    onError: _blanco,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: const Color(0xFFF4FBF9),
    onSurface: const Color(0xFF161D1C),
    onSurfaceVariant: const Color(0xFF3F4947),
    surfaceContainer: const Color(0xFFE9EFED),
    outline: const Color(0xFF6F7977),
  );

  static final ColorScheme _esquemaOscuro = ColorScheme.fromSeed(
    seedColor: _semilla,
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF53DBC9),
    onPrimary: const Color(0xFF003731),
    primaryContainer: const Color(0xFF005047),
    onPrimaryContainer: const Color(0xFF74F8E5),
    secondaryContainer: const Color(0xFF314B47),
    onSecondaryContainer: const Color(0xFFCCE8E2),
    tertiary: const Color(0xFFADCAE6),
    onTertiary: const Color(0xFF001D32),
    tertiaryContainer: const Color(0xFF2C4A61),
    onTertiaryContainer: const Color(0xFFCDE5FF),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surface: const Color(0xFF0E1514),
    onSurface: const Color(0xFFDDE4E2),
    onSurfaceVariant: const Color(0xFFBEC9C6),
    surfaceContainer: const Color(0xFF1A2120),
    outline: const Color(0xFF899390),
  );

  static ThemeData get claro => _construir(_esquemaClaro);
  static ThemeData get oscuro => _construir(_esquemaOscuro);

  static ThemeData _construir(ColorScheme cs) {
    final forma12 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: cs.surface,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: forma12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surfaceContainer,
        indicatorColor: cs.secondaryContainer,
      ),
    );
  }
}
