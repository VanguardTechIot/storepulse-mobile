import 'package:flutter_bloc/flutter_bloc.dart';
import '../../iam/data/token_manager.dart';
import '../domain/dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardViewModel extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  final TokenManager _tokenManager;

  DashboardViewModel(this._dashboardRepository, this._tokenManager)
      : super(DashboardInitial());

  Future<void> loadSummary() async {
    emit(DashboardLoading());
    try {
      final role = await _tokenManager.getRole();
      final summary = await _dashboardRepository.getDashboardSummary();
      emit(DashboardLoaded(summary: summary, activeRole: role));
    } catch (e) {
      emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}