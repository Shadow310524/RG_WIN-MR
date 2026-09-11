import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/network/dio_client.dart';
import 'package:rgwin_crm/core/storage/secure_storage.dart';
import 'package:rgwin_crm/core/utils/numeric_utils.dart';
import 'package:rgwin_crm/features/sales/domain/models/purchase_model.dart';
import 'package:rgwin_crm/features/sales/domain/pts_calculation_service.dart';

class PurchaseRepository {
  final Dio _dio;
  final SecureStorageService _storage;
  // Local cache of purchases
  final List<PurchaseModel> _localPurchases = [];

  PurchaseRepository({Dio? dio, SecureStorageService? storage})
    : _dio = dio ?? DioClient().dio,
      _storage = storage ?? SecureStorageService();

  Future<Options> _authOptions() async {
    final token = await _storage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<PurchaseModel>> getPurchases({String? doctorId}) async {
    try {
      final options = await _authOptions();
      final response = await _dio.get(
        '/sales',
        queryParameters: doctorId != null ? {'doctor_id': doctorId} : null,
        options: options,
      );
      final data = response.data;
      final List rawItems = data is List
          ? data
          : (data is Map && data['items'] is List ? data['items'] as List : []);

      if (rawItems.isNotEmpty || data is Map || data is List) {
        final serverPurchases = rawItems.map((raw) {
          final json = asStringKeyedMap(raw);
          final amt = parseDouble(json['total_amount']);
          return PurchaseModel(
            id: json['id']?.toString() ?? '',
            doctorId: json['doctor_id']?.toString(),
            doctorName: json['doctor_name'] as String?,
            clinicName: json['clinic_name'] as String?,
            purchaseDate:
                DateTime.tryParse(json['sale_date']?.toString() ?? '') ??
                DateTime.now(),
            purchaseAmount: amt,
            gstAmount: parseDouble(json['gst_amount']),
            totalAmount: amt,
            ptsRate: parseDoubleOrNull(json['pts_rate']),
            ptsValue: parseDoubleOrNull(json['pts_value']),
            status: json['status'] as String? ?? 'CONFIRMED',
            syncState: 'synced',
            createdAt:
                DateTime.tryParse(json['created_at']?.toString() ?? '') ??
                DateTime.now(),
          );
        }).toList();

        // Merge with local purchases not yet synced
        final all = [
          ..._localPurchases.where((l) => l.syncState != 'synced'),
          ...serverPurchases,
        ];
        return all;
      }
    } catch (_) {
      // Offline fallback: return local purchases
    }
    return _localPurchases;
  }

  Future<PurchaseModel> recordPurchase({
    required String? doctorId,
    required String? doctorName,
    required String? clinicName,
    required DateTime purchaseDate,
    required double purchaseAmount,
    required double gstAmount,
    required String? notes,
  }) async {
    final total = purchaseAmount + gstAmount;
    final ptsResult = PtsCalculationService.calculate(
      purchaseAmount: purchaseAmount,
      gstAmount: gstAmount,
    );

    final newPurchase = PurchaseModel(
      id: "pch_${DateTime.now().millisecondsSinceEpoch}",
      doctorId: doctorId,
      doctorName: doctorName,
      clinicName: clinicName,
      purchaseDate: purchaseDate,
      purchaseAmount: purchaseAmount,
      gstAmount: gstAmount,
      totalAmount: total,
      ptsRate: ptsResult.rate,
      ptsValue: ptsResult.value,
      notes: notes,
      status: "CONFIRMED",
      syncState: "pending_create",
      createdAt: DateTime.now(),
    );

    _localPurchases.insert(0, newPurchase);

    try {
      final options = await _authOptions();
      final response = await _dio.post(
        '/sales',
        data: {
          'doctor_id': doctorId,
          'sale_date': purchaseDate.toIso8601String().split('T').first,
          'total_amount': total,
        },
        options: options,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Updated with server ID and synced state
        final serverId = response.data['id'] as String?;
        if (serverId != null) {
          final index = _localPurchases.indexOf(newPurchase);
          if (index != -1) {
            _localPurchases[index] = PurchaseModel(
              id: serverId,
              doctorId: doctorId,
              doctorName: doctorName,
              clinicName: clinicName,
              purchaseDate: purchaseDate,
              purchaseAmount: purchaseAmount,
              gstAmount: gstAmount,
              totalAmount: total,
              ptsRate: ptsResult.rate,
              ptsValue: ptsResult.value,
              notes: notes,
              status: "CONFIRMED",
              syncState: "synced",
              createdAt: newPurchase.createdAt,
            );
            return _localPurchases[index];
          }
        }
      }
    } catch (_) {
      // Retained in local storage as pending_create
    }

    return newPurchase;
  }
}

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepository();
});
