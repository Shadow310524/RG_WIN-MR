import 'package:dio/dio.dart';
import 'package:rgwin_crm/core/config/app_config.dart';
import 'package:rgwin_crm/core/network/dio_client.dart';
import 'package:rgwin_crm/features/auth/domain/models/user_model.dart';

class AuthResponseData {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponseData({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

class AuthApiService {
  final Dio _dio;

  AuthApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<AuthResponseData> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    return AuthResponseData(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthResponseData> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );

    final data = response.data as Map<String, dynamic>;
    return AuthResponseData(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<void> logout(String accessToken, {String? refreshToken}) async {
    await _dio.post(
      ApiEndpoints.logout,
      data: refreshToken != null ? {'refresh_token': refreshToken} : null,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  Future<UserModel> getMe(String accessToken) async {
    final response = await _dio.get(
      ApiEndpoints.me,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
