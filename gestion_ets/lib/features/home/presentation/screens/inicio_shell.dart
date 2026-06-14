import 'package:flutter/material.dart';

import '../../../agenda/presentation/screens/agenda_screen.dart';
import '../../../exams/presentation/screens/busqueda_screen.dart';

/// Cascarón del **Módulo Público (Consulta)**: agrupa el Buscador Inteligente
/// y el Calendario in-app ("Mi Calendario") tras una barra de navegación
/// inferior Material 3, para que el usuario alterne entre consultar la oferta
/// oficial y gestionar su propia agenda de ETS.
///
/// Cada destino conserva su propio `Scaffold`/`AppBar`; el `IndexedStack`
/// preserva su estado (filtros de búsqueda, mes seleccionado) al cambiar de
/// pestaña.
class InicioShell extends StatefulWidget {
  const InicioShell({super.key});

  @override
  State<InicioShell> createState() => _InicioShellState();
}

class _InicioShellState extends State<InicioShell> {
  int _indiceSeleccionado = 0;

  static const List<Widget> _pantallas = <Widget>[
    BusquedaScreen(),
    AgendaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceSeleccionado,
        children: _pantallas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSeleccionado,
        onDestinationSelected: (int indice) => setState(() => _indiceSeleccionado = indice),
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Mi Calendario',
          ),
        ],
      ),
    );
  }
}
