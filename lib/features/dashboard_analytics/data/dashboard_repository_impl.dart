import '../domain/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';
import 'dashboard_service.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepositoryImpl(this._dashboardService);

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    final dto = await _dashboardService.fetchDashboardSummary();
    return dto.toDomain();
  }
}