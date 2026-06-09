import 'package:flutter/material.dart';

/// Indicador de carga estándar mostrado mientras un [AsyncValue] está en
/// estado `loading`.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.mensaje});

  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          if (mensaje != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(mensaje!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
