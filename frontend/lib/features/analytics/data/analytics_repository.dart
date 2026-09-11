import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/network/dio_client.dart';
import 'package:rgwin_crm/core/storage/secure_storage.dart';
import 'package:rgwin_crm/core/utils/numeric_utils.dart';
import 'package:rgwin_crm/features/analytics/domain/models/analytics_models.dart';

class AnalyticsFetchResult {
  final OverallCommercialSummaryModel? summary;
  final bool isCached;
  final DateTime? cachedTimestamp;

  const AnalyticsFetchResult({
    this.summary,
    this.isCached = false,
    this.cachedTimestamp,
  });
}

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
    String doctorId, {
    String period = 'all',
  }) async {
    try {
      final options = await _authOptions();
      final response = await _dio.get(
        '/analytics/doctor/$doctorId',
        queryParameters: {'period': period},
        options: options,
      );
      if (response.data is Map) {
        return DoctorCommercialSummaryModel.fromJson(
          asStringKeyedMap(response.data),
        );
      }
    } catch (_) {}
    return null;
  }

  Future<AreaCommercialSummaryModel?> getAreaSummary(
    String areaId, {
    String period = 'all',
  }) async {
    try {
      final options = await _authOptions();
      final response = await _dio.get(
        '/analytics/area/$areaId',
        queryParameters: {'period': period},
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

  Future<AnalyticsFetchResult> getOverallSummary({
    String period = 'this_month',
  }) async {
    final cacheKey = 'analytics_overall_$period';
    final timestampKey = 'analytics_overall_ts_$period';

    try {
      final options = await _authOptions();
      final response = await _dio.get(
        '/analytics/overall',
        queryParameters: {'period': period},
        options: options,
      );
      if (response.data is Map) {
        final summary = OverallCommercialSummaryModel.fromJson(
          asStringKeyedMap(response.data),
        );
        final now = DateTime.now();

        // Persist to local cache asynchronously
        try {
          await _storage.write(cacheKey, jsonEncode(summary.toJson()));
          await _storage.write(timestampKey, now.toIso8601String());
        } catch (_) {}

        return AnalyticsFetchResult(
          summary: summary,
          isCached: false,
          cachedTimestamp: now,
        );
      }
    } catch (_) {
      // Network failure: Attempt to serve from offline cache
      try {
        final cachedJson = await _storage.read(cacheKey);
        final tsStr = await _storage.read(timestampKey);
        if (cachedJson != null && cachedJson.isNotEmpty) {
          final decoded = jsonDecode(cachedJson);
          if (decoded is Map) {
            final summary = OverallCommercialSummaryModel.fromJson(
              asStringKeyedMap(decoded),
            );
            final cachedTs = tsStr != null ? DateTime.tryParse(tsStr) : null;
            return AnalyticsFetchResult(
              summary: summary,
              isCached: true,
              cachedTimestamp: cachedTs,
            );
          }
        }
      } catch (_) {}
    }

    return const AnalyticsFetchResult(summary: null, isCached: false);
  }
}
