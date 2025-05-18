import 'package:equatable/equatable.dart';

class DashboardItem extends Equatable {
  final String id;
  final String title;
  final String iconData;
  final String route;

  const DashboardItem({
    required this.id,
    required this.title,
    required this.iconData,
    required this.route,
  });

  @override
  List<Object> get props => [id, title, iconData, route];
}
