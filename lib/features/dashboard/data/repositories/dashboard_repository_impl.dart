import 'package:rtm_sat/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:rtm_sat/features/dashboard/domain/entities/dashboard_item.dart';
import 'package:rtm_sat/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl(this.localDataSource);

  @override
  Future<List<DashboardItem>> getDashboardItems() async {
    return await localDataSource.getDashboardItems();
  }
}
