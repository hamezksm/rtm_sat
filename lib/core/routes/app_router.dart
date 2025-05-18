import 'package:flutter/material.dart';
import 'package:rtm_sat/features/dashboard/presentation/pages/dashboard_page.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String dashboard = '/dashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
