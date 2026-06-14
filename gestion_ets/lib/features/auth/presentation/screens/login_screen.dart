import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/marca_ipn.dart';
import '../../domain/entities/usuario.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';

/// **Autenticación**: login seguro del Módulo Administrativo. Las
/// contraseñas nunca viajan ni se comparan en texto plano — la validación
/// recae en `SesionAuth` → `LoginUseCase` → `AuthRepository`
/// (contraseñas encriptadas con SHA-256 + sal, ver `PasswordHasher`).
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Usuario?> sesion = ref.watch(sesionAuthProvider);

    ref.listen<AsyncValue<Usuario?>>(sesionAuthProvider, (
      AsyncValue<Usuario?>? anterior,
      AsyncValue<Usuario?> actual,
    ) {
      if (actual.hasValue && actual.value != null) {
        Navigator.of(context).pushReplacementNamed('/admin/panel');
      }
      final Object? error = actual.error;
      if (error != null && error is Failure && actual.isLoading == false) {
        mostrarErrorEnSnackbar(context, error);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Acceso administrativo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 16),
                const EncabezadoMarca(
                  titulo: 'Gestión de ETS',
                  subtitulo: 'Inicia sesión para administrar los exámenes y los catálogos.',
                ),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: LoginForm(
                      cargando: sesion.isLoading,
                      onEnviar: (String usuario, String contrasena) {
                        ref.read(sesionAuthProvider.notifier).iniciarSesion(
                              nombreUsuario: usuario,
                              contrasena: contrasena,
                            );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
