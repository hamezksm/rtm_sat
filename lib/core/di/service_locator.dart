import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:rtm_sat/core/api/api_service.dart';
import 'package:rtm_sat/core/constants/api.dart';
import 'package:rtm_sat/core/database/hive_database.dart';
import 'package:rtm_sat/core/network/network_info.dart';
import 'package:rtm_sat/features/activities/data/datasources/activity_local_data_source.dart';
import 'package:rtm_sat/features/activities/data/datasources/activity_remote_data_source.dart';
import 'package:rtm_sat/features/activities/data/models/activity_model.dart';
import 'package:rtm_sat/features/activities/data/repositories/activity_repository_impl.dart';
import 'package:rtm_sat/features/activities/domain/repositories/activity_repository.dart';
import 'package:rtm_sat/features/activities/presentation/cubit/activity_cubit.dart';
import 'package:rtm_sat/features/customers/data/datasources/customer_local_data_source.dart';
import 'package:rtm_sat/features/customers/data/datasources/customer_remote_data_source.dart';
import 'package:rtm_sat/features/customers/data/models/customer_model.dart';
import 'package:rtm_sat/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:rtm_sat/features/customers/domain/repositories/customer_repository.dart';
import 'package:rtm_sat/features/customers/presentation/cubit/customer_cubit.dart';
import 'package:rtm_sat/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:rtm_sat/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:rtm_sat/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:rtm_sat/features/dashboard/domain/usecases/get_dashboard_data_use_case.dart';
import 'package:rtm_sat/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:rtm_sat/features/visits_tracker/data/datasources/visits_local_data_source.dart';
import 'package:rtm_sat/features/visits_tracker/data/datasources/visits_remote_data_source.dart';
import 'package:rtm_sat/features/visits_tracker/data/models/visit_model.dart';
import 'package:rtm_sat/features/visits_tracker/data/repositories/visits_repository_impl.dart';
import 'package:rtm_sat/features/visits_tracker/domain/entities/visit.dart';
import 'package:rtm_sat/features/visits_tracker/domain/repositories/visits_repository.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/create_visit.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/delete_visit.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/get_visits.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/sync_visits.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/update_visit.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/get_visit_by_id.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/cubit/visit_detail_cubit.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/cubit/visits_cubit.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/cubit/visit_form_cubit.dart';

final GetIt sl = GetIt.instance;

bool _isInitialized = false;

Future<void> initDependencies() async {
  if (_isInitialized) return;

  // Register core services first
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
  }

  // Initialize Hive
  await HiveDatabase.init();

  // Register Hive adapters
  Hive.registerAdapter(CustomerModelAdapter());
  Hive.registerAdapter(VisitModelAdapter());
  Hive.registerAdapter(ActivityModelAdapter());

  // Open Hive boxes
  final dashboardBox = await HiveDatabase.openBox<Map>('dashboard');
  await HiveDatabase.openBox<CustomerModel>('customers');
  final visitsBox = await HiveDatabase.openBox<VisitModel>('visits');
  await HiveDatabase.openBox<ActivityModel>('activities');

  // Customer and Activity Feature
  // Network Info
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  sl.registerLazySingleton<Box<CustomerModel>>(
    () => Hive.box<CustomerModel>('customers'),
  );

  sl.registerLazySingleton<Box<ActivityModel>>(
    () => Hive.box<ActivityModel>('activities'),
  );

  // Data sources
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(
      client: sl<http.Client>(),
      baseUrl: Api.baseUrl,
      apiKey: Api.apiKey,
    ),
  );

  sl.registerLazySingleton<CustomerLocalDataSource>(
    () => CustomerLocalDataSourceImpl(customerBox: sl<Box<CustomerModel>>()),
  );

  sl.registerLazySingleton<ActivityRemoteDataSource>(
    () => ActivityRemoteDataSourceImpl(apiService: sl<ApiService>()),
  );

  sl.registerLazySingleton<ActivityLocalDataSource>(
    () => ActivityLocalDataSourceImpl(activityBox: sl<Box<ActivityModel>>()),
  );

  sl.registerFactory(() => CustomerCubit(repository: sl<CustomerRepository>()));

  // Activity Repository
  sl.registerLazySingleton<ActivityRepository>(
    () => ActivityRepositoryImpl(
      remoteDataSource: sl<ActivityRemoteDataSource>(),
      localDataSource: sl<ActivityLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton<ApiService>(
    () => ApiService(
      client: sl<http.Client>(),
      baseUrl: Api.baseUrl,
      apiKey: Api.apiKey,
    ),
  );

  // Repository
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(
      customerLocalDataSource: sl<CustomerLocalDataSource>(),
      customerRemoteDataSource: sl<CustomerRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Dashboard feature
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

  // Visits Tracker Feature
  // Data Sources
  sl.registerLazySingleton<VisitsLocalDataSource>(
    () => VisitsLocalDataSourceImpl(visitsBox),
  );

  sl.registerLazySingleton<VisitsRemoteDataSource>(
    () => VisitsRemoteDataSourceImpl(
      client: sl<http.Client>(),
      baseUrl: Api.baseUrl,
      apiKey: Api.apiKey,
    ),
  );

  // Repository
  sl.registerLazySingleton<VisitsRepository>(
    () => VisitsRepositoryImpl(
      localDataSource: sl<VisitsLocalDataSource>(),
      remoteDataSource: sl<VisitsRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetVisitsUseCase(sl<VisitsRepository>()));

  sl.registerLazySingleton(() => CreateVisitUseCase(sl<VisitsRepository>()));
  sl.registerLazySingleton(() => UpdateVisitUseCase(sl<VisitsRepository>()));
  sl.registerLazySingleton(() => DeleteVisitUseCase(sl<VisitsRepository>()));
  sl.registerLazySingleton(() => SyncVisitsUseCase(sl<VisitsRepository>()));
  sl.registerLazySingleton(() => GetVisitByIdUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => VisitsCubit(
      getVisitsUseCase: sl<GetVisitsUseCase>(),
      createVisitUseCase: sl<CreateVisitUseCase>(),
      updateVisitUseCase: sl<UpdateVisitUseCase>(),
      deleteVisitUseCase: sl<DeleteVisitUseCase>(),
      syncVisitsUseCase: sl<SyncVisitsUseCase>(),
      getVisitByIdUseCase: sl<GetVisitByIdUseCase>(),
    ),
  );

  sl.registerFactory(
    () => VisitDetailCubit(updateVisitUseCase: sl<UpdateVisitUseCase>()),
  );

  // Register Activity Cubit
  sl.registerFactory<ActivityCubit>(
    () => ActivityCubit(repository: sl<ActivityRepository>()),
  );

  // Register VisitFormCubit

  sl.registerFactoryParam<VisitFormCubit, Visit?, void>(
    (visit, _) => VisitFormCubit(
      customerRepository: sl<CustomerRepository>(),
      activityRepository: sl<ActivityRepository>(),
      initialVisit: visit,
    ),
  );

  // Print success message for debugging
  log('Service locator initialized successfully');

  _isInitialized = true;
}
