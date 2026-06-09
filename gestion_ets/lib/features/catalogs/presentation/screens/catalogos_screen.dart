import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/carrera.dart';
import '../../domain/entities/salon.dart';
import '../providers/catalogo_provider.dart';

/// **Gestión de catálogos**: Carreras y Edificios/Salones — el módulo
/// administrativo necesita poder darlos de alta antes de ofertar exámenes,
/// ya que el formulario de exámenes selecciona ambos de listas vivas.
class CatalogosScreen extends StatelessWidget {
  const CatalogosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Catálogos'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Carreras', icon: Icon(Icons.school_outlined)),
              Tab(text: 'Edificios y salones', icon: Icon(Icons.meeting_room_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[_TabCarreras(), _TabSalones()],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Carreras
// ---------------------------------------------------------------------------

class _TabCarreras extends ConsumerWidget {
  const _TabCarreras();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Carrera>> carreras = ref.watch(carrerasCatalogoProvider);

    ref.listen<AsyncValue<List<Carrera>>>(carrerasCatalogoProvider, (
      AsyncValue<List<Carrera>>? anterior,
      AsyncValue<List<Carrera>> actual,
    ) {
      final Object? error = actual.error;
      if (error is Failure && actual.hasValue) {
        mostrarErrorEnSnackbar(context, error);
      }
    });

    return Scaffold(
      body: carreras.when(
        loading: () => const LoadingView(mensaje: 'Cargando carreras…'),
        error: (Object error, StackTrace _) => ErrorView(
          mensaje: error is Failure ? error.message : 'No fue posible cargar las carreras',
          onReintentar: () => ref.invalidate(carrerasCatalogoProvider),
        ),
        data: (List<Carrera> lista) => lista.isEmpty
            ? const _ListaVacia(
                mensaje: 'Aún no hay carreras registradas.\nUsa el botón "+" para dar de alta la primera.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: lista.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (BuildContext context, int indice) {
                  final Carrera carrera = lista[indice];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(carrera.clave)),
                      title: Text(carrera.nombre),
                      subtitle: Text('Clave: ${carrera.clave}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _abrirFormularioCarrera(context, ref, carrera: carrera),
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                            onPressed: () => _confirmarEliminarCarrera(context, ref, carrera),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormularioCarrera(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva carrera'),
      ),
    );
  }

  Future<void> _abrirFormularioCarrera(BuildContext context, WidgetRef ref, {Carrera? carrera}) {
    return showDialog<void>(
      context: context,
      builder: (_) => _FormularioCarrera(carrera: carrera),
    );
  }

  Future<void> _confirmarEliminarCarrera(BuildContext context, WidgetRef ref, Carrera carrera) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext contexto) => AlertDialog(
        title: const Text('Eliminar carrera'),
        content: Text('¿Seguro que deseas eliminar "${carrera.nombre}" del catálogo?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(contexto).pop(false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(contexto).colorScheme.error),
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar ?? false) {
      await ref.read(carrerasCatalogoProvider.notifier).eliminar(carrera.id);
    }
  }
}

class _FormularioCarrera extends ConsumerStatefulWidget {
  const _FormularioCarrera({this.carrera});

  final Carrera? carrera;

  @override
  ConsumerState<_FormularioCarrera> createState() => _FormularioCarreraState();
}

class _FormularioCarreraState extends ConsumerState<_FormularioCarrera> {
  final GlobalKey<FormState> _llave = GlobalKey<FormState>();
  late final TextEditingController _claveCtrl;
  late final TextEditingController _nombreCtrl;
  bool _enviando = false;

  bool get _esEdicion => widget.carrera != null;

  @override
  void initState() {
    super.initState();
    _claveCtrl = TextEditingController(text: widget.carrera?.clave ?? '');
    _nombreCtrl = TextEditingController(text: widget.carrera?.nombre ?? '');
  }

  @override
  void dispose() {
    _claveCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_esEdicion ? 'Editar carrera' : 'Nueva carrera'),
      content: Form(
        key: _llave,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _claveCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Clave (p. ej. ISC)'),
              validator: _requerido,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: _requerido,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _enviando ? null : _guardar,
          child: _enviando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }

  String? _requerido(String? valor) => (valor == null || valor.trim().isEmpty) ? 'Campo obligatorio' : null;

  Future<void> _guardar() async {
    if (!(_llave.currentState?.validate() ?? false)) {
      return;
    }
    final Carrera carrera = Carrera(
      id: widget.carrera?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      clave: _claveCtrl.text.trim().toUpperCase(),
      nombre: _nombreCtrl.text.trim(),
    );

    setState(() => _enviando = true);
    try {
      final CarrerasCatalogo notificador = ref.read(carrerasCatalogoProvider.notifier);
      if (_esEdicion) {
        await notificador.actualizar(carrera);
      } else {
        await notificador.crear(carrera);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Salones
// ---------------------------------------------------------------------------

class _TabSalones extends ConsumerWidget {
  const _TabSalones();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Salon>> salones = ref.watch(salonesCatalogoProvider);

    ref.listen<AsyncValue<List<Salon>>>(salonesCatalogoProvider, (
      AsyncValue<List<Salon>>? anterior,
      AsyncValue<List<Salon>> actual,
    ) {
      final Object? error = actual.error;
      if (error is Failure && actual.hasValue) {
        mostrarErrorEnSnackbar(context, error);
      }
    });

    return Scaffold(
      body: salones.when(
        loading: () => const LoadingView(mensaje: 'Cargando salones…'),
        error: (Object error, StackTrace _) => ErrorView(
          mensaje: error is Failure ? error.message : 'No fue posible cargar los salones',
          onReintentar: () => ref.invalidate(salonesCatalogoProvider),
        ),
        data: (List<Salon> lista) => lista.isEmpty
            ? const _ListaVacia(
                mensaje: 'Aún no hay salones registrados.\nUsa el botón "+" para dar de alta el primero.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: lista.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (BuildContext context, int indice) {
                  final Salon salon = lista[indice];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.meeting_room_rounded)),
                      title: Text(salon.nombreCompleto),
                      subtitle: Text(salon.direccionMapa ?? 'Sin ubicación de mapa registrada'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _abrirFormularioSalon(context, ref, salon: salon),
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                            onPressed: () => _confirmarEliminarSalon(context, ref, salon),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormularioSalon(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo salón'),
      ),
    );
  }

  Future<void> _abrirFormularioSalon(BuildContext context, WidgetRef ref, {Salon? salon}) {
    return showDialog<void>(
      context: context,
      builder: (_) => _FormularioSalon(salon: salon),
    );
  }

  Future<void> _confirmarEliminarSalon(BuildContext context, WidgetRef ref, Salon salon) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext contexto) => AlertDialog(
        title: const Text('Eliminar salón'),
        content: Text('¿Seguro que deseas eliminar "${salon.nombreCompleto}" del catálogo?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(contexto).pop(false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(contexto).colorScheme.error),
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar ?? false) {
      await ref.read(salonesCatalogoProvider.notifier).eliminar(salon.id);
    }
  }
}

class _FormularioSalon extends ConsumerStatefulWidget {
  const _FormularioSalon({this.salon});

  final Salon? salon;

  @override
  ConsumerState<_FormularioSalon> createState() => _FormularioSalonState();
}

class _FormularioSalonState extends ConsumerState<_FormularioSalon> {
  final GlobalKey<FormState> _llave = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _edificioCtrl;
  late final TextEditingController _mapaCtrl;
  bool _enviando = false;

  bool get _esEdicion => widget.salon != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.salon?.nombre ?? '');
    _edificioCtrl = TextEditingController(text: widget.salon?.edificio ?? '');
    _mapaCtrl = TextEditingController(text: widget.salon?.direccionMapa ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _edificioCtrl.dispose();
    _mapaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_esEdicion ? 'Editar salón' : 'Nuevo salón'),
      content: Form(
        key: _llave,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _edificioCtrl,
              decoration: const InputDecoration(labelText: 'Edificio (p. ej. Edificio de Posgrado)'),
              validator: _requerido,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Salón (p. ej. CC-301)'),
              validator: _requerido,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mapaCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Enlace de mapa (opcional)',
                hintText: 'https://maps.google.com/?q=…',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _enviando ? null : _guardar,
          child: _enviando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }

  String? _requerido(String? valor) => (valor == null || valor.trim().isEmpty) ? 'Campo obligatorio' : null;

  Future<void> _guardar() async {
    if (!(_llave.currentState?.validate() ?? false)) {
      return;
    }
    final String mapa = _mapaCtrl.text.trim();
    final Salon salon = Salon(
      id: widget.salon?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: _nombreCtrl.text.trim(),
      edificio: _edificioCtrl.text.trim(),
      direccionMapa: mapa.isEmpty ? null : mapa,
    );

    setState(() => _enviando = true);
    try {
      final SalonesCatalogo notificador = ref.read(salonesCatalogoProvider.notifier);
      if (_esEdicion) {
        await notificador.actualizar(salon);
      } else {
        await notificador.crear(salon);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }
}

class _ListaVacia extends StatelessWidget {
  const _ListaVacia({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(mensaje, textAlign: TextAlign.center),
      ),
    );
  }
}
