import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/features/auth/data/auth_repository.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> checkSession() async {
    state = state.copyWith(status: AuthStatus.checking, isLoading: true);
    try {
      final user = await _repository.restoreSession();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          clearError: true,
        );
      }
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      final errorMsg =
          e.toString().contains("Invalid") ||
              e.toString().contains("credentials")
          ? "Invalid email or password. Please verify and try again."
          : e.toString().contains("inactive")
          ? "Account is inactive. Contact administrator."
          : "Unable to connect to server. Please check your network.";

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: errorMsg,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.logout();
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}
