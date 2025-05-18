import 'package:rtm_sat/features/dashboard/domain/entities/dashboard_item.dart';

abstract class DashboardRepository {
  Future<List<DashboardItem>> getDashboardItems();
}
