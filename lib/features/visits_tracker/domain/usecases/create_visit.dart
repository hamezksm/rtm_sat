import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class CreateVisitUseCase {
  final VisitsRepository repository;

  CreateVisitUseCase(this.repository);

  Future call(Visit visit) => repository.createVisit(visit);
}
