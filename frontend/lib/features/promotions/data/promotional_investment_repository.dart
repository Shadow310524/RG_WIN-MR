import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/network/dio_client.dart';
import 'package:rgwin_crm/core/storage/secure_storage.dart';
import 'package:rgwin_crm/features/promotions/domain/models/promotional_investment_model.dart';

final promotionalInvestmentRepositoryProvider =
    Provider<PromotionalInvestmentRepository>((ref) {
      return PromotionalInvestmentRepository();
    });

class PromotionalInvestmentRepository {
  final Dio _dio;
  final SecureStorageService _storage;
  final List<PromotionalInvestmentModel> _localInvestments = [];

  PromotionalInvestmentRepository({Dio? dio, SecureStorageService? storage})
    : _dio = dio ?? DioClient().dio,
      _storage = storage ?? SecureStorageService();

  Future<Options> _authOptions() async {
    final token = await _storage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<PromotionalInvestmentModel>> getInvestments({
    String? doctorId,
    String? visitId,
  }) async {
    try {
      final options = await _authOptions();
      final queryParams = <String, dynamic>{};
      if (doctorId != null && doctorId.isNotEmpty) {
        queryParams['doctor_id'] = doctorId;
      }
      if (visitId != null && visitId.isNotEmpty) {
        queryParams['visit_id'] = visitId;
      }

      final response = await _dio.get(
        '/promotional-investments',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: options,
      );

      final data = response.data;
      final List rawItems = data is List
          ? data
          : (data is Map && data['items'] is List ? data['items'] as List : []);

      final serverInvestments = rawItems.map((json) {
        return PromotionalInvestmentModel.fromJson(
          json as Map<String, dynamic>,
        );
      }).toList();

      // Merge with offline pending items not yet on server
      final pendingItems = _localInvestments.where((local) {
        return local.syncState != 'synced' &&
            (doctorId == null || local.doctorId == doctorId) &&
            (visitId == null || local.visitId == visitId);
      }).toList();

      return [...pendingItems, ...serverInvestments];
    } catch (_) {
      // Offline fallback: return local in-memory investments
      if (doctorId != null) {
        return _localInvestments
            .where((item) => item.doctorId == doctorId)
            .toList();
      }
      return _localInvestments;
    }
  }

  Future<PromotionalInvestmentModel> recordInvestment({
    required String doctorId,
    String? doctorName,
    String? visitId,
    required double amount,
    required String investmentType,
    required DateTime investmentDate,
    String? notes,
  }) async {
    final localId = "inv_${DateTime.now().millisecondsSinceEpoch}";
    final investment = PromotionalInvestmentModel(
      id: localId,
      doctorId: doctorId,
      doctorName: doctorName,
      visitId: visitId,
      amount: amount,
      investmentType: investmentType,
      investmentDate: investmentDate,
      notes: notes,
      syncState: 'pending',
      provenanceSource: 'EXPLICIT_PROMOTIONAL_INVESTMENT',
      createdAt: DateTime.now(),
    );

    _localInvestments.insert(0, investment);

    try {
      final options = await _authOptions();
      final payload = {
        'doctor_id': doctorId,
        if (visitId != null && visitId.isNotEmpty) 'visit_id': visitId,
        'amount': amount,
        'investment_type': investmentType,
        'investment_date': investmentDate.toIso8601String().split('T').first,
        'notes': notes,
      };

      final response = await _dio.post(
        '/promotional-investments',
        data: payload,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final serverItem = PromotionalInvestmentModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        // Update local cache to synced
        _localInvestments.removeWhere((i) => i.id == localId);
        _localInvestments.insert(0, serverItem);
        return serverItem;
      }
    } catch (_) {
      // Network unavailable, remains pending in local cache
    }

    return investment;
  }
}
