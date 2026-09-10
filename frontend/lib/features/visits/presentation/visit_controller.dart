import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/network/dio_client.dart';
import 'package:rgwin_crm/core/storage/secure_storage.dart';
import 'package:rgwin_crm/features/visits/domain/models/visit_model.dart';

class VisitState {
  final List<VisitModel> visits;
  final bool isLoading;
  final String? errorMessage;
  final String activeFilter; // "ALL", "TODAY", "UPCOMING", "COMPLETED"

  const VisitState({
    this.visits = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeFilter = "ALL",
  });

  List<VisitModel> get todayVisits {
    final now = DateTime.now();
    return visits.where((v) {
      return v.visitDatetime.year == now.year &&
          v.visitDatetime.month == now.month &&
          v.visitDatetime.day == now.day;
    }).toList();
  }

  List<VisitModel> get filteredVisits {
    final now = DateTime.now();
    switch (activeFilter) {
      case "TODAY":
        return todayVisits;
      case "UPCOMING":
        return visits
            .where(
              (v) => v.status == "UPCOMING" || v.visitDatetime.isAfter(now),
            )
            .toList();
      case "COMPLETED":
        return visits.where((v) => v.status == "COMPLETED").toList();
      default:
        return visits;
    }
  }

  VisitState copyWith({
    List<VisitModel>? visits,
    bool? isLoading,
    String? errorMessage,
    String? activeFilter,
  }) {
    return VisitState(
      visits: visits ?? this.visits,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class VisitController extends Notifier<VisitState> {
  final Dio _dio = DioClient().dio;
  final SecureStorageService _storage = SecureStorageService();

  @override
  VisitState build() {
    Future.microtask(() => loadVisits());
    return const VisitState(isLoading: true);
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<Options> _authOptions() async {
    final token = await _storage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<void> loadVisits({String? doctorId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final options = await _authOptions();
      final response = await _dio.get(
        '/visits',
        queryParameters: doctorId != null ? {'doctor_id': doctorId} : null,
        options: options,
      );
      final data = response.data;
      if (data is List) {
        final serverVisits = data.map((json) {
          return VisitModel(
            id: json['id'] as String,
            doctorId: json['doctor_id'] as String,
            doctorName: json['doctor_name'] as String?,
            clinicName: json['clinic_name'] as String?,
            specialization: json['specialization'] as String?,
            visitDatetime:
                DateTime.tryParse(json['visit_datetime'] as String? ?? '') ??
                DateTime.now(),
            visitType: json['visit_type'] as String? ?? 'ROUTINE',
            doctorResponse: json['doctor_response'] as String? ?? 'POSITIVE',
            prescriptionPotential:
                json['prescription_potential'] as String? ?? 'MEDIUM',
            discussedProducts: json['discussed_products'] as String?,
            samplesGiven: json['samples_given'] as String?,
            notes: json['notes'] as String?,
            status: json['status'] as String? ?? 'COMPLETED',
            syncStatus: 'SYNCED',
          );
        }).toList();

        state = state.copyWith(visits: serverVisits, isLoading: false);
        return;
      }
    } catch (_) {
      // Offline fallback: use local state
    }
    state = state.copyWith(isLoading: false);
  }

  Future<bool> recordVisit({
    required String doctorId,
    required String? doctorName,
    required String? clinicName,
    required String? specialization,
    required DateTime visitDatetime,
    required String doctorResponse,
    required String? discussedProducts,
    required String? samplesGiven,
    required bool purchaseOpportunity,
    required bool followUpRequired,
    required DateTime? followUpDate,
    required String? notes,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final newVisit = VisitModel(
      id: "vst_${DateTime.now().millisecondsSinceEpoch}",
      doctorId: doctorId,
      doctorName: doctorName,
      clinicName: clinicName,
      specialization: specialization,
      visitDatetime: visitDatetime,
      doctorResponse: doctorResponse,
      discussedProducts: discussedProducts,
      samplesGiven: samplesGiven,
      purchaseOpportunity: purchaseOpportunity,
      followUpRequired: followUpRequired,
      followUpDate: followUpDate,
      notes: notes,
      status: visitDatetime.isAfter(DateTime.now()) ? "UPCOMING" : "COMPLETED",
      syncStatus: "PENDING",
    );

    try {
      final options = await _authOptions();
      await _dio.post(
        '/visits',
        data: {
          'doctor_id': doctorId,
          'visit_datetime': visitDatetime.toIso8601String(),
          'doctor_response': doctorResponse,
          'notes': notes,
          'purchase_opportunity': purchaseOpportunity,
        },
        options: options,
      );
    } catch (_) {
      // Retained in local memory/Drift when offline
    }

    state = state.copyWith(
      visits: [newVisit, ...state.visits],
      isLoading: false,
    );
    return true;
  }
}

final visitControllerProvider = NotifierProvider<VisitController, VisitState>(
  () {
    return VisitController();
  },
);
