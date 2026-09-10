import 'package:dio/dio.dart';
import 'package:rgwin_crm/core/config/app_config.dart';
import 'package:rgwin_crm/core/network/dio_client.dart';
import 'package:rgwin_crm/core/storage/secure_storage.dart';
import 'package:rgwin_crm/features/doctors/domain/models/area_model.dart';
import 'package:rgwin_crm/features/doctors/domain/models/association_model.dart';
import 'package:rgwin_crm/features/doctors/domain/models/doctor_model.dart';

class DuplicateDoctorException implements Exception {
  final String message;
  final String? field;
  final String? existingDoctorId;
  final String? existingDoctorName;

  DuplicateDoctorException({
    required this.message,
    this.field,
    this.existingDoctorId,
    this.existingDoctorName,
  });

  @override
  String toString() => message;
}

class DoctorApiService {
  final Dio _dio;
  final SecureStorageService _storage;

  DoctorApiService({Dio? dio, SecureStorageService? storage})
    : _dio = dio ?? DioClient().dio,
      _storage = storage ?? SecureStorageService();

  Future<Options> _authOptions() async {
    final token = await _storage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<AreaModel>> fetchAreas({bool? isActive}) async {
    final options = await _authOptions();
    final response = await _dio.get(
      ApiEndpoints.areas,
      queryParameters: {'is_active': ?isActive, 'limit': 100},
      options: options,
    );

    final list = response.data as List<dynamic>;
    return list
        .map((e) => AreaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AssociationModel>> fetchAssociations({bool? isActive}) async {
    final options = await _authOptions();
    final response = await _dio.get(
      ApiEndpoints.associations,
      queryParameters: {'is_active': ?isActive, 'limit': 100},
      options: options,
    );

    final list = response.data as List<dynamic>;
    return list
        .map((e) => AssociationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> fetchDoctors({
    String? areaId,
    String? associationId,
    String? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final options = await _authOptions();
    final response = await _dio.get(
      ApiEndpoints.doctors,
      queryParameters: {
        if (areaId != null && areaId.isNotEmpty) 'area_id': areaId,
        if (associationId != null && associationId.isNotEmpty)
          'association_id': associationId,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'page_size': pageSize,
      },
      options: options,
    );

    final data = response.data as Map<String, dynamic>;
    final itemsJson = data['items'] as List<dynamic>;
    final items = itemsJson
        .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return {
      'items': items,
      'total': data['total'] as int? ?? items.length,
      'page': data['page'] as int? ?? page,
      'pageSize': data['page_size'] as int? ?? pageSize,
      'totalPages': data['total_pages'] as int? ?? 1,
    };
  }

  Future<DoctorModel> getDoctorById(String id) async {
    final options = await _authOptions();
    final response = await _dio.get(
      '${ApiEndpoints.doctors}/$id',
      options: options,
    );
    return DoctorModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DoctorModel> createDoctor(Map<String, dynamic> payload) async {
    try {
      final options = await _authOptions();
      final response = await _dio.post(
        ApiEndpoints.doctors,
        data: payload,
        options: options,
      );
      return DoctorModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final error = e.response?.data?['error'] as Map<String, dynamic>?;
        final details = error?['details'] as Map<String, dynamic>?;
        throw DuplicateDoctorException(
          message:
              error?['message'] as String? ??
              'Doctor with these credentials already exists.',
          field: details?['field'] as String?,
          existingDoctorId: details?['existing_doctor_id'] as String?,
          existingDoctorName: details?['existing_doctor_name'] as String?,
        );
      }
      rethrow;
    }
  }

  Future<DoctorModel> updateDoctor(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final options = await _authOptions();
      final response = await _dio.put(
        '${ApiEndpoints.doctors}/$id',
        data: payload,
        options: options,
      );
      return DoctorModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final error = e.response?.data?['error'] as Map<String, dynamic>?;
        final details = error?['details'] as Map<String, dynamic>?;
        throw DuplicateDoctorException(
          message:
              error?['message'] as String? ??
              'Doctor with these credentials already exists.',
          field: details?['field'] as String?,
          existingDoctorId: details?['existing_doctor_id'] as String?,
          existingDoctorName: details?['existing_doctor_name'] as String?,
        );
      }
      rethrow;
    }
  }

  Future<DoctorModel> setDoctorStatus(String id, String status) async {
    final options = await _authOptions();
    final response = await _dio.patch(
      '${ApiEndpoints.doctors}/$id/status',
      data: {'status': status},
      options: options,
    );
    return DoctorModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> checkDuplicate({
    String? phone,
    String? medicalLicenseNumber,
    String? excludeDoctorId,
  }) async {
    final options = await _authOptions();
    final response = await _dio.post(
      ApiEndpoints.checkDoctorDuplicate,
      data: {
        'phone': ?phone,
        'medical_license_number': ?medicalLicenseNumber,
        'exclude_doctor_id': ?excludeDoctorId,
      },
      options: options,
    );
    return response.data as Map<String, dynamic>;
  }
}
