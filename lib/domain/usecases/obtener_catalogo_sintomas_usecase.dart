import '../entities/sintoma.dart';
import '../repositories/enfermero_dashboard_repository.dart';

class ObtenerCatalogoSintomasUseCase {
  final EnfermeroDashboardRepository repository;

  ObtenerCatalogoSintomasUseCase(this.repository);

  Future<List<Sintoma>> call() async {
    return repository.obtenerCatalogoSintomas();
  }
}
