import 'package:flutter/material.dart';

/// Tema de la aplicación basado en **Material Design 3** con la identidad
/// visual del **IPN / ESCOM**: guinda institucional sobre fondos blancos, con
/// un acento dorado para los realces.
///
/// Se construye sobre un [ColorScheme.fromSeed] (para garantizar combinaciones
/// accesibles en claro y oscuro) pero fija el guinda exacto como color
/// primario, de modo que la marca se respete con fidelidad.
abstract final class AppTheme {
  /// Guinda institucional del IPN.
  static const Color guinda = Color(0xFF691B31);
  static const Color guindaClaro = Color(0xFF8E2A46);
  static const Color guindaOscuro = Color(0xFF45101F);

  /// Acento dorado para realces sutiles (íconos, indicadores).
  static const Color dorado = Color(0xFFC9A227);

  /// Degradado guinda usado en encabezados y el emblema institucional.
  static const LinearGradient gradienteGuinda = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[guindaClaro, guindaOscuro],
  );

  static ThemeData get claro => _construir(Brightness.light);

  static ThemeData get oscuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    final bool esClaro = brillo == Brightness.light;

    final ColorScheme base = ColorScheme.fromSeed(
      seedColor: guinda,
      brightness: brillo,
    );
    final ColorScheme esquema = base.copyWith(
      primary: esClaro ? guinda : const Color(0xFFFFB2C0),
      onPrimary: esClaro ? Colors.white : guindaOscuro,
      tertiary: dorado,
    );

    final Color fondo = esClaro ? const Color(0xFFFBF5F6) : esquema.surface;

    return ThemeData(
      useMaterial3: true,
      brightness: brillo,
      colorScheme: esquema,
      scaffoldBackgroundColor: fondo,
      appBarTheme: AppBarTheme(
        backgroundColor: esClaro ? guinda : esquema.surfaceContainer,
        foregroundColor: esClaro ? Colors.white : esquema.onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: esClaro ? Colors.white : esquema.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: esClaro ? Colors.white : esquema.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: esClaro ? const Color(0x14691B31) : esquema.outlineVariant,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: esClaro ? guinda : esquema.primaryContainer,
        foregroundColor: esClaro ? Colors.white : esquema.onPrimaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esClaro
            ? guinda.withValues(alpha: 0.04)
            : esquema.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: esquema.outlineVariant.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: esquema.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: esClaro ? Colors.white : esquema.surfaceContainer,
        indicatorColor: esquema.primary.withValues(alpha: esClaro ? 0.14 : 0.30),
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> estados) => TextStyle(
            fontSize: 12,
            fontWeight: estados.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: estados.contains(WidgetState.selected)
                ? esquema.primary
                : esquema.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> estados) => IconThemeData(
            color: estados.contains(WidgetState.selected)
                ? esquema.primary
                : esquema.onSurfaceVariant,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: esquema.surfaceContainerHigh,
        selectedColor: esquema.secondaryContainer,
        labelStyle: TextStyle(color: esquema.onSurface, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor:
            WidgetStatePropertyAll<Color>(esquema.surfaceContainerHigh),
        dataRowMinHeight: 52,
        dataRowMaxHeight: 64,
      ),
      dividerTheme: DividerThemeData(
        color: esquema.outlineVariant.withValues(alpha: 0.5),
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
