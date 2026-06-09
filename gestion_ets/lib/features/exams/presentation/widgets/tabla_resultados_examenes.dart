import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/examen.dart';

/// **Visualización Dinámica**: tabla de resultados que muestra Materia,
/// Fecha, Turno, Salón y Profesor evaluador — tal como lo pide el Módulo
/// Público — con acción rápida para marcar favoritos.
///
/// Se desplaza horizontalmente en pantallas angostas para conservar el
/// formato de tabla sin recortar columnas, conforme a la UX de alto nivel
/// solicitada (Material Design 3).
class TablaResultadosExamenes extends StatelessWidget {
  const TablaResultadosExamenes({
    super.key,
    required this.examenes,
    required this.favoritos,
    required this.onAlternarFavorito,
    required this.onAbrirDetalle,
  });

  final List<Examen> examenes;
  final Set<String> favoritos;
  final ValueChanged<Examen> onAlternarFavorito;
  final ValueChanged<Examen> onAbrirDetalle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.sizeOf(context).width - 32),
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('Materia')),
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Turno')),
            DataColumn(label: Text('Salón')),
            DataColumn(label: Text('Profesor evaluador')),
            DataColumn(label: Text('')),
          ],
          rows: examenes.map((Examen examen) {
            final bool esFavorito = favoritos.contains(examen.id);
            return DataRow(
              onSelectChanged: (_) => onAbrirDetalle(examen),
              cells: <DataCell>[
                DataCell(Text(examen.unidadAprendizaje)),
                DataCell(Text(
                  '${DateFormatter.fechaCorta(examen.fecha)}\n${DateFormatter.hora(examen.fecha)} h',
                )),
                DataCell(Chip(
                  label: Text(examen.turno.etiqueta),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: examen.turno == Turno.matutino
                      ? esquema.primaryContainer
                      : esquema.tertiaryContainer,
                )),
                DataCell(Text(examen.salonNombre)),
                DataCell(Text(examen.profesorEvaluador)),
                DataCell(IconButton(
                  tooltip: esFavorito ? 'Quitar de guardados' : 'Guardar examen',
                  icon: Icon(
                    esFavorito ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: esFavorito ? esquema.primary : null,
                  ),
                  onPressed: () => onAlternarFavorito(examen),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
