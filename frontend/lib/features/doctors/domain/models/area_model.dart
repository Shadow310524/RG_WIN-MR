import 'package:rgwin_crm/core/storage/local_database.dart';

class AreaModel {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AreaModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'status': status,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LocalArea toLocal({String syncState = 'synced'}) {
    return LocalArea(
      id: id,
      name: name,
      code: code,
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

  factory AreaModel.fromLocal(LocalArea local) {
    return AreaModel(
      id: local.id,
      name: local.name,
      code: local.code,
      description: local.description,
      status: local.isActive ? 'ACTIVE' : 'ARCHIVED',
      isActive: local.isActive,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
    );
  }
}
