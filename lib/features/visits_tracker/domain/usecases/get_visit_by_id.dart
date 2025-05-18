import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class GetVisitByIdUseCase {
  final VisitsRepository repository;

  GetVisitByIdUseCase(this.repository);

  Future<Visit?> call(int id) async {
    return repository.getVisitById(id);
  }
}
