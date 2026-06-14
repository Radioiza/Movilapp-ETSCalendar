import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';

/// Calendario mensual **Material 3** construido a mano (sin dependencias
/// externas) para mostrar y seleccionar días dentro del calendario in-app.
///
/// Es un widget de presentación puro: no conoce los modelos de datos. El padre
/// le indica el mes enfocado, el día seleccionado y cuántos eventos tiene cada
/// día (para pintar el indicador), y reacciona a la selección de día y al
/// cambio de mes mediante callbacks.
class CalendarioMensual extends StatelessWidget {
  const CalendarioMensual({
    super.key,
    required this.mesEnfocado,
    required this.diaSeleccionado,
    required this.conteoPorDia,
    required this.onDiaSeleccionado,
    required this.onCambiarMes,
    this.mesMinimo,
    this.mesMaximo,
  });

  /// Cualquier fecha dentro del mes que se está mostrando.
  final DateTime mesEnfocado;
  final DateTime diaSeleccionado;

  /// Número de eventos por día (clave normalizada a medianoche).
  final Map<DateTime, int> conteoPorDia;

  final ValueChanged<DateTime> onDiaSeleccionado;

  /// Avanza (`+1`) o retrocede (`-1`) un mes.
  final ValueChanged<int> onCambiarMes;

  /// Límites de navegación (primer/último mes con ETS). Si son `null`, no se
  /// restringe el avance/retroceso.
  final DateTime? mesMinimo;
  final DateTime? mesMaximo;

  static const List<String> _diasSemana = <String>['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  static int _indiceMes(DateTime mes) => mes.year * 12 + mes.month;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
        child: Column(
          children: <Widget>[
            _encabezado(context),
            _filaDiasSemana(context),
            const SizedBox(height: 4),
            _cuadricula(context),
          ],
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    final bool puedeRetroceder =
        mesMinimo == null || _indiceMes(mesEnfocado) > _indiceMes(mesMinimo!);
    final bool puedeAvanzar =
        mesMaximo == null || _indiceMes(mesEnfocado) < _indiceMes(mesMaximo!);

    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Mes anterior',
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: puedeRetroceder ? () => onCambiarMes(-1) : null,
        ),
        Expanded(
          child: Center(
            child: Text(
              DateFormatter.mesAnio(mesEnfocado),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Mes siguiente',
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: puedeAvanzar ? () => onCambiarMes(1) : null,
        ),
      ],
    );
  }

  Widget _filaDiasSemana(BuildContext context) {
    final TextStyle? estilo = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Row(
      children: _diasSemana
          .map((String etiqueta) => Expanded(
                child: Center(child: Text(etiqueta, style: estilo)),
              ))
          .toList(),
    );
  }

  Widget _cuadricula(BuildContext context) {
    final DateTime primerDia = DateTime(mesEnfocado.year, mesEnfocado.month);
    // Desplazamiento para que la semana empiece en lunes (weekday: lun=1).
    final int desplazamiento = primerDia.weekday - 1;
    final int diasEnMes = DateTime(mesEnfocado.year, mesEnfocado.month + 1, 0).day;
    final int totalCeldas = desplazamiento + diasEnMes;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: totalCeldas,
      itemBuilder: (BuildContext context, int indice) {
        if (indice < desplazamiento) {
          return const SizedBox.shrink();
        }
        final int dia = indice - desplazamiento + 1;
        final DateTime fecha = DateTime(mesEnfocado.year, mesEnfocado.month, dia);
        return _celdaDia(context, fecha);
      },
    );
  }

  Widget _celdaDia(BuildContext context, DateTime fecha) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final bool esHoy = _mismoDia(fecha, DateTime.now());
    final bool esSeleccionado = _mismoDia(fecha, diaSeleccionado);
    final int conteo = conteoPorDia[_normalizar(fecha)] ?? 0;

    final Color colorNumero = esSeleccionado
        ? esquema.onPrimary
        : esHoy
            ? esquema.primary
            : esquema.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () => onDiaSeleccionado(fecha),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: esSeleccionado ? esquema.primary : Colors.transparent,
                border: esHoy && !esSeleccionado
                    ? Border.all(color: esquema.primary)
                    : null,
              ),
              child: Text(
                '${fecha.day}',
                style: TextStyle(
                  color: colorNumero,
                  fontWeight: esHoy || esSeleccionado ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 2),
            _indicadorEventos(esquema, conteo, esSeleccionado),
          ],
        ),
      ),
    );
  }

  /// Hasta tres puntos bajo el día para señalar que tiene eventos.
  Widget _indicadorEventos(ColorScheme esquema, int conteo, bool esSeleccionado) {
    if (conteo == 0) {
      return const SizedBox(height: 6);
    }
    final Color color = esSeleccionado ? esquema.primary : esquema.tertiary;
    final int puntos = conteo > 3 ? 3 : conteo;
    return SizedBox(
      height: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(
          puntos,
          (_) => Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  static DateTime _normalizar(DateTime fecha) => DateTime(fecha.year, fecha.month, fecha.day);

  static bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
