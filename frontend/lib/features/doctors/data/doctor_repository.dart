import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/storage/local_database.dart';
import 'package:rgwin_crm/features/doctors/data/doctor_api_service.dart';
import 'package:rgwin_crm/features/doctors/domain/models/area_model.dart';
import 'package:rgwin_crm/features/doctors/domain/models/association_model.dart';
import 'package:rgwin_crm/features/doctors/domain/models/doctor_model.dart';
import 'package:uuid/uuid.dart';

class DoctorListResult {
  final List<DoctorModel> doctors;
  final int total;
  final bool isOffline;

  const DoctorListResult({
    required this.doctors,
    required this.total,
    required this.isOffline,
  });
}

class DoctorRepository {
  final DoctorApiService _apiService;
  final AppDatabase db;

  DoctorRepository({DoctorApiService? apiService, required this.db})
    : _apiService = apiService ?? DoctorApiService();

  // --- Areas ---
  Future<List<AreaModel>> getAreas({bool? isActive}) async {
    try {
      final remoteAreas = await _apiService.fetchAreas(isActive: isActive);
      // Cache locally
      await db.upsertAreas(remoteAreas.map((a) => a.toLocal()).toList());
      return remoteAreas;
    } catch (_) {
      // Offline fallback: load from Drift
      final local = await db.getAllAreas(activeOnly: isActive);
      return local.map((l) => AreaModel.fromLocal(l)).toList();
    }
  }

  // --- Associations ---
  Future<List<AssociationModel>> getAssociations({bool? isActive}) async {
    try {
      final remoteAssocs = await _apiService.fetchAssociations(
        isActive: isActive,
      );
      // Cache locally
      await db.upsertAssociations(
        remoteAssocs.map((a) => a.toLocal()).toList(),
      );
      return remoteAssocs;
    } catch (_) {
      // Offline fallback: load from Drift
      final local = await db.getAllAssociations(activeOnly: isActive);
      return local.map((l) => AssociationModel.fromLocal(l)).toList();
    }
  }

  // --- Doctors Listing with Search and Filters ---
  Future<DoctorListResult> getDoctors({
    String? areaId,
    String? associationId,
    String? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final res = await _apiService.fetchDoctors(
        areaId: areaId,
        associationId: associationId,
        status: status,
        search: search,
        page: page,
        pageSize: pageSize,
      );

      final List<DoctorModel> remoteDoctors = res['items'] as List<DoctorModel>;
      final int total = res['total'] as int;

      // Cache doctors into Drift local database without overwriting pending local edits
      await db.upsertDoctors(
        remoteDoctors.map((d) => d.toLocal(state: 'synced')).toList(),
      );

      return DoctorListResult(
        doctors: remoteDoctors,
        total: total,
        isOffline: false,
      );
    } catch (_) {
      // Offline fallback: query Drift local database
      final bool? activeOnly = status == 'ACTIVE' ? true : null;
      final localDoctors = await db.getDoctors(
        areaId: areaId,
        associationId: associationId,
        activeOnly: activeOnly,
        searchQuery: search,
        limit: pageSize,
        offset: (page - 1) * pageSize,
      );

      final total = await db.countDoctors(
        areaId: areaId,
        associationId: associationId,
        activeOnly: activeOnly,
        searchQuery: search,
      );

      return DoctorListResult(
        doctors: localDoctors.map((l) => DoctorModel.fromLocal(l)).toList(),
        total: total,
        isOffline: true,
      );
    }
  }

  // --- Single Doctor Details ---
  Future<DoctorModel> getDoctorById(String id) async {
    try {
      final remote = await _apiService.getDoctorById(id);
      await db.saveLocalDoctor(remote.toLocal(state: 'synced'));
      return remote;
    } catch (_) {
      final local = await db.getDoctorById(id);
      if (local != null) {
        return DoctorModel.fromLocal(local);
      }
      rethrow;
    }
  }

  // --- Duplicate Check Pre-Flight ---
  Future<Map<String, dynamic>> checkDuplicate({
    String? phone,
    String? medicalLicenseNumber,
    String? excludeDoctorId,
  }) async {
    try {
      return await _apiService.checkDuplicate(
        phone: phone,
        medicalLicenseNumber: medicalLicenseNumber,
        excludeDoctorId: excludeDoctorId,
      );
    } catch (_) {
      // When offline, duplicate pre-flight passes locally; server will validate upon sync
      return {'is_duplicate': false};
    }
  }

  // --- Create Doctor ---
  Future<DoctorModel> createDoctor(Map<String, dynamic> payload) async {
    try {
      final created = await _apiService.createDoctor(payload);
      await db.saveLocalDoctor(created.toLocal(state: 'synced'));
      return created;
    } on DuplicateDoctorException {
      rethrow;
    } catch (_) {
      // Network failure / Offline: persist locally with pendingCreate status
      final offlineId = const Uuid().v4();
      final now = DateTime.now();

      final offlineDoctor = DoctorModel(
        id: offlineId,
        name: payload['name'] as String,
        phone: payload['phone'] as String,
        alternatePhone: payload['alternate_phone'] as String?,
        email: payload['email'] as String?,
        medicalLicenseNumber: payload['medical_license_number'] as String,
        specialization: payload['specialization'] as String,
        qualification: payload['qualification'] as String?,
        clinicName: payload['clinic_name'] as String?,
        address: payload['address'] as String?,
        areaId: payload['area_id'] as String,
        associationId: payload['association_id'] as String?,
        status: 'ACTIVE',
        isActive: true,
        notes: payload['notes'] as String?,
        createdAt: now,
        updatedAt: now,
        syncState: 'pendingCreate',
      );

      await db.saveLocalDoctor(offlineDoctor.toLocal(state: 'pendingCreate'));
      return offlineDoctor;
    }
  }

  // --- Update Doctor ---
  Future<DoctorModel> updateDoctor(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final updated = await _apiService.updateDoctor(id, payload);
      await db.saveLocalDoctor(updated.toLocal(state: 'synced'));
      return updated;
    } on DuplicateDoctorException {
      rethrow;
    } catch (_) {
      // Offline: update local doctor record with pendingUpdate
      final local = await db.getDoctorById(id);
      if (local != null) {
        final existing = DoctorModel.fromLocal(local);
        final modified = existing.copyWith(
          name: payload['name'] as String?,
          phone: payload['phone'] as String?,
          alternatePhone: payload['alternate_phone'] as String?,
          email: payload['email'] as String?,
          medicalLicenseNumber: payload['medical_license_number'] as String?,
          specialization: payload['specialization'] as String?,
          qualification: payload['qualification'] as String?,
          clinicName: payload['clinic_name'] as String?,
          address: payload['address'] as String?,
          areaId: payload['area_id'] as String?,
          associationId: payload['association_id'] as String?,
          notes: payload['notes'] as String?,
          updatedAt: DateTime.now(),
          syncState: 'pendingUpdate',
        );
        await db.saveLocalDoctor(modified.toLocal(state: 'pendingUpdate'));
        return modified;
      }
      rethrow;
    }
  }

  // --- Status Update ---
  Future<DoctorModel> setDoctorStatus(String id, String status) async {
    try {
      final updated = await _apiService.setDoctorStatus(id, status);
      await db.saveLocalDoctor(updated.toLocal(state: 'synced'));
      return updated;
    } catch (_) {
      final local = await db.getDoctorById(id);
      if (local != null) {
        final existing = DoctorModel.fromLocal(local);
        final modified = existing.copyWith(
          status: status,
          isActive: status == 'ACTIVE',
          updatedAt: DateTime.now(),
          syncState: 'pendingUpdate',
        );
        await db.saveLocalDoctor(modified.toLocal(state: 'pendingUpdate'));
        return modified;
      }
      rethrow;
    }
  }
}

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  final db = ref.watch(localDatabaseProvider);
  return DoctorRepository(db: db);
});
