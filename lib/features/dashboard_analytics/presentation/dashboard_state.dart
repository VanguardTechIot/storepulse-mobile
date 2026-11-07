import '../domain/dashboard_summary.dart';

sealed class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final String activeRole; // 'GALLERY_ADMINISTRATOR' | 'TENANT'

  DashboardLoaded({
    required this.summary,
    required this.activeRole,
  });

  bool get isGalleryAdmin => activeRole == 'GALLERY_ADMINISTRATOR';
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}