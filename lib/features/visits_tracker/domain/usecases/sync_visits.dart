import '../repositories/visits_repository.dart';

class SyncVisitsUseCase {
  final VisitsRepository repository;

  SyncVisitsUseCase(this.repository);

  Future<void> call() => repository.syncVisits();
}
