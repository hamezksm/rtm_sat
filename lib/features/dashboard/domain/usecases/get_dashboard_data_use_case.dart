import 'package:rtm_sat/features/dashboard/domain/entities/dashboard_item.dart';
import 'package:rtm_sat/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardDataUseCase {
  final DashboardRepository repository;

  GetDashboardDataUseCase(this.repository);

  Future<List<DashboardItem>> call() {
    return repository.getDashboardItems();
  }
}
