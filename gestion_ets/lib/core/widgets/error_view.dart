import 'package:flutter/material.dart';

import '../error/failures.dart';

/// Vista de error reutilizable: traduce un [Failure] en un mensaje amigable
/// con opción de reintentar. Se usa como contenido de pantallas completas
/// cuando un [AsyncValue] cae en estado `error`.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.mensaje, this.onReintentar});

  ErrorView.deFailure(Failure failure, {super.key, this.onReintentar})
      : mensaje = failure.message;

  final String mensaje;
  final VoidCallback? onReintentar;

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline_rounded, size: 48, color: esquema.error),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onReintentar != null) ...<Widget>[
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Muestra un [SnackBar] informativo a partir de un [Failure]. Es la forma
/// estándar de notificar errores de red (timeout, 404, 500) sin bloquear
/// la pantalla, según lo solicitado en los requerimientos técnicos.
void mostrarErrorEnSnackbar(BuildContext context, Failure failure) {
  final ColorScheme esquema = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(failure.message),
        backgroundColor: esquema.errorContainer,
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: esquema.onErrorContainer,
          onPressed: () {},
        ),
      ),
    );
}
