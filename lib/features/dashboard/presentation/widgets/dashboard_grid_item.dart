import 'package:flutter/material.dart';
import 'package:rtm_sat/features/dashboard/domain/entities/dashboard_item.dart';

class DashboardGridItem extends StatelessWidget {
  final DashboardItem item;

  const DashboardGridItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the specified route
        Navigator.pushNamed(context, item.route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border:
              item.title == 'Visits Tracker'
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    item.title == 'Visits Tracker'
                        ? Colors.blue
                        : Colors.blue.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(item.iconData),
                color:
                    item.title == 'Visits Tracker' ? Colors.white : Colors.blue,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: TextStyle(
                fontWeight:
                    item.title == 'Visits Tracker'
                        ? FontWeight.bold
                        : FontWeight.normal,
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'location_on':
        return Icons.location_on;
      case 'people':
        return Icons.people;
      case 'bar_chart':
        return Icons.bar_chart;
      default:
        return Icons.dashboard;
    }
  }
}
