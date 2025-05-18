import 'package:rtm_sat/features/dashboard/domain/entities/dashboard_item.dart';

class DashboardItemModel extends DashboardItem {
  const DashboardItemModel({
    required super.id,
    required super.title,
    required super.iconData,
    required super.route,
  });

  factory DashboardItemModel.fromMap(Map<String, dynamic> map) {
    return DashboardItemModel(
      id: map['id'] as String,
      title: map['title'] as String,
      iconData: map['iconData'] as String,
      route: map['route'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'iconData': iconData, 'route': route};
  }
}
