import 'package:rgwin_crm/core/storage/secure_storage.dart';
import 'package:rgwin_crm/features/auth/data/auth_api_service.dart';
import 'package:rgwin_crm/features/auth/domain/models/user_model.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _storage;

  AuthRepository({AuthApiService? apiService, SecureStorageService? storage})
    : _apiService = apiService ?? AuthApiService(),
      _storage = storage ?? SecureStorageService();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final result = await _apiService.login(email: email, password: password);
    await _storage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    await _storage.saveUserRole(result.user.role);
    return result.user;
  }

  Future<UserModel?> restoreSession() async {
    final accessToken = await _storage.getAccessToken();
    if (accessToken == null) return null;

    try {
      return await _apiService.getMe(accessToken);
    } catch (_) {
      // Access token expired, try refresh token
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        await _storage.clearAll();
        return null;
      }

      try {
        final result = await _apiService.refreshToken(refreshToken);
        await _storage.saveTokens(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
        );
        await _storage.saveUserRole(result.user.role);
        return result.user;
      } catch (_) {
        await _storage.clearAll();
        return null;
      }
    }
  }

  Future<void> logout() async {
    final accessToken = await _storage.getAccessToken();
    final refreshToken = await _storage.getRefreshToken();
    if (accessToken != null) {
      try {
        await _apiService.logout(accessToken, refreshToken: refreshToken);
      } catch (_) {
        // Suppress network failures on logout
      }
    }
    await _storage.clearAll();
  }

  Future<String?> getAccessToken() => _storage.getAccessToken();
}
