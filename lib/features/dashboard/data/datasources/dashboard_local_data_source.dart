import 'package:hive/hive.dart';
import 'package:rtm_sat/features/dashboard/data/models/dashboard_item_model.dart';

abstract class DashboardLocalDataSource {
  Future<List<DashboardItemModel>> getDashboardItems();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final Box<Map> dashboardBox;

  DashboardLocalDataSourceImpl(this.dashboardBox);

  @override
  Future<List<DashboardItemModel>> getDashboardItems() async {
    // Initialize default data if empty
    if (dashboardBox.isEmpty) {
      await _initDefaultDashboardItems();
    }

    final items = dashboardBox.values.toList();
    return items
        .map(
          (item) => DashboardItemModel.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> _initDefaultDashboardItems() async {
    final defaultItems = [
      {
        'id': '1',
        'title': 'Visits Tracker',
        'iconData': 'location_on',
        'route': '/visits',
      },
      {
        'id': '2',
        'title': 'Customers',
        'iconData': 'people',
        'route': '/customers',
      },
    ];

    for (final item in defaultItems) {
      await dashboardBox.add(item);
    }
  }
}
