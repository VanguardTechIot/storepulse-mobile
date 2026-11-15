# StorePulse Mobile

Mobile application of **StorePulse**, the IoT platform of VanguardTech for commercial galleries in Lima: real-time safety alerts, utility consumption monitoring, dashboard analytics, subscription management, and user profiles for **Gallery Administrators** and **Store Tenants**.

| Repository | Role |
|---|---|
| [storepulse-platform](https://github.com/VanguardTechIot/storepulse-platform) | REST API (Spring Boot) consumed by this application |
| [storepulse-web-application](https://github.com/VanguardTechIot/storepulse-web-application) | Web application of the gallery administrator (Angular) |
| [storepulse-edge](https://github.com/VanguardTechIot/storepulse-edge) | Edge API that receives the telemetry of the IoT nodes |
| [storepulse-landing-page](https://github.com/VanguardTechIot/storepulse-landing-page) | Public landing page |
| [storepulse-report](https://github.com/VanguardTechIot/storepulse-report) | Project report (DDD, architecture, user stories) |

## Stack

- Flutter (Dart SDK `^3.12.2`) with Material 3 theming (`AppTheme`, `StatusColors`).
- `flutter_bloc` (`Bloc` / `Cubit` view models) for reactive state management.
- `get_it` for dependency injection (`setupDependencyInjection()`).
- `http` for REST communication against [StorePulse Platform](https://github.com/VanguardTechIot/storepulse-platform).
- `shared_preferences` (`TokenManager`) for JWT session persistence.
- `flutter_test` and `flutter_lints` for unit/widget testing and static analysis.

## Getting started

By default, `ApiConfig.baseUrl` points to the deployed backend (`https://storepulse-platform-production.up.railway.app/api/v1`). You can override it at compile time via `--dart-define`:

```bash
flutter pub get
flutter run
# Point Android emulator to a local Spring Boot backend:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
flutter test
flutter analyze
```

## Architecture

The project is organized by **Feature Bounded Context** under `lib/features/`, each divided into clean layers (`domain/`, `data/`, `presentation/`), supported by shared infrastructure in `lib/core/`:

```text
lib/
  core/
    config/    API base URL configuration (ApiConfig)
    di/        GetIt service locator registration (dependency_injection.dart)
    network/   Backend error code mapping (ApiErrorCode)
    router/    Named routes (AppRoutes)
    theme/     Material 3 light theme and semantic status colors
    widgets/   Shared UI components (ProgressFilledButton, showAppSnackBar)
  features/
    <context>/
      domain/        entities, value objects, commands, domain errors and repository contracts
      data/          HTTP services, DTOs, ACL facades and repository implementations
      presentation/  pages, BLoC/Cubit view models, states, validators and widgets
```

| Feature Folder | Bounded Context | Responsibility |
|---|---|---|
| `iam/` | Identity and Access Management | Splash screen, sign-in, sign-up, password recovery (`ForgotPasswordPage`, `ResetPasswordPage`), session BLoC (`SessionViewModel`), roles (`gallery_administrator`, `tenant`), and branded `IamHeader`. |
| `profiles_preferences/` | Profiles and Preferences | Profile page, profile details editing, photo dialog, and `IamContextFacade` ACL lookup. |
| `dashboard_analytics/` | Dashboard and Analytics | Gallery and store telemetry KPIs, consumption summary, and responsive safety incident cards. |
| `monitoring/` | Service Execution and Monitoring | Monitored locations, real-time sensor status overview, and electricity/water consumption views. |
| `subscriptions_payments/` | Subscriptions and Payments | Plan catalog, administrator checkout (`SubscriptionCheckoutPage`) and payment history, plus tenant IoT coverage status banner. |
| `main/` | App Shell | Role-aware bottom navigation (`Dashboard`, `Monitoring`, `Subscriptions / IoT Coverage`), StorePulse app bar, profile navigation, and sign-out confirmation. |

## Navigation Routes

Defined in `lib/core/router/app_routes.dart`:

| Route | Screen | Purpose |
|---|---|---|
| `/` | `SplashPage` | Restores persisted JWT session and routes to `/main` or `/sign-in`. |
| `/sign-in` | `SignInPage` | User authentication and role-aware session start. |
| `/sign-up` | `SignUpPage` | Account registration (administrator or tenant). |
| `/forgot-password` | `ForgotPasswordPage` | Requests password recovery code by email. |
| `/reset-password` | `ResetPasswordPage` | Resets password using the verification code. |
| `/main` | `MainPage` | Authenticated workspace with role-based bottom navigation tabs. |
| `/profile` | `ProfilePage` | Signed-in user profile details and photo update. |

## Conventions

- Branches: `feature/<name>` from `develop`; releases through `release/x.y.z` into `main`.
- Commits: Conventional Commits with context scope, for example `feat(monitoring): ...`.
- Code identifiers and technical comments in English.
