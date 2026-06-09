import 'package:flutter/material.dart';

import '../../domain/estadisticas_dashboard.dart';

/// Barra horizontal proporcional al total — una visualización ligera de
/// "cuántos exámenes hay programados por carrera/turno" sin depender de
/// paquetes de gráficas externos (Material puro, M3).
class BarraEstadistica extends StatelessWidget {
  const BarraEstadistica({super.key, required this.conteo, required this.maximo, required this.color});

  final ConteoPorEtiqueta conteo;
  final int maximo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double proporcion = maximo == 0 ? 0 : conteo.total / maximo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(conteo.etiqueta, overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text('${conteo.total}', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: proporcion.clamp(0.04, 1.0),
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
