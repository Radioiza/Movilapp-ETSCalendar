import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../catalogs/presentation/screens/catalogos_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../exams/presentation/screens/examenes_admin_screen.dart';

/// Cascarón del **Módulo Administrativo (Gestión)**: agrupa Dashboard,
/// CRUD de exámenes y Catálogos detrás de una barra de navegación inferior
/// Material 3, una vez que el usuario inició sesión.
class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  int _indiceSeleccionado = 0;

  static const List<_Destino> _destinos = <_Destino>[
    _Destino('Panel', Icons.dashboard_outlined, Icons.dashboard_rounded, DashboardScreen()),
    _Destino('Exámenes', Icons.event_note_outlined, Icons.event_note_rounded, ExamenesAdminScreen()),
    _Destino('Catálogos', Icons.folder_open_outlined, Icons.folder_rounded, CatalogosScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final Usuario? usuario = ref.watch(sesionAuthProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(_destinos[_indiceSeleccionado].titulo),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: 'Cuenta',
            icon: const CircleAvatar(child: Icon(Icons.person_rounded, size: 20)),
            onSelected: (String accion) {
              if (accion == 'salir') {
                _confirmarCierreSesion(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  usuario?.nombreCompleto ?? 'Cuenta administrativa',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (usuario != null)
                PopupMenuItem<String>(enabled: false, child: Text(usuario.rol.etiqueta)),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'salir',
                child: ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Cerrar sesión'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _indiceSeleccionado,
        children: _destinos.map((_Destino d) => d.pantalla).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSeleccionado,
        onDestinationSelected: (int indice) => setState(() => _indiceSeleccionado = indice),
        destinations: _destinos
            .map((_Destino d) => NavigationDestination(
                  icon: Icon(d.icono),
                  selectedIcon: Icon(d.iconoSeleccionado),
                  label: d.titulo,
                ))
            .toList(),
      ),
    );
  }

  Future<void> _confirmarCierreSesion(BuildContext context) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext contexto) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que deseas salir del panel administrativo?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar ?? false) {
      await ref.read(sesionAuthProvider.notifier).cerrarSesion();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> ruta) => false);
      }
    }
  }
}

class _Destino {
  const _Destino(this.titulo, this.icono, this.iconoSeleccionado, this.pantalla);

  final String titulo;
  final IconData icono;
  final IconData iconoSeleccionado;
  final Widget pantalla;
}
