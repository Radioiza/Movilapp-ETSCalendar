import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/examen.dart';

/// Lista de exámenes como **tarjetas** Material 3 (Materia, Fecha, Turno,
/// Salón y Profesor evaluador), con una insignia de fecha tipo calendario.
/// Se usa tanto en los resultados de búsqueda como en el día seleccionado de
/// "Mi Calendario". Cada tarjeta abre el detalle del examen.
class ListaResultadosExamenes extends StatelessWidget {
  const ListaResultadosExamenes({
    super.key,
    required this.examenes,
    required this.onAbrirDetalle,
  });

  final List<Examen> examenes;
  final ValueChanged<Examen> onAbrirDetalle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final Examen examen in examenes)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _TarjetaExamen(
              examen: examen,
              onAbrir: () => onAbrirDetalle(examen),
            ),
          ),
      ],
    );
  }
}

class _TarjetaExamen extends StatelessWidget {
  const _TarjetaExamen({required this.examen, required this.onAbrir});

  final Examen examen;
  final VoidCallback onAbrir;

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onAbrir,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InsigniaFecha(fecha: examen.fecha),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      examen.unidadAprendizaje,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _filaIcono(context, Icons.meeting_room_outlined, examen.salonNombre),
                    const SizedBox(height: 4),
                    _filaIcono(context, Icons.person_outline_rounded, examen.profesorEvaluador),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: <Widget>[
                        _pildora(
                          context,
                          Icons.schedule_rounded,
                          '${DateFormatter.hora(examen.fecha)} h',
                          esquema.surfaceContainerHighest,
                          esquema.onSurfaceVariant,
                        ),
                        _pildora(
                          context,
                          Icons.wb_sunny_outlined,
                          examen.turno.etiqueta,
                          examen.turno == Turno.matutino
                              ? esquema.primaryContainer
                              : esquema.tertiaryContainer,
                          examen.turno == Turno.matutino
                              ? esquema.onPrimaryContainer
                              : esquema.onTertiaryContainer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: esquema.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaIcono(BuildContext context, IconData icono, String texto) {
    final Color color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icono, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  Widget _pildora(
    BuildContext context,
    IconData icono,
    String texto,
    Color fondo,
    Color colorTexto,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icono, size: 14, color: colorTexto),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(color: colorTexto, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Insignia de fecha tipo calendario (día grande + mes), con la guinda
/// institucional. Reutilizable en cualquier lista de exámenes.
class InsigniaFecha extends StatelessWidget {
  const InsigniaFecha({super.key, required this.fecha});

  final DateTime fecha;

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: esquema.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${fecha.day}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: esquema.primary,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormatter.mesCorto(fecha),
            style: TextStyle(
              color: esquema.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
