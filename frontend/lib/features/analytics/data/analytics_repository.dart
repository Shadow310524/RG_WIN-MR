import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/network/dio_client.dart';
import 'package:rgwin_crm/core/storage/secure_storage.dart';
import 'package:rgwin_crm/core/utils/numeric_utils.dart';
import 'package:rgwin_crm/features/analytics/domain/models/analytics_models.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository();
});

class AnalyticsRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AnalyticsRepository({Dio? dio, SecureStorageService? storage})
    : _dio = dio ?? DioClient().dio,
      _storage = storage ?? SecureStorageService();

  Future<Options> _authOptions() async {
    final token = await _storage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<DoctorCommercialSummaryModel?> getDoctorSummary(
    String doctorId,
  ) async {
    try {
      final options = await _authOptions();
      final response = await _dio.get(
        '/analytics/doctor/$doctorId',
        options: options,
      );
      if (response.data is Map) {
        return DoctorCommercialSummaryModel.fromJson(
          asStringKeyedMap(response.data),
        );
      }
    } catch (_) {
      // Offline fallback can be derived or null
    }
    return null;
  }

  Future<AreaCommercialSummaryModel?> getAreaSummary(String areaId) async {
    try {
      final options = await _authOptions();
      final response = await _dio.get(
        '/analytics/area/$areaId',
        options: options,
      );
      if (response.data is Map) {
        return AreaCommercialSummaryModel.fromJson(
          asStringKeyedMap(response.data),
        );
      }
    } catch (_) {}
    return null;
  }

  Future<OverallCommercialSummaryModel?> getOverallSummary({
    String period = 'this_month',
  }) async {
    try {
      final options = await _authOptions();
      final response = await _dio.get(
        '/analytics/overall',
        queryParameters: {'period': period},
        options: options,
      );
      if (response.data is Map) {
        return OverallCommercialSummaryModel.fromJson(
          asStringKeyedMap(response.data),
        );
      }
    } catch (_) {}
    return null;
  }
}
