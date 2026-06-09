import '../entities/carrera.dart';
import '../entities/salon.dart';

/// Contrato de la capa de dominio para administrar los catálogos de
/// **Carreras** y **Edificios/Salones** (Módulo Administrativo →
/// Gestión de Catálogos).
abstract interface class CatalogoRepository {
  Future<List<Carrera>> obtenerCarreras();

  Future<Carrera> crearCarrera(Carrera carrera);

  Future<Carrera> actualizarCarrera(Carrera carrera);

  Future<void> eliminarCarrera(String id);

  Future<List<Salon>> obtenerSalones();

  Future<Salon> crearSalon(Salon salon);

  Future<Salon> actualizarSalon(Salon salon);

  Future<void> eliminarSalon(String id);

  /// Sincroniza ambos catálogos desde el backend hacia la caché local.
  Future<void> sincronizar();
}
