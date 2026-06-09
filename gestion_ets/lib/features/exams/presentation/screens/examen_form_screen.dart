import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../catalogs/domain/entities/carrera.dart';
import '../../../catalogs/domain/entities/salon.dart';
import '../../../catalogs/presentation/providers/catalogo_provider.dart';
import '../../domain/entities/examen.dart';
import '../providers/examen_admin_provider.dart';

/// Formulario de **Alta / Edición** de un examen de la oferta — cubre las
/// operaciones "Cambios" y "Altas" del CRUD administrativo.
///
/// Si [examen] es `null` se trata de un alta; en caso contrario, de una
/// edición. Los catálogos de Carreras y Salones se consultan en vivo para
/// evitar capturar texto libre (y así mantener la integridad referencial).
class ExamenFormScreen extends ConsumerStatefulWidget {
  const ExamenFormScreen({super.key, this.examen});

  final Examen? examen;

  bool get esEdicion => examen != null;

  @override
  ConsumerState<ExamenFormScreen> createState() => _ExamenFormScreenState();
}

class _ExamenFormScreenState extends ConsumerState<ExamenFormScreen> {
  final GlobalKey<FormState> _llaveFormulario = GlobalKey<FormState>();
  late final TextEditingController _unidadCtrl;
  late final TextEditingController _profesorCtrl;

