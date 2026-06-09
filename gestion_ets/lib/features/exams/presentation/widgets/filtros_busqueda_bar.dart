import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../catalogs/domain/entities/carrera.dart';
import '../../domain/repositories/examen_repository.dart';

/// Barra de filtros del **Buscador Inteligente**: Carrera, Semestre y
/// Unidad de Aprendizaje (Materia), tal como lo exige el Módulo Público.
///
/// Es un widget de presentación puro — recibe el estado actual y notifica
/// los cambios — para que toda la lógica viva en `FiltrosBusqueda`
/// (Riverpod), sin `setState` de por medio.
class FiltrosBusquedaBar extends StatelessWidget {
  const FiltrosBusquedaBar({
    super.key,
    required this.filtros,
    required this.carreras,
    required this.onCarreraCambiada,
    required this.onSemestreCambiado,
    required this.onUnidadCambiada,
    required this.onLimpiar,
  });

  final FiltrosExamen filtros;
  final List<Carrera> carreras;
  final ValueChanged<String?> onCarreraCambiada;
  final ValueChanged<int?> onSemestreCambiado;
  final ValueChanged<String> onUnidadCambiada;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.tune_rounded, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Buscador inteligente', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (!filtros.estaVacio)
                  TextButton.icon(
                    onPressed: onLimpiar,
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                    label: const Text('Limpiar'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Unidad de Aprendizaje (Materia)',
                prefixIcon: Icon(Icons.menu_book_rounded),
              ),
              onChanged: onUnidadCambiada,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints restricciones) {
                final bool angosto = restricciones.maxWidth < 480;
                final List<Widget> selectores = <Widget>[
                  _selectorCarrera(context),
                  _selectorSemestre(context),
                ];
                return angosto
                    ? Column(
                        children: <Widget>[
                          selectores[0],
                          const SizedBox(height: 12),
                          selectores[1],
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          Expanded(child: selectores[0]),
                          const SizedBox(width: 12),
                          Expanded(child: selectores[1]),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectorCarrera(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: filtros.carreraId,
      isExpanded: true,
      menuMaxHeight: 360,
      decoration: const InputDecoration(
        labelText: 'Carrera',
        prefixIcon: Icon(Icons.school_rounded),
      ),
      items: <DropdownMenuItem<String?>>[
        const DropdownMenuItem<String?>(value: null, child: Text('Todas las carreras')),
        ...carreras.map(
          (Carrera carrera) => DropdownMenuItem<String?>(
            value: carrera.id,
            child: Text('${carrera.clave} — ${carrera.nombre}', overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onCarreraCambiada,
    );
  }

  Widget _selectorSemestre(BuildContext context) {
    return DropdownButtonFormField<int?>(
      initialValue: filtros.semestre,
      isExpanded: true,
      menuMaxHeight: 360,
      decoration: const InputDecoration(
        labelText: 'Semestre',
        prefixIcon: Icon(Icons.format_list_numbered_rounded),
      ),
      items: <DropdownMenuItem<int?>>[
        const DropdownMenuItem<int?>(value: null, child: Text('Todos los semestres')),
        ...AppConstants.semestres.map(
          (int semestre) => DropdownMenuItem<int?>(value: semestre, child: Text('$semestre.º semestre')),
        ),
      ],
      onChanged: onSemestreCambiado,
    );
  }
}
