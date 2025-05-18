import '../repositories/visits_repository.dart';

class DeleteVisitUseCase {
  final VisitsRepository repository;

  DeleteVisitUseCase(this.repository);

  Future<void> call(int id) => repository.deleteVisit(id);
}
