import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/loading_view.dart';
import '../features/admin_shell/presentation/screens/admin_panel_screen.dart';
import '../features/auth/domain/entities/usuario.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/exams/presentation/screens/busqueda_screen.dart';

/// Nombres de ruta de la aplicación, centralizados para evitar literales
/// dispersos por las pantallas.
abstract final class RutasApp {
  static const String inicio = '/';
  static const String acceso = '/admin';
  static const String panel = '/admin/panel';
}

/// Generador de rutas con nombre de la aplicación.
///
/// Se usa con `MaterialApp.onGenerateRoute` para mantener centralizada la
/// navegación entre el Módulo Público (búsqueda, raíz) y el Módulo
/// Administrativo (acceso ↔ panel), respetando la Clean Architecture al no
/// acoplar las pantallas entre sí más que por nombres de ruta.
abstract final class AppRouter {
  static Route<dynamic> generarRuta(RouteSettings configuracion) {
    switch (configuracion.name) {
      case RutasApp.acceso:
        return MaterialPageRoute<void>(
          settings: configuracion,
          builder: (_) => const _PuertaAdministrativa(),
        );
      case RutasApp.panel:
        return MaterialPageRoute<void>(
          settings: configuracion,
          builder: (_) => const AdminPanelScreen(),
        );
      case RutasApp.inicio:
      default:
        return MaterialPageRoute<void>(
          settings: configuracion,
          builder: (_) => const BusquedaScreen(),
        );
    }
  }
}

/// "Puerta" del Módulo Administrativo: decide, según haya o no una sesión
/// activa, si mostrar el formulario de acceso o el panel de gestión —
/// evitando así pedir credenciales a quien ya inició sesión previamente
/// (offline-first: la sesión persiste localmente entre arranques).
class _PuertaAdministrativa extends ConsumerWidget {
  const _PuertaAdministrativa();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Usuario?> sesion = ref.watch(sesionAuthProvider);

    return sesion.when(
      loading: () => const Scaffold(body: LoadingView(mensaje: 'Verificando sesión…')),
      error: (Object _, StackTrace __) => const LoginScreen(),
      data: (Usuario? usuario) => usuario == null ? const LoginScreen() : const AdminPanelScreen(),
    );
  }
}
