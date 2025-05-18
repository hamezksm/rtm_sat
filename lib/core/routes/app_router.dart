import 'package:flutter/material.dart';
import 'package:rtm_sat/features/customers/presentation/pages/customers_page.dart';
import 'package:rtm_sat/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:rtm_sat/features/visits_tracker/domain/entities/visit.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/pages/visit_create_page.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/pages/visit_details_page.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/pages/visit_edit_page.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/pages/visits_list_page.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String dashboard = '/dashboard';
  static const String splash = '/splash';
  static const String visits = '/visits';
  static const String visitDetails = '/visits/details';
  static const String visitCreate = '/visits/create';
  static const String visitEdit = '/visits/edit';
  static const String customers = '/customers';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());

      case visits:
        return MaterialPageRoute(builder: (_) => const VisitsListPage());

      case visitDetails:
        final int visitId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => VisitDetailsPage(visitId: visitId),
        );

      case visitCreate:
        return MaterialPageRoute(builder: (_) => const VisitCreatePage());

      case visitEdit:
        final Visit visit = settings.arguments as Visit;
        return MaterialPageRoute(builder: (_) => VisitEditPage(visit: visit));

      case customers:
        return MaterialPageRoute(builder: (_) => const CustomerPage());

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
