import 'package:get_it/get_it.dart';
import '../../features/dashboard_analytics/data/dashboard_repository_impl.dart';
import '../../features/dashboard_analytics/data/dashboard_service.dart';
import '../../features/dashboard_analytics/domain/dashboard_repository.dart';
import '../../features/dashboard_analytics/presentation/dashboard_view_model.dart';
import '../../features/iam/data/iam_repository_impl.dart';
import '../../features/iam/data/iam_service.dart';
import '../../features/iam/data/token_manager.dart';
import '../../features/iam/domain/iam_repository.dart';
import '../../features/iam/presentation/authentication_view_model.dart';
import '../../features/iam/presentation/password_recovery_view_model.dart';
import '../../features/iam/presentation/session_view_model.dart';
import '../../features/monitoring/data/monitoring_repository_impl.dart';
import '../../features/monitoring/data/monitoring_service.dart';
import '../../features/monitoring/domain/monitoring_repository.dart';
import '../../features/monitoring/presentation/monitoring_view_model.dart';
import '../../features/profiles_preferences/data/acl/iam_context_facade.dart';
import '../../features/profiles_preferences/data/profiles_repository_impl.dart';
import '../../features/profiles_preferences/data/profiles_service.dart';
import '../../features/profiles_preferences/domain/profiles_repository.dart';
import '../../features/profiles_preferences/presentation/profile_view_model.dart';
import '../../features/subscriptions_payments/data/subscription_repository_impl.dart';
import '../../features/subscriptions_payments/data/subscription_service.dart';
import '../../features/subscriptions_payments/domain/subscription_repository.dart';
import '../../features/subscriptions_payments/presentation/subscription_view_model.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // 1. Core / Session Storage
  getIt.registerLazySingleton<TokenManager>(() => TokenManager());

  // 2. Services (Data Sources)
  getIt.registerLazySingleton<IamService>(() => IamService());
  getIt.registerLazySingleton<ProfilesService>(
    () => ProfilesService(getIt<TokenManager>()),
  );
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
  getIt.registerLazySingleton<IamRepository>(
    () => IamRepositoryImpl(getIt<IamService>(), getIt<TokenManager>()),
  );
  getIt.registerLazySingleton<ProfilesRepository>(
    () => ProfilesRepositoryImpl(getIt<ProfilesService>()),
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

  // 4. Anti-Corruption Layers
  getIt.registerLazySingleton<IamContextFacade>(
    () => IamContextFacade(getIt<IamRepository>()),
  );

  // 5. ViewModels / Cubits
  getIt.registerFactory<SessionViewModel>(
    () => SessionViewModel(getIt<IamRepository>()),
  );
  getIt.registerFactory<AuthenticationViewModel>(
    () => AuthenticationViewModel(getIt<IamRepository>()),
  );
  getIt.registerFactory<PasswordRecoveryViewModel>(
    () => PasswordRecoveryViewModel(getIt<IamRepository>()),
  );
  getIt.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      getIt<ProfilesRepository>(),
      getIt<IamContextFacade>(),
    ),
  );
  getIt.registerFactory<DashboardViewModel>(
    () =>
        DashboardViewModel(getIt<DashboardRepository>(), getIt<TokenManager>()),
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
