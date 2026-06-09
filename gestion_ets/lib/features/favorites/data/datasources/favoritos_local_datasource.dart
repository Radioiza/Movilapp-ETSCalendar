import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';

/// Caché local de **exámenes favoritos/guardados** respaldada por
/// `shared_preferences`, tal como lo pide el requerimiento de persistencia
/// del proyecto. Solo guarda identificadores: el detalle se obtiene del
/// repositorio de exámenes (que ya mantiene su propia caché offline-first).
class FavoritosLocalDataSource {
  const FavoritosLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _llaveFavoritos = 'examenes_favoritos';

  Future<Set<String>> obtenerIds() async {
    try {
      return _prefs.getStringList(_llaveFavoritos)?.toSet() ?? <String>{};
    } on Exception {
      throw const CacheException('No fue posible leer tus exámenes guardados');
    }
  }

  Future<void> guardarIds(Set<String> ids) async {
    try {
      await _prefs.setStringList(_llaveFavoritos, ids.toList(growable: false));
    } on Exception {
      throw const CacheException('No fue posible guardar tus exámenes favoritos');
    }
  }
}
