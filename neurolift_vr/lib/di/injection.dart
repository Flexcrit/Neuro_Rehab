import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/network/network_info.dart';

// ── Dashboard Feature ────────────────────────────────────────────────────────
import '../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../features/dashboard/data/datasources/dashboard_local_data_source.dart';
import '../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../features/dashboard/domain/usecases/get_daily_metrics.dart';
import '../features/dashboard/domain/usecases/get_recent_sessions.dart';
import '../features/dashboard/presentation/cubit/dashboard_cubit.dart';

// ── Patients Feature ─────────────────────────────────────────────────────────
import '../features/patients/data/datasources/patients_remote_data_source.dart';
import '../features/patients/data/repositories/patients_repository_impl.dart';
import '../features/patients/domain/repositories/patients_repository.dart';
import '../features/patients/domain/usecases/get_all_patients.dart';
import '../features/patients/presentation/cubit/patients_cubit.dart';

// ── Analytics Feature ────────────────────────────────────────────────────────
import '../features/analytics/data/datasources/analytics_remote_data_source.dart';
import '../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../features/analytics/domain/repositories/analytics_repository.dart';
import '../features/analytics/domain/usecases/get_recovery_trends.dart';
import '../features/analytics/presentation/cubit/analytics_cubit.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Initialize all dependencies in the service locator.
///
/// Call this once at app startup before runApp().
Future<void> initializeDependencies() async {
  // ── External ───────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // ═══════════════════════════════════════════════════════════════════════
  // DASHBOARD FEATURE
  // ═══════════════════════════════════════════════════════════════════════

  // Data Sources
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: getIt<DashboardRemoteDataSource>(),
      localDataSource: getIt<DashboardLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetDailyMetrics(getIt<DashboardRepository>()));
  getIt.registerLazySingleton(() => GetRecentSessions(getIt<DashboardRepository>()));

  // Cubit — registered as Factory so each screen gets a fresh instance
  getIt.registerFactory(() => DashboardCubit(
        getDailyMetrics: getIt<GetDailyMetrics>(),
        getRecentSessions: getIt<GetRecentSessions>(),
      ));

  // ═══════════════════════════════════════════════════════════════════════
  // PATIENTS FEATURE
  // ═══════════════════════════════════════════════════════════════════════

  getIt.registerLazySingleton<PatientsRemoteDataSource>(
    () => PatientsRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<PatientsRepository>(
    () => PatientsRepositoryImpl(
      remoteDataSource: getIt<PatientsRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton(() => GetAllPatients(getIt<PatientsRepository>()));
  getIt.registerFactory(() => PatientsCubit(
        getAllPatients: getIt<GetAllPatients>(),
      ));

  // ═══════════════════════════════════════════════════════════════════════
  // ANALYTICS FEATURE
  // ═══════════════════════════════════════════════════════════════════════

  getIt.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(
      remoteDataSource: getIt<AnalyticsRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton(() => GetRecoveryTrends(getIt<AnalyticsRepository>()));
  getIt.registerFactory(() => AnalyticsCubit(
        getRecoveryTrends: getIt<GetRecoveryTrends>(),
      ));
}