  String? _carreraId;
  int? _semestre;
  String? _salonId;
  Turno _turno = Turno.matutino;
  DateTime? _fechaHora;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final Examen? examen = widget.examen;
    _unidadCtrl = TextEditingController(text: examen?.unidadAprendizaje ?? '');
    _profesorCtrl = TextEditingController(text: examen?.profesorEvaluador ?? '');
    _carreraId = examen?.carreraId;
    _semestre = examen?.semestre;
    _salonId = examen?.salonId;
    _turno = examen?.turno ?? Turno.matutino;
    _fechaHora = examen?.fecha;
  }

  @override
  void dispose() {
    _unidadCtrl.dispose();
    _profesorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Carrera>> carreras = ref.watch(carrerasCatalogoProvider);
    final AsyncValue<List<Salon>> salones = ref.watch(salonesCatalogoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.esEdicion ? 'Editar examen' : 'Nuevo examen')),
      body: carreras.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorView(
          mensaje: error is Failure ? error.message : 'No fue posible cargar el catálogo de carreras',
          onReintentar: () => ref.invalidate(carrerasCatalogoProvider),
        ),
        data: (List<Carrera> listaCarreras) => salones.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace _) => ErrorView(
            mensaje: error is Failure ? error.message : 'No fue posible cargar el catálogo de salones',
            onReintentar: () => ref.invalidate(salonesCatalogoProvider),
          ),
          data: (List<Salon> listaSalones) => _formulario(context, listaCarreras, listaSalones),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context, List<Carrera> carreras, List<Salon> salones) {
    if (carreras.isEmpty || salones.isEmpty) {
      return const ErrorView(
        mensaje: 'Antes de capturar exámenes, registra al menos una carrera y un salón '
            'en Catálogos.',
      );
    }

    return Form(
      key: _llaveFormulario,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextFormField(
            controller: _unidadCtrl,
            decoration: const InputDecoration(
              labelText: 'Unidad de Aprendizaje (Materia)',
              prefixIcon: Icon(Icons.menu_book_rounded),
            ),
            validator: _requerido,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _carreraId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Carrera', prefixIcon: Icon(Icons.school_rounded)),
            items: carreras
                .map((Carrera c) => DropdownMenuItem<String>(
                    value: c.id, child: Text('${c.clave} — ${c.nombre}', overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (String? valor) => setState(() => _carreraId = valor),
            validator: (String? valor) => valor == null ? 'Selecciona una carrera' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _semestre,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Semestre',
              prefixIcon: Icon(Icons.format_list_numbered_rounded),
            ),
            items: AppConstants.semestres
                .map((int s) => DropdownMenuItem<int>(value: s, child: Text('$s.º semestre')))
                .toList(),
            onChanged: (int? valor) => setState(() => _semestre = valor),
            validator: (int? valor) => valor == null ? 'Selecciona un semestre' : null,
          ),
          const SizedBox(height: 16),
          _selectorFechaHora(context),
          const SizedBox(height: 16),
          SegmentedButton<Turno>(
            segments: Turno.values
                .map((Turno t) => ButtonSegment<Turno>(value: t, label: Text(t.etiqueta)))
                .toList(),
            selected: <Turno>{_turno},
            onSelectionChanged: (Set<Turno> seleccion) => setState(() => _turno = seleccion.first),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _salonId,
            isExpanded: true,
            decoration:
                const InputDecoration(labelText: 'Salón', prefixIcon: Icon(Icons.meeting_room_rounded)),
            items: salones
                .map((Salon s) => DropdownMenuItem<String>(
                    value: s.id, child: Text(s.nombreCompleto, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (String? valor) => setState(() => _salonId = valor),
            validator: (String? valor) => valor == null ? 'Selecciona un salón' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _profesorCtrl,
            decoration: const InputDecoration(
              labelText: 'Profesor evaluador',
              prefixIcon: Icon(Icons.person_rounded),
            ),
            validator: _requerido,
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _enviando ? null : _guardar,
            icon: _enviando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_rounded),
            label: Text(widget.esEdicion ? 'Guardar cambios' : 'Registrar examen'),
          ),
        ],
      ),
    );
  }

  Widget _selectorFechaHora(BuildContext context) {
    final String etiqueta = _fechaHora == null
        ? 'Selecciona fecha y hora'
        : '${DateFormatter.fechaCorta(_fechaHora!)} · ${DateFormatter.hora(_fechaHora!)} h';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _seleccionarFechaHora,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha y hora del examen',
          prefixIcon: Icon(Icons.event_rounded),
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(etiqueta)),
            const Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFechaHora() async {
    final DateTime ahora = DateTime.now();
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaHora ?? ahora.add(const Duration(days: 7)),
      firstDate: ahora.subtract(const Duration(days: 1)),
      lastDate: ahora.add(const Duration(days: 365)),
    );
    if (fecha == null || !mounted) {
      return;
    }
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _fechaHora == null
          ? const TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay.fromDateTime(_fechaHora!),
    );
    if (hora == null) {
      return;
    }
    setState(() {
      _fechaHora = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    });
  }

  String? _requerido(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  Future<void> _guardar() async {
    final bool formularioValido = _llaveFormulario.currentState?.validate() ?? false;
    if (!formularioValido || _fechaHora == null) {
      if (_fechaHora == null) {
        mostrarErrorEnSnackbar(context, const ValidacionFailure('Selecciona la fecha y hora del examen'));
      }
      return;
    }

    final List<Carrera> carreras = ref.read(carrerasCatalogoProvider).valueOrNull ?? const <Carrera>[];
    final List<Salon> salones = ref.read(salonesCatalogoProvider).valueOrNull ?? const <Salon>[];
    final Carrera carrera = carreras.firstWhere((Carrera c) => c.id == _carreraId);
    final Salon salon = salones.firstWhere((Salon s) => s.id == _salonId);

    final Examen examen = Examen(
      id: widget.examen?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      unidadAprendizaje: _unidadCtrl.text.trim(),
      carreraId: carrera.id,
      carreraNombre: carrera.nombre,
      semestre: _semestre!,
      fecha: _fechaHora!,
      turno: _turno,
      salonId: salon.id,
      salonNombre: salon.nombreCompleto,
      profesorEvaluador: _profesorCtrl.text.trim(),
    );

    setState(() => _enviando = true);
    try {
      final ExamenesAdmin notificador = ref.read(examenesAdminProvider.notifier);
      if (widget.esEdicion) {
        await notificador.actualizar(examen);
      } else {
        await notificador.crear(examen);
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
