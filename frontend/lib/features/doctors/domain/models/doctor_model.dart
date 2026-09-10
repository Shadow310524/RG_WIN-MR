import 'package:rgwin_crm/core/storage/local_database.dart';

class DoctorModel {
  final String id;
  final String name;
  final String phone;
  final String? alternatePhone;
  final String? email;
  final String medicalLicenseNumber;
  final String specialization;
  final String? qualification;
  final String? clinicName;
  final String? address;
  final String areaId;
  final String? areaName;
  final String? associationId;
  final String? associationName;
  final String status;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.phone,
    this.alternatePhone,
    this.email,
    required this.medicalLicenseNumber,
    required this.specialization,
    this.qualification,
    this.clinicName,
    this.address,
    required this.areaId,
    this.areaName,
    this.associationId,
    this.associationName,
    required this.status,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncState = 'synced',
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      alternatePhone: json['alternate_phone'] as String?,
      email: json['email'] as String?,
      medicalLicenseNumber: json['medical_license_number'] as String,
      specialization: json['specialization'] as String,
      qualification: json['qualification'] as String?,
      clinicName: json['clinic_name'] as String?,
      address: json['address'] as String?,
      areaId: json['area_id'] as String,
      areaName: json['area_name'] as String?,
      associationId: json['association_id'] as String?,
      associationName: json['association_name'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncState: 'synced',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'alternate_phone': alternatePhone,
      'email': email,
      'medical_license_number': medicalLicenseNumber,
      'specialization': specialization,
      'qualification': qualification,
      'clinic_name': clinicName,
      'address': address,
      'area_id': areaId,
      'area_name': areaName,
      'association_id': associationId,
      'association_name': associationName,
      'status': status,
      'is_active': isActive,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LocalDoctor toLocal({String? state}) {
    return LocalDoctor(
      id: id,
      name: name,
      normalizedPhone: phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), ''),
      phone: phone,
      alternatePhone: alternatePhone,
      email: email,
      medicalLicenseNumber: medicalLicenseNumber,
      specialization: specialization,
      qualification: qualification,
      clinicName: clinicName,
      address: address,
      areaId: areaId,
      areaName: areaName,
      associationId: associationId,
      associationName: associationName,
      isActive: isActive,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncState: state ?? syncState,
      lastSyncedAt: DateTime.now(),
      serverUpdatedAt: updatedAt,
      localUpdatedAt: DateTime.now(),
    );
  }

  factory DoctorModel.fromLocal(LocalDoctor local) {
    return DoctorModel(
      id: local.id,
      name: local.name,
      phone: local.phone,
      alternatePhone: local.alternatePhone,
      email: local.email,
      medicalLicenseNumber: local.medicalLicenseNumber,
      specialization: local.specialization,
      qualification: local.qualification,
      clinicName: local.clinicName,
      address: local.address,
      areaId: local.areaId,
      areaName: local.areaName,
      associationId: local.associationId,
      associationName: local.associationName,
      status: local.isActive ? 'ACTIVE' : 'INACTIVE',
      isActive: local.isActive,
      notes: local.notes,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      syncState: local.syncState,
    );
  }

  DoctorModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? alternatePhone,
    String? email,
    String? medicalLicenseNumber,
    String? specialization,
    String? qualification,
    String? clinicName,
    String? address,
    String? areaId,
    String? areaName,
    String? associationId,
    String? associationName,
    String? status,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      email: email ?? this.email,
      medicalLicenseNumber: medicalLicenseNumber ?? this.medicalLicenseNumber,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      clinicName: clinicName ?? this.clinicName,
      address: address ?? this.address,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      associationId: associationId ?? this.associationId,
      associationName: associationName ?? this.associationName,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
    );
  }
}
