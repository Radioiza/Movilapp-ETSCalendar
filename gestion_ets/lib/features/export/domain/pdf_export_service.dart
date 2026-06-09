import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/date_formatter.dart';
import '../../exams/domain/entities/examen.dart';

/// Servicio de **exportación a PDF** del calendario de exámenes
/// seleccionado (requerimiento "Exportación" del Módulo Público).
///
/// Genera un documento con la misma información que la tabla de resultados
/// (Materia, Fecha, Turno, Salón, Profesor evaluador) y delega en
/// `printing` la vista previa / impresión / guardado, que en cada
/// plataforma ofrece además la opción nativa de "Compartir".
abstract final class PdfExportService {
  static Future<void> exportarYCompartir({
    required List<Examen> examenes,
    String titulo = 'Calendario de Exámenes a Título de Suficiencia',
  }) async {
    final pw.Document documento = pw.Document();

    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context contexto) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Text(
              titulo,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Generado el ${DateFormatter.fechaCorta(DateTime.now())} · ${examenes.length} examen(es)',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (pw.Context contexto) => <pw.Widget>[_tabla(examenes)],
        footer: (pw.Context contexto) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Página ${contexto.pageNumber} de ${contexto.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await documento.save(),
      filename: 'calendario_ets.pdf',
    );
  }

  static pw.Widget _tabla(List<Examen> examenes) {
    const List<String> encabezados = <String>[
      'Materia',
      'Fecha',
      'Turno',
      'Salón',
      'Profesor evaluador',
    ];

    return pw.TableHelper.fromTextArray(
      headers: encabezados,
      data: examenes
          .map((Examen examen) => <String>[
                examen.unidadAprendizaje,
                '${DateFormatter.fechaCorta(examen.fecha)}  ${DateFormatter.hora(examen.fecha)}',
                examen.turno.etiqueta,
                examen.salonNombre,
                examen.profesorEvaluador,
              ])
          .toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
    );
  }
}
