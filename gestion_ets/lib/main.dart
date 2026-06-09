import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/domain/notificacion_service.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_MX');
  await inicializarDependencias();
  await sl<NotificacionService>().inicializar();
  await sl<NotificacionService>().solicitarPermisos();

  runApp(const ProviderScope(child: GestionEtsApp()));
}

/// Raíz de la aplicación: ensambla el tema **Material Design 3**, la
/// inyección de dependencias (ya inicializada antes de `runApp`) y el
/// enrutador con nombre que conecta el Módulo Público con el Administrativo.
class GestionEtsApp extends StatelessWidget {
  const GestionEtsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de ETS — ESCOM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      darkTheme: AppTheme.oscuro,
      themeMode: ThemeMode.system,
      initialRoute: RutasApp.inicio,
      onGenerateRoute: AppRouter.generarRuta,
      locale: const Locale('es', 'MX'),
      supportedLocales: const <Locale>[Locale('es', 'MX'), Locale('en', 'US')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
