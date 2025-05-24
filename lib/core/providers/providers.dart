import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:rtm_sat/core/di/service_locator.dart';
import 'package:rtm_sat/features/activities/presentation/cubit/activity_cubit.dart';
import 'package:rtm_sat/features/customers/presentation/cubit/customer_cubit.dart';
import 'package:rtm_sat/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/cubit/visit_detail_cubit.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/cubit/visits_cubit.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/cubit/visits_list_filter/visits_list_filter_cubit.dart';

List<SingleChildWidget> getProviders() {
  return [
    BlocProvider<DashboardCubit>(
      create: (_) => sl<DashboardCubit>()..loadDashboardItems(),
    ),
    BlocProvider<VisitsCubit>(create: (_) => sl<VisitsCubit>()..getVisits()),
    BlocProvider<CustomerCubit>(
      create: (_) => sl<CustomerCubit>()..getCustomers(),
    ),
    BlocProvider<VisitDetailCubit>(create: (_) => sl<VisitDetailCubit>()),
    BlocProvider<ActivityCubit>(
      create: (_) => sl<ActivityCubit>()..getActivities(),
    ),
    BlocProvider<VisitsListFilterCubit>(
      create: (_) => sl<VisitsListFilterCubit>(),
    ),
  ];
}
