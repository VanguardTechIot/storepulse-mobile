import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/iam_repository.dart';
import '../domain/user_account.dart';
import 'session_state.dart';

class SessionViewModel extends Cubit<SessionState> {
  final IamRepository _iamRepository;

  SessionViewModel(this._iamRepository) : super(SessionChecking());

  Future<void> restore() async {
    try {
      final user = await _iamRepository.restoreSession();
      emit(
        user == null ? SessionUnauthenticated() : SessionAuthenticated(user),
      );
    } catch (_) {
      emit(SessionUnauthenticated());
    }
  }

  void authenticated(UserAccount user) => emit(SessionAuthenticated(user));

  Future<void> reload() async {
    final user = await _iamRepository.currentUser();
    emit(user == null ? SessionUnauthenticated() : SessionAuthenticated(user));
  }

  Future<void> signOut() async {
    await _iamRepository.signOut();
    emit(SessionUnauthenticated());
  }
}
