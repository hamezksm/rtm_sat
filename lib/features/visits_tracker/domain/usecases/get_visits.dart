import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class GetVisitsUseCase {
  final VisitsRepository repository;

  GetVisitsUseCase(this.repository);

  Future<List<Visit>> call() => repository.getVisits();
}
