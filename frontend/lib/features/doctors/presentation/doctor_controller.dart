import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/features/doctors/data/doctor_api_service.dart';
import 'package:rgwin_crm/features/doctors/data/doctor_repository.dart';
import 'package:rgwin_crm/features/doctors/domain/models/area_model.dart';
import 'package:rgwin_crm/features/doctors/domain/models/association_model.dart';
import 'package:rgwin_crm/features/doctors/domain/models/doctor_model.dart';

class DoctorState {
  final bool isLoading;
  final bool isOffline;
  final List<DoctorModel> doctors;
  final int total;
  final int page;
  final int pageSize;
  final String searchQuery;
  final String? selectedAreaId;
  final String? selectedAssociationId;
  final String? selectedStatus;
  final List<AreaModel> areas;
  final List<AssociationModel> associations;
  final String? errorMessage;
  final String? duplicateWarning;
  final bool isSaving;

  const DoctorState({
    this.isLoading = false,
    this.isOffline = false,
    this.doctors = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.searchQuery = '',
    this.selectedAreaId,
    this.selectedAssociationId,
    this.selectedStatus,
    this.areas = const [],
    this.associations = const [],
    this.errorMessage,
    this.duplicateWarning,
    this.isSaving = false,
  });

  DoctorState copyWith({
    bool? isLoading,
    bool? isOffline,
    List<DoctorModel>? doctors,
    int? total,
    int? page,
    int? pageSize,
    String? searchQuery,
    String? selectedAreaId,
    bool clearArea = false,
    String? selectedAssociationId,
    bool clearAssociation = false,
    String? selectedStatus,
    bool clearStatus = false,
    List<AreaModel>? areas,
    List<AssociationModel>? associations,
    String? errorMessage,
    bool clearError = false,
    String? duplicateWarning,
    bool clearDuplicateWarning = false,
    bool? isSaving,
  }) {
    return DoctorState(
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
      doctors: doctors ?? this.doctors,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedAreaId: clearArea
          ? null
          : (selectedAreaId ?? this.selectedAreaId),
      selectedAssociationId: clearAssociation
          ? null
          : (selectedAssociationId ?? this.selectedAssociationId),
      selectedStatus: clearStatus
          ? null
          : (selectedStatus ?? this.selectedStatus),
      areas: areas ?? this.areas,
      associations: associations ?? this.associations,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      duplicateWarning: clearDuplicateWarning
          ? null
          : (duplicateWarning ?? this.duplicateWarning),
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class DoctorController extends Notifier<DoctorState> {
  late final DoctorRepository _repo;

  @override
  DoctorState build() {
    _repo = ref.watch(doctorRepositoryProvider);
    // Automatically trigger initial fetch
    Future.microtask(() => loadInitialData());
    return const DoctorState(isLoading: true);
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final areas = await _repo.getAreas(isActive: true);
      final assocs = await _repo.getAssociations(isActive: true);
      final result = await _repo.getDoctors(
        page: 1,
        pageSize: state.pageSize,
        status: state.selectedStatus,
      );

      state = state.copyWith(
        isLoading: false,
        areas: areas,
        associations: assocs,
        doctors: result.doctors,
        total: result.total,
        isOffline: result.isOffline,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadDoctors({int? page}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final targetPage = page ?? state.page;
      final result = await _repo.getDoctors(
        areaId: state.selectedAreaId,
        associationId: state.selectedAssociationId,
        status: state.selectedStatus,
        search: state.searchQuery,
        page: targetPage,
        pageSize: state.pageSize,
      );

      state = state.copyWith(
        isLoading: false,
        doctors: result.doctors,
        total: result.total,
        page: targetPage,
        isOffline: result.isOffline,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query, page: 1);
    loadDoctors(page: 1);
  }

  void setAreaFilter(String? areaId) {
    if (areaId == state.selectedAreaId) return;
    state = state.copyWith(
      selectedAreaId: areaId,
      clearArea: areaId == null,
      page: 1,
    );
    loadDoctors(page: 1);
  }

  void setAssociationFilter(String? assocId) {
    if (assocId == state.selectedAssociationId) return;
    state = state.copyWith(
      selectedAssociationId: assocId,
      clearAssociation: assocId == null,
      page: 1,
    );
    loadDoctors(page: 1);
  }

  void setStatusFilter(String? status) {
    if (status == state.selectedStatus) return;
    state = state.copyWith(
      selectedStatus: status,
      clearStatus: status == null,
      page: 1,
    );
    loadDoctors(page: 1);
  }

  Future<DoctorModel?> createDoctor(Map<String, dynamic> data) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearDuplicateWarning: true,
    );
    try {
      final created = await _repo.createDoctor(data);
      state = state.copyWith(isSaving: false);
      await loadDoctors();
      return created;
    } on DuplicateDoctorException catch (e) {
      state = state.copyWith(isSaving: false, duplicateWarning: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<DoctorModel?> updateDoctor(
    String id,
    Map<String, dynamic> data,
  ) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearDuplicateWarning: true,
    );
    try {
      final updated = await _repo.updateDoctor(id, data);
      state = state.copyWith(isSaving: false);
      await loadDoctors();
      return updated;
    } on DuplicateDoctorException catch (e) {
      state = state.copyWith(isSaving: false, duplicateWarning: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<void> setDoctorStatus(String id, String status) async {
    try {
      await _repo.setDoctorStatus(id, status);
      await loadDoctors();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<Map<String, dynamic>> checkDuplicate({
    String? phone,
    String? medicalLicenseNumber,
    String? excludeDoctorId,
  }) {
    return _repo.checkDuplicate(
      phone: phone,
      medicalLicenseNumber: medicalLicenseNumber,
      excludeDoctorId: excludeDoctorId,
    );
  }
}

final doctorControllerProvider =
    NotifierProvider<DoctorController, DoctorState>(() {
      return DoctorController();
    });
