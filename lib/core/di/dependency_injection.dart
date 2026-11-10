import 'package:get_it/get_it.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/auth/data/token_manager.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/login_view_model.dart';
import '../../features/dashboard_analytics/data/dashboard_repository_impl.dart';
import '../../features/dashboard_analytics/data/dashboard_service.dart';
import '../../features/dashboard_analytics/domain/dashboard_repository.dart';
import '../../features/dashboard_analytics/presentation/dashboard_view_model.dart';
import '../../features/monitoring/data/monitoring_repository_impl.dart';
import '../../features/monitoring/data/monitoring_service.dart';
import '../../features/monitoring/domain/monitoring_repository.dart';
import '../../features/monitoring/presentation/monitoring_view_model.dart';
import '../../features/subscriptions_payments/data/subscription_repository_impl.dart';
import '../../features/subscriptions_payments/data/subscription_service.dart';
import '../../features/subscriptions_payments/domain/subscription_repository.dart';
import '../../features/subscriptions_payments/presentation/subscription_view_model.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // 1. Core / Session Storage
  getIt.registerLazySingleton<TokenManager>(() => TokenManager());

  // 2. Services (Data Sources)
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<DashboardService>(
    () => DashboardService(getIt<TokenManager>()),
  );
  getIt.registerLazySingleton<SubscriptionService>(
    () => SubscriptionService(getIt<TokenManager>()),
  );
  getIt.registerLazySingleton<MonitoringService>(
    () => MonitoringService(getIt<TokenManager>()),
  );

  // 3. Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthService>(), getIt<TokenManager>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt<DashboardService>()),
  );
  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(getIt<SubscriptionService>()),
  );
  getIt.registerLazySingleton<MonitoringRepository>(
    () => MonitoringRepositoryImpl(getIt<MonitoringService>()),
  );

  // 4. ViewModels / Cubits
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt<AuthRepository>()),
  );
  getIt.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(
      getIt<DashboardRepository>(),
      getIt<TokenManager>(),
    ),
  );
  getIt.registerFactory<MonitoringViewModel>(
    () => MonitoringViewModel(getIt<MonitoringRepository>()),
  );
  getIt.registerFactory<SubscriptionViewModel>(
    () => SubscriptionViewModel(
      getIt<SubscriptionRepository>(),
      getIt<TokenManager>(),
    ),
  );
}