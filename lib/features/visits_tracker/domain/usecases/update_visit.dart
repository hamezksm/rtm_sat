import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class UpdateVisitUseCase {
  final VisitsRepository repository;

  UpdateVisitUseCase(this.repository);

  Future<void> call(Visit visit) => repository.updateVisit(visit);
}
