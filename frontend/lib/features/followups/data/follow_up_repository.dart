import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/network/dio_client.dart';
import 'package:rgwin_crm/core/storage/secure_storage.dart';
import 'package:rgwin_crm/features/followups/domain/models/follow_up_model.dart';

class FollowUpRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  // Local state cache for offline resilience
  final List<FollowUpModel> _localFollowUps = [
    FollowUpModel(
      id: "fu_seed_1",
      doctorId: "doc_1",
      doctorName: "Dr. Ravi Kumar",
      clinicName: "ABC Medicals",
      dueDate: DateTime.now(),
      taskReason: "Follow up on purchase requirement",
      status: "PENDING",
      syncStatus: "SYNCED",
    ),
    FollowUpModel(
      id: "fu_seed_2",
      doctorId: "doc_2",
      doctorName: "Dr. Priya Sharma",
      clinicName: "City Heart Care",
      dueDate: DateTime.now().add(const Duration(days: 1)),
      taskReason: "Follow up on prescription discussion",
      status: "PENDING",
      syncStatus: "SYNCED",
    ),
    FollowUpModel(
      id: "fu_seed_3",
      doctorId: "doc_3",
      doctorName: "Dr. Anil Mehta",
      clinicName: "Apollo Clinic",
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      taskReason: "Sample trial feedback for Healix-500",
      status: "COMPLETED",
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
      syncStatus: "SYNCED",
    ),
  ];

  FollowUpRepository({Dio? dio, SecureStorageService? storage})
    : _dio = dio ?? DioClient().dio,
      _storage = storage ?? SecureStorageService();

  Future<Options> _authOptions() async {
    final token = await _storage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<FollowUpModel>> getFollowUps({
    String? doctorId,
    String? status,
  }) async {
    try {
      final options = await _authOptions();
      final queryParams = <String, dynamic>{};
      if (doctorId != null && doctorId.isNotEmpty) {
        queryParams['doctor_id'] = doctorId;
      }
      if (status != null && status.isNotEmpty && status != "ALL") {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/follow-ups',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: options,
      );

      final data = response.data;
      if (data is Map && data['items'] is List) {
        final serverList = (data['items'] as List).map((json) {
          return FollowUpModel(
            id: json['id'] as String,
            doctorId: json['doctor_id'] as String,
            doctorName: json['doctor_name'] as String?,
            clinicName: json['clinic_name'] as String?,
            visitId: json['visit_id'] as String?,
            dueDate:
                DateTime.tryParse(json['due_date'] as String? ?? '') ??
                DateTime.now(),
            taskReason: json['notes'] as String? ?? "Follow-up discussion",
            status: json['status'] as String? ?? "PENDING",
            completedAt: json['completed_at'] != null
                ? DateTime.tryParse(json['completed_at'] as String)
                : null,
            syncStatus: "SYNCED",
          );
        }).toList();

        // Merge local pending items
        final localPending = _localFollowUps.where(
          (f) => f.syncStatus != "SYNCED",
        );
        final merged = [...localPending, ...serverList];

        // Apply filters
        var result = merged;
        if (doctorId != null && doctorId.isNotEmpty) {
          result = result.where((f) => f.doctorId == doctorId).toList();
        }
        if (status != null && status.isNotEmpty && status != "ALL") {
          result = result.where((f) => f.status == status).toList();
        }
        return result;
      }
    } catch (_) {
      // Offline fallback: return local in-memory follow-ups
    }

    var result = List<FollowUpModel>.from(_localFollowUps);
    if (doctorId != null && doctorId.isNotEmpty) {
      result = result.where((f) => f.doctorId == doctorId).toList();
    }
    if (status != null && status.isNotEmpty && status != "ALL") {
      result = result.where((f) => f.status == status).toList();
    }
    return result;
  }

  Future<FollowUpModel> createFollowUp({
    required String doctorId,
    String? doctorName,
    String? clinicName,
    String? visitId,
    required DateTime dueDate,
    required String taskReason,
  }) async {
    final newFollowUp = FollowUpModel(
      id: "fu_${DateTime.now().millisecondsSinceEpoch}",
      doctorId: doctorId,
      doctorName: doctorName,
      clinicName: clinicName,
      visitId: visitId,
      dueDate: dueDate,
      taskReason: taskReason,
      status: "PENDING",
      syncStatus: "PENDING",
    );

    _localFollowUps.insert(0, newFollowUp);

    try {
      final options = await _authOptions();
      final dateStr = dueDate.toIso8601String().split('T').first;
      final response = await _dio.post(
        '/follow-ups',
        data: {
          'doctor_id': doctorId,
          'visit_id': visitId,
          'due_date': dateStr,
          'notes': taskReason,
        },
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final serverId = response.data['id'] as String?;
        if (serverId != null) {
          final idx = _localFollowUps.indexOf(newFollowUp);
          if (idx != -1) {
            _localFollowUps[idx] = newFollowUp.copyWith(
              id: serverId,
              syncStatus: "SYNCED",
            );
            return _localFollowUps[idx];
          }
        }
      }
    } catch (_) {
      // Offline: remains in _localFollowUps as PENDING
    }

    return newFollowUp;
  }

  Future<FollowUpModel?> updateStatus({
    required String followUpId,
    required String newStatus,
  }) async {
    final idx = _localFollowUps.indexWhere((f) => f.id == followUpId);
    if (idx != -1) {
      _localFollowUps[idx] = _localFollowUps[idx].copyWith(
        status: newStatus,
        completedAt: newStatus == "COMPLETED" ? DateTime.now() : null,
      );
    }

    try {
      final options = await _authOptions();
      await _dio.patch(
        '/follow-ups/$followUpId/status',
        data: {'status': newStatus},
        options: options,
      );
    } catch (_) {
      // Retained in local cache
    }

    return idx != -1 ? _localFollowUps[idx] : null;
  }
}

final followUpRepositoryProvider = Provider<FollowUpRepository>((ref) {
  return FollowUpRepository();
});
