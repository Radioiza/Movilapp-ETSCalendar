import '../entities/examen.dart';
import '../repositories/examen_repository.dart';

/// Caso de uso del **Buscador Inteligente** del módulo público.
///
/// Aplica los filtros (Carrera, Semestre, Unidad de Aprendizaje) a través
/// del repositorio y garantiza que el resultado se presente ordenado
/// cronológicamente — la regla de negocio que la presentación espera y que
/// no debería reimplementarse en cada pantalla.
class BuscarExamenesUseCase {
  const BuscarExamenesUseCase(this._repositorio);

  final ExamenRepository _repositorio;

  Future<List<Examen>> ejecutar(FiltrosExamen filtros) async {
    final List<Examen> resultado = await _repositorio.buscarExamenes(filtros);
    final List<Examen> ordenado = List<Examen>.of(resultado)
      ..sort((Examen a, Examen b) => a.fecha.compareTo(b.fecha));
    return ordenado;
  }
}
