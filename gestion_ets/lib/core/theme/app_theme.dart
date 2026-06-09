import 'package:flutter/material.dart';

/// Tema de la aplicación basado en **Material Design 3**.
///
/// Se genera a partir de un único color semilla con [ColorScheme.fromSeed]
/// para garantizar combinaciones de color accesibles tanto en modo claro
/// como oscuro, tal como lo exige la UX de alto nivel solicitada en el
/// proyecto.
abstract final class AppTheme {
  static const Color _colorSemilla = Color(0xFF6750A4);

  static ThemeData get claro => _construir(Brightness.light);

  static ThemeData get oscuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    final ColorScheme esquema = ColorScheme.fromSeed(
      seedColor: _colorSemilla,
      brightness: brillo,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brillo,
      colorScheme: esquema,
      scaffoldBackgroundColor: esquema.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: esquema.surfaceContainer,
        indicatorColor: esquema.secondaryContainer,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: esquema.surfaceContainerHigh,
        selectedColor: esquema.secondaryContainer,
        labelStyle: TextStyle(color: esquema.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor:
            WidgetStatePropertyAll<Color>(esquema.surfaceContainerHigh),
        dataRowMinHeight: 52,
        dataRowMaxHeight: 64,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
