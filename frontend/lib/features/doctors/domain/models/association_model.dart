import 'package:rgwin_crm/core/storage/local_database.dart';

class AssociationModel {
  final String id;
  final String name;
  final String? code;
  final String? shortName;
  final String? description;
  final String status;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssociationModel({
    required this.id,
    required this.name,
    this.code,
    this.shortName,
    this.description,
    required this.status,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssociationModel.fromJson(Map<String, dynamic> json) {
    return AssociationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      shortName: json['short_name'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'short_name': shortName,
      'description': description,
      'status': status,
      'is_active': isActive,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LocalAssociation toLocal({String syncState = 'synced'}) {
    return LocalAssociation(
      id: id,
      name: name,
      code: code ?? shortName,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncState: syncState,
      lastSyncedAt: DateTime.now(),
      serverUpdatedAt: updatedAt,
      localUpdatedAt: DateTime.now(),
    );
  }

  factory AssociationModel.fromLocal(LocalAssociation local) {
    return AssociationModel(
      id: local.id,
      name: local.name,
      code: local.code,
      shortName: local.code,
      description: local.description,
      status: local.isActive ? 'ACTIVE' : 'ARCHIVED',
      isActive: local.isActive,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
    );
  }
}
