import 'package:get_it/get_it.dart';
import 'package:rtm_sat/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:rtm_sat/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:rtm_sat/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:rtm_sat/features/dashboard/domain/usecases/get_dashboard_data_use_case.dart';
import 'package:rtm_sat/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:rtm_sat/core/database/hive_database.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Database
  await HiveDatabase.init();
  final dashboardBox = await HiveDatabase.openBox<Map>('dashboard');

  // Data sources
  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(dashboardBox),
  );

  // Repositories
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl<DashboardLocalDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(
    () => GetDashboardDataUseCase(sl<DashboardRepository>()),
  );

  // Cubits
  sl.registerFactory(() => DashboardCubit(sl<GetDashboardDataUseCase>()));
}
