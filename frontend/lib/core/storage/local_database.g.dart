// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalAreasTable extends LocalAreas
    with TableInfo<$LocalAreasTable, LocalArea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    code,
    description,
    isActive,
    createdAt,
    updatedAt,
    syncState,
    lastSyncedAt,
    serverUpdatedAt,
    localUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_areas';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalArea> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalArea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalArea(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      ),
    );
  }

  @override
  $LocalAreasTable createAlias(String alias) {
    return $LocalAreasTable(attachedDatabase, alias);
  }
}

class LocalArea extends DataClass implements Insertable<LocalArea> {
  final String id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  final DateTime? lastSyncedAt;
  final DateTime? serverUpdatedAt;
  final DateTime? localUpdatedAt;
  const LocalArea({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    this.lastSyncedAt,
    this.serverUpdatedAt,
    this.localUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    if (!nullToAbsent || localUpdatedAt != null) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    }
    return map;
  }

  LocalAreasCompanion toCompanion(bool nullToAbsent) {
    return LocalAreasCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      localUpdatedAt: localUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(localUpdatedAt),
    );
  }

  factory LocalArea.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalArea(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      localUpdatedAt: serializer.fromJson<DateTime?>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'localUpdatedAt': serializer.toJson<DateTime?>(localUpdatedAt),
    };
  }

  LocalArea copyWith({
    String? id,
    String? name,
    String? code,
    Value<String?> description = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
    Value<DateTime?> localUpdatedAt = const Value.absent(),
  }) => LocalArea(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    description: description.present ? description.value : this.description,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    localUpdatedAt: localUpdatedAt.present
        ? localUpdatedAt.value
        : this.localUpdatedAt,
  );
  LocalArea copyWithCompanion(LocalAreasCompanion data) {
    return LocalArea(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      description: data.description.present
          ? data.description.value
          : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalArea(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    code,
    description,
    isActive,
    createdAt,
    updatedAt,
    syncState,
    lastSyncedAt,
    serverUpdatedAt,
    localUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalArea &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class LocalAreasCompanion extends UpdateCompanion<LocalArea> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> code;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<DateTime?> localUpdatedAt;
  final Value<int> rowid;
  const LocalAreasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAreasCompanion.insert({
    required String id,
    required String name,
    required String code,
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       code = Value(code),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalArea> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAreasCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? code,
    Value<String?>? description,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncState,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime?>? serverUpdatedAt,
    Value<DateTime?>? localUpdatedAt,
    Value<int>? rowid,
  }) {
    return LocalAreasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAreasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAssociationsTable extends LocalAssociations
    with TableInfo<$LocalAssociationsTable, LocalAssociation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssociationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    code,
    description,
    isActive,
    createdAt,
    updatedAt,
    syncState,
    lastSyncedAt,
    serverUpdatedAt,
    localUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_associations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssociation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAssociation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssociation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      ),
    );
  }

  @override
  $LocalAssociationsTable createAlias(String alias) {
    return $LocalAssociationsTable(attachedDatabase, alias);
  }
}

class LocalAssociation extends DataClass
    implements Insertable<LocalAssociation> {
  final String id;
  final String name;
  final String? code;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  final DateTime? lastSyncedAt;
  final DateTime? serverUpdatedAt;
  final DateTime? localUpdatedAt;
  const LocalAssociation({
    required this.id,
    required this.name,
    this.code,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    this.lastSyncedAt,
    this.serverUpdatedAt,
    this.localUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    if (!nullToAbsent || localUpdatedAt != null) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    }
    return map;
  }

  LocalAssociationsCompanion toCompanion(bool nullToAbsent) {
    return LocalAssociationsCompanion(
      id: Value(id),
      name: Value(name),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      localUpdatedAt: localUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(localUpdatedAt),
    );
  }

  factory LocalAssociation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssociation(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String?>(json['code']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      localUpdatedAt: serializer.fromJson<DateTime?>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String?>(code),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'localUpdatedAt': serializer.toJson<DateTime?>(localUpdatedAt),
    };
  }

  LocalAssociation copyWith({
    String? id,
    String? name,
    Value<String?> code = const Value.absent(),
    Value<String?> description = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
    Value<DateTime?> localUpdatedAt = const Value.absent(),
  }) => LocalAssociation(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code.present ? code.value : this.code,
    description: description.present ? description.value : this.description,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    localUpdatedAt: localUpdatedAt.present
        ? localUpdatedAt.value
        : this.localUpdatedAt,
  );
  LocalAssociation copyWithCompanion(LocalAssociationsCompanion data) {
    return LocalAssociation(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      description: data.description.present
          ? data.description.value
          : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssociation(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    code,
    description,
    isActive,
    createdAt,
    updatedAt,
    syncState,
    lastSyncedAt,
    serverUpdatedAt,
    localUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssociation &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class LocalAssociationsCompanion extends UpdateCompanion<LocalAssociation> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> code;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<DateTime?> localUpdatedAt;
  final Value<int> rowid;
  const LocalAssociationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssociationsCompanion.insert({
    required String id,
    required String name,
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalAssociation> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssociationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? code,
    Value<String?>? description,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncState,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime?>? serverUpdatedAt,
    Value<DateTime?>? localUpdatedAt,
    Value<int>? rowid,
  }) {
    return LocalAssociationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssociationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDoctorsTable extends LocalDoctors
    with TableInfo<$LocalDoctorsTable, LocalDoctor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDoctorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedPhoneMeta = const VerificationMeta(
    'normalizedPhone',
  );
  @override
  late final GeneratedColumn<String> normalizedPhone = GeneratedColumn<String>(
    'normalized_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alternatePhoneMeta = const VerificationMeta(
    'alternatePhone',
  );
  @override
  late final GeneratedColumn<String> alternatePhone = GeneratedColumn<String>(
    'alternate_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medicalLicenseNumberMeta =
      const VerificationMeta('medicalLicenseNumber');
  @override
  late final GeneratedColumn<String> medicalLicenseNumber =
      GeneratedColumn<String>(
        'medical_license_number',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _specializationMeta = const VerificationMeta(
    'specialization',
  );
  @override
  late final GeneratedColumn<String> specialization = GeneratedColumn<String>(
    'specialization',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qualificationMeta = const VerificationMeta(
    'qualification',
  );
  @override
  late final GeneratedColumn<String> qualification = GeneratedColumn<String>(
    'qualification',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicNameMeta = const VerificationMeta(
    'clinicName',
  );
  @override
  late final GeneratedColumn<String> clinicName = GeneratedColumn<String>(
    'clinic_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaNameMeta = const VerificationMeta(
    'areaName',
  );
  @override
  late final GeneratedColumn<String> areaName = GeneratedColumn<String>(
    'area_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _associationIdMeta = const VerificationMeta(
    'associationId',
  );
  @override
  late final GeneratedColumn<String> associationId = GeneratedColumn<String>(
    'association_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _associationNameMeta = const VerificationMeta(
    'associationName',
  );
  @override
  late final GeneratedColumn<String> associationName = GeneratedColumn<String>(
    'association_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    normalizedPhone,
    phone,
    alternatePhone,
    email,
    medicalLicenseNumber,
    specialization,
    qualification,
    clinicName,
    address,
    areaId,
    areaName,
    associationId,
    associationName,
    isActive,
    notes,
    createdAt,
    updatedAt,
    syncState,
    lastSyncedAt,
    serverUpdatedAt,
    localUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_doctors';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDoctor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_phone')) {
      context.handle(
        _normalizedPhoneMeta,
        normalizedPhone.isAcceptableOrUnknown(
          data['normalized_phone']!,
          _normalizedPhoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedPhoneMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('alternate_phone')) {
      context.handle(
        _alternatePhoneMeta,
        alternatePhone.isAcceptableOrUnknown(
          data['alternate_phone']!,
          _alternatePhoneMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('medical_license_number')) {
      context.handle(
        _medicalLicenseNumberMeta,
        medicalLicenseNumber.isAcceptableOrUnknown(
          data['medical_license_number']!,
          _medicalLicenseNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicalLicenseNumberMeta);
    }
    if (data.containsKey('specialization')) {
      context.handle(
        _specializationMeta,
        specialization.isAcceptableOrUnknown(
          data['specialization']!,
          _specializationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_specializationMeta);
    }
    if (data.containsKey('qualification')) {
      context.handle(
        _qualificationMeta,
        qualification.isAcceptableOrUnknown(
          data['qualification']!,
          _qualificationMeta,
        ),
      );
    }
    if (data.containsKey('clinic_name')) {
      context.handle(
        _clinicNameMeta,
        clinicName.isAcceptableOrUnknown(data['clinic_name']!, _clinicNameMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_areaIdMeta);
    }
    if (data.containsKey('area_name')) {
      context.handle(
        _areaNameMeta,
        areaName.isAcceptableOrUnknown(data['area_name']!, _areaNameMeta),
      );
    }
    if (data.containsKey('association_id')) {
      context.handle(
        _associationIdMeta,
        associationId.isAcceptableOrUnknown(
          data['association_id']!,
          _associationIdMeta,
        ),
      );
    }
    if (data.containsKey('association_name')) {
      context.handle(
        _associationNameMeta,
        associationName.isAcceptableOrUnknown(
          data['association_name']!,
          _associationNameMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDoctor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDoctor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_phone'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      alternatePhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternate_phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      medicalLicenseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medical_license_number'],
      )!,
      specialization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialization'],
      )!,
      qualification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qualification'],
      ),
      clinicName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_name'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      )!,
      areaName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_name'],
      ),
      associationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}association_id'],
      ),
      associationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}association_name'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      ),
    );
  }

  @override
  $LocalDoctorsTable createAlias(String alias) {
    return $LocalDoctorsTable(attachedDatabase, alias);
  }
}

class LocalDoctor extends DataClass implements Insertable<LocalDoctor> {
  final String id;
  final String name;
  final String normalizedPhone;
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
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  final DateTime? lastSyncedAt;
  final DateTime? serverUpdatedAt;
  final DateTime? localUpdatedAt;
  const LocalDoctor({
    required this.id,
    required this.name,
    required this.normalizedPhone,
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
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    this.lastSyncedAt,
    this.serverUpdatedAt,
    this.localUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['normalized_phone'] = Variable<String>(normalizedPhone);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || alternatePhone != null) {
      map['alternate_phone'] = Variable<String>(alternatePhone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['medical_license_number'] = Variable<String>(medicalLicenseNumber);
    map['specialization'] = Variable<String>(specialization);
    if (!nullToAbsent || qualification != null) {
      map['qualification'] = Variable<String>(qualification);
    }
    if (!nullToAbsent || clinicName != null) {
      map['clinic_name'] = Variable<String>(clinicName);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['area_id'] = Variable<String>(areaId);
    if (!nullToAbsent || areaName != null) {
      map['area_name'] = Variable<String>(areaName);
    }
    if (!nullToAbsent || associationId != null) {
      map['association_id'] = Variable<String>(associationId);
    }
    if (!nullToAbsent || associationName != null) {
      map['association_name'] = Variable<String>(associationName);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    if (!nullToAbsent || localUpdatedAt != null) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    }
    return map;
  }

  LocalDoctorsCompanion toCompanion(bool nullToAbsent) {
    return LocalDoctorsCompanion(
      id: Value(id),
      name: Value(name),
      normalizedPhone: Value(normalizedPhone),
      phone: Value(phone),
      alternatePhone: alternatePhone == null && nullToAbsent
          ? const Value.absent()
          : Value(alternatePhone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      medicalLicenseNumber: Value(medicalLicenseNumber),
      specialization: Value(specialization),
      qualification: qualification == null && nullToAbsent
          ? const Value.absent()
          : Value(qualification),
      clinicName: clinicName == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicName),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      areaId: Value(areaId),
      areaName: areaName == null && nullToAbsent
          ? const Value.absent()
          : Value(areaName),
      associationId: associationId == null && nullToAbsent
          ? const Value.absent()
          : Value(associationId),
      associationName: associationName == null && nullToAbsent
          ? const Value.absent()
          : Value(associationName),
      isActive: Value(isActive),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      localUpdatedAt: localUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(localUpdatedAt),
    );
  }

  factory LocalDoctor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDoctor(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedPhone: serializer.fromJson<String>(json['normalizedPhone']),
      phone: serializer.fromJson<String>(json['phone']),
      alternatePhone: serializer.fromJson<String?>(json['alternatePhone']),
      email: serializer.fromJson<String?>(json['email']),
      medicalLicenseNumber: serializer.fromJson<String>(
        json['medicalLicenseNumber'],
      ),
      specialization: serializer.fromJson<String>(json['specialization']),
      qualification: serializer.fromJson<String?>(json['qualification']),
      clinicName: serializer.fromJson<String?>(json['clinicName']),
      address: serializer.fromJson<String?>(json['address']),
      areaId: serializer.fromJson<String>(json['areaId']),
      areaName: serializer.fromJson<String?>(json['areaName']),
      associationId: serializer.fromJson<String?>(json['associationId']),
      associationName: serializer.fromJson<String?>(json['associationName']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      localUpdatedAt: serializer.fromJson<DateTime?>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'normalizedPhone': serializer.toJson<String>(normalizedPhone),
      'phone': serializer.toJson<String>(phone),
      'alternatePhone': serializer.toJson<String?>(alternatePhone),
      'email': serializer.toJson<String?>(email),
      'medicalLicenseNumber': serializer.toJson<String>(medicalLicenseNumber),
      'specialization': serializer.toJson<String>(specialization),
      'qualification': serializer.toJson<String?>(qualification),
      'clinicName': serializer.toJson<String?>(clinicName),
      'address': serializer.toJson<String?>(address),
      'areaId': serializer.toJson<String>(areaId),
      'areaName': serializer.toJson<String?>(areaName),
      'associationId': serializer.toJson<String?>(associationId),
      'associationName': serializer.toJson<String?>(associationName),
      'isActive': serializer.toJson<bool>(isActive),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'localUpdatedAt': serializer.toJson<DateTime?>(localUpdatedAt),
    };
  }

  LocalDoctor copyWith({
    String? id,
    String? name,
    String? normalizedPhone,
    String? phone,
    Value<String?> alternatePhone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    String? medicalLicenseNumber,
    String? specialization,
    Value<String?> qualification = const Value.absent(),
    Value<String?> clinicName = const Value.absent(),
    Value<String?> address = const Value.absent(),
    String? areaId,
    Value<String?> areaName = const Value.absent(),
    Value<String?> associationId = const Value.absent(),
    Value<String?> associationName = const Value.absent(),
    bool? isActive,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
    Value<DateTime?> localUpdatedAt = const Value.absent(),
  }) => LocalDoctor(
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedPhone: normalizedPhone ?? this.normalizedPhone,
    phone: phone ?? this.phone,
    alternatePhone: alternatePhone.present
        ? alternatePhone.value
        : this.alternatePhone,
    email: email.present ? email.value : this.email,
    medicalLicenseNumber: medicalLicenseNumber ?? this.medicalLicenseNumber,
    specialization: specialization ?? this.specialization,
    qualification: qualification.present
        ? qualification.value
        : this.qualification,
    clinicName: clinicName.present ? clinicName.value : this.clinicName,
    address: address.present ? address.value : this.address,
    areaId: areaId ?? this.areaId,
    areaName: areaName.present ? areaName.value : this.areaName,
    associationId: associationId.present
        ? associationId.value
        : this.associationId,
    associationName: associationName.present
        ? associationName.value
        : this.associationName,
    isActive: isActive ?? this.isActive,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    localUpdatedAt: localUpdatedAt.present
        ? localUpdatedAt.value
        : this.localUpdatedAt,
  );
  LocalDoctor copyWithCompanion(LocalDoctorsCompanion data) {
    return LocalDoctor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedPhone: data.normalizedPhone.present
          ? data.normalizedPhone.value
          : this.normalizedPhone,
      phone: data.phone.present ? data.phone.value : this.phone,
      alternatePhone: data.alternatePhone.present
          ? data.alternatePhone.value
          : this.alternatePhone,
      email: data.email.present ? data.email.value : this.email,
      medicalLicenseNumber: data.medicalLicenseNumber.present
          ? data.medicalLicenseNumber.value
          : this.medicalLicenseNumber,
      specialization: data.specialization.present
          ? data.specialization.value
          : this.specialization,
      qualification: data.qualification.present
          ? data.qualification.value
          : this.qualification,
      clinicName: data.clinicName.present
          ? data.clinicName.value
          : this.clinicName,
      address: data.address.present ? data.address.value : this.address,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      areaName: data.areaName.present ? data.areaName.value : this.areaName,
      associationId: data.associationId.present
          ? data.associationId.value
          : this.associationId,
      associationName: data.associationName.present
          ? data.associationName.value
          : this.associationName,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDoctor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedPhone: $normalizedPhone, ')
          ..write('phone: $phone, ')
          ..write('alternatePhone: $alternatePhone, ')
          ..write('email: $email, ')
          ..write('medicalLicenseNumber: $medicalLicenseNumber, ')
          ..write('specialization: $specialization, ')
          ..write('qualification: $qualification, ')
          ..write('clinicName: $clinicName, ')
          ..write('address: $address, ')
          ..write('areaId: $areaId, ')
          ..write('areaName: $areaName, ')
          ..write('associationId: $associationId, ')
          ..write('associationName: $associationName, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    normalizedPhone,
    phone,
    alternatePhone,
    email,
    medicalLicenseNumber,
    specialization,
    qualification,
    clinicName,
    address,
    areaId,
    areaName,
    associationId,
    associationName,
    isActive,
    notes,
    createdAt,
    updatedAt,
    syncState,
    lastSyncedAt,
    serverUpdatedAt,
    localUpdatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDoctor &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedPhone == this.normalizedPhone &&
          other.phone == this.phone &&
          other.alternatePhone == this.alternatePhone &&
          other.email == this.email &&
          other.medicalLicenseNumber == this.medicalLicenseNumber &&
          other.specialization == this.specialization &&
          other.qualification == this.qualification &&
          other.clinicName == this.clinicName &&
          other.address == this.address &&
          other.areaId == this.areaId &&
          other.areaName == this.areaName &&
          other.associationId == this.associationId &&
          other.associationName == this.associationName &&
          other.isActive == this.isActive &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class LocalDoctorsCompanion extends UpdateCompanion<LocalDoctor> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> normalizedPhone;
  final Value<String> phone;
  final Value<String?> alternatePhone;
  final Value<String?> email;
  final Value<String> medicalLicenseNumber;
  final Value<String> specialization;
  final Value<String?> qualification;
  final Value<String?> clinicName;
  final Value<String?> address;
  final Value<String> areaId;
  final Value<String?> areaName;
  final Value<String?> associationId;
  final Value<String?> associationName;
  final Value<bool> isActive;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<DateTime?> localUpdatedAt;
  final Value<int> rowid;
  const LocalDoctorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedPhone = const Value.absent(),
    this.phone = const Value.absent(),
    this.alternatePhone = const Value.absent(),
    this.email = const Value.absent(),
    this.medicalLicenseNumber = const Value.absent(),
    this.specialization = const Value.absent(),
    this.qualification = const Value.absent(),
    this.clinicName = const Value.absent(),
    this.address = const Value.absent(),
    this.areaId = const Value.absent(),
    this.areaName = const Value.absent(),
    this.associationId = const Value.absent(),
    this.associationName = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDoctorsCompanion.insert({
    required String id,
    required String name,
    required String normalizedPhone,
    required String phone,
    this.alternatePhone = const Value.absent(),
    this.email = const Value.absent(),
    required String medicalLicenseNumber,
    required String specialization,
    this.qualification = const Value.absent(),
    this.clinicName = const Value.absent(),
    this.address = const Value.absent(),
    required String areaId,
    this.areaName = const Value.absent(),
    this.associationId = const Value.absent(),
    this.associationName = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       normalizedPhone = Value(normalizedPhone),
       phone = Value(phone),
       medicalLicenseNumber = Value(medicalLicenseNumber),
       specialization = Value(specialization),
       areaId = Value(areaId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalDoctor> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? normalizedPhone,
    Expression<String>? phone,
    Expression<String>? alternatePhone,
    Expression<String>? email,
    Expression<String>? medicalLicenseNumber,
    Expression<String>? specialization,
    Expression<String>? qualification,
    Expression<String>? clinicName,
    Expression<String>? address,
    Expression<String>? areaId,
    Expression<String>? areaName,
    Expression<String>? associationId,
    Expression<String>? associationName,
    Expression<bool>? isActive,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedPhone != null) 'normalized_phone': normalizedPhone,
      if (phone != null) 'phone': phone,
      if (alternatePhone != null) 'alternate_phone': alternatePhone,
      if (email != null) 'email': email,
      if (medicalLicenseNumber != null)
        'medical_license_number': medicalLicenseNumber,
      if (specialization != null) 'specialization': specialization,
      if (qualification != null) 'qualification': qualification,
      if (clinicName != null) 'clinic_name': clinicName,
      if (address != null) 'address': address,
      if (areaId != null) 'area_id': areaId,
      if (areaName != null) 'area_name': areaName,
      if (associationId != null) 'association_id': associationId,
      if (associationName != null) 'association_name': associationName,
      if (isActive != null) 'is_active': isActive,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDoctorsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? normalizedPhone,
    Value<String>? phone,
    Value<String?>? alternatePhone,
    Value<String?>? email,
    Value<String>? medicalLicenseNumber,
    Value<String>? specialization,
    Value<String?>? qualification,
    Value<String?>? clinicName,
    Value<String?>? address,
    Value<String>? areaId,
    Value<String?>? areaName,
    Value<String?>? associationId,
    Value<String?>? associationName,
    Value<bool>? isActive,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncState,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime?>? serverUpdatedAt,
    Value<DateTime?>? localUpdatedAt,
    Value<int>? rowid,
  }) {
    return LocalDoctorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedPhone: normalizedPhone ?? this.normalizedPhone,
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
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedPhone.present) {
      map['normalized_phone'] = Variable<String>(normalizedPhone.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (alternatePhone.present) {
      map['alternate_phone'] = Variable<String>(alternatePhone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (medicalLicenseNumber.present) {
      map['medical_license_number'] = Variable<String>(
        medicalLicenseNumber.value,
      );
    }
    if (specialization.present) {
      map['specialization'] = Variable<String>(specialization.value);
    }
    if (qualification.present) {
      map['qualification'] = Variable<String>(qualification.value);
    }
    if (clinicName.present) {
      map['clinic_name'] = Variable<String>(clinicName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (areaName.present) {
      map['area_name'] = Variable<String>(areaName.value);
    }
    if (associationId.present) {
      map['association_id'] = Variable<String>(associationId.value);
    }
    if (associationName.present) {
      map['association_name'] = Variable<String>(associationName.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDoctorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedPhone: $normalizedPhone, ')
          ..write('phone: $phone, ')
          ..write('alternatePhone: $alternatePhone, ')
          ..write('email: $email, ')
          ..write('medicalLicenseNumber: $medicalLicenseNumber, ')
          ..write('specialization: $specialization, ')
          ..write('qualification: $qualification, ')
          ..write('clinicName: $clinicName, ')
          ..write('address: $address, ')
          ..write('areaId: $areaId, ')
          ..write('areaName: $areaName, ')
          ..write('associationId: $associationId, ')
          ..write('associationName: $associationName, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProductRefsTable extends LocalProductRefs
    with TableInfo<$LocalProductRefsTable, LocalProductRef> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProductRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _healixProductIdMeta = const VerificationMeta(
    'healixProductId',
  );
  @override
  late final GeneratedColumn<int> healixProductId = GeneratedColumn<int>(
    'healix_product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mrpMeta = const VerificationMeta('mrp');
  @override
  late final GeneratedColumn<String> mrp = GeneratedColumn<String>(
    'mrp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ingredientsJsonMeta = const VerificationMeta(
    'ingredientsJson',
  );
  @override
  late final GeneratedColumn<String> ingredientsJson = GeneratedColumn<String>(
    'ingredients_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _benefitsJsonMeta = const VerificationMeta(
    'benefitsJson',
  );
  @override
  late final GeneratedColumn<String> benefitsJson = GeneratedColumn<String>(
    'benefits_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVE'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    healixProductId,
    name,
    category,
    mrp,
    imageUrl,
    description,
    ingredientsJson,
    benefitsJson,
    status,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_product_refs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProductRef> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('healix_product_id')) {
      context.handle(
        _healixProductIdMeta,
        healixProductId.isAcceptableOrUnknown(
          data['healix_product_id']!,
          _healixProductIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('mrp')) {
      context.handle(
        _mrpMeta,
        mrp.isAcceptableOrUnknown(data['mrp']!, _mrpMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('ingredients_json')) {
      context.handle(
        _ingredientsJsonMeta,
        ingredientsJson.isAcceptableOrUnknown(
          data['ingredients_json']!,
          _ingredientsJsonMeta,
        ),
      );
    }
    if (data.containsKey('benefits_json')) {
      context.handle(
        _benefitsJsonMeta,
        benefitsJson.isAcceptableOrUnknown(
          data['benefits_json']!,
          _benefitsJsonMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {healixProductId};
  @override
  LocalProductRef map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProductRef(
      healixProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}healix_product_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      mrp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mrp'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      ingredientsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredients_json'],
      )!,
      benefitsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}benefits_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      )!,
    );
  }

  @override
  $LocalProductRefsTable createAlias(String alias) {
    return $LocalProductRefsTable(attachedDatabase, alias);
  }
}

class LocalProductRef extends DataClass implements Insertable<LocalProductRef> {
  final int healixProductId;
  final String name;
  final String? category;
  final String? mrp;
  final String? imageUrl;
  final String? description;
  final String ingredientsJson;
  final String benefitsJson;
  final String status;
  final DateTime lastSyncedAt;
  const LocalProductRef({
    required this.healixProductId,
    required this.name,
    this.category,
    this.mrp,
    this.imageUrl,
    this.description,
    required this.ingredientsJson,
    required this.benefitsJson,
    required this.status,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['healix_product_id'] = Variable<int>(healixProductId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || mrp != null) {
      map['mrp'] = Variable<String>(mrp);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['ingredients_json'] = Variable<String>(ingredientsJson);
    map['benefits_json'] = Variable<String>(benefitsJson);
    map['status'] = Variable<String>(status);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    return map;
  }

  LocalProductRefsCompanion toCompanion(bool nullToAbsent) {
    return LocalProductRefsCompanion(
      healixProductId: Value(healixProductId),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      mrp: mrp == null && nullToAbsent ? const Value.absent() : Value(mrp),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      ingredientsJson: Value(ingredientsJson),
      benefitsJson: Value(benefitsJson),
      status: Value(status),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory LocalProductRef.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProductRef(
      healixProductId: serializer.fromJson<int>(json['healixProductId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      mrp: serializer.fromJson<String?>(json['mrp']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      ingredientsJson: serializer.fromJson<String>(json['ingredientsJson']),
      benefitsJson: serializer.fromJson<String>(json['benefitsJson']),
      status: serializer.fromJson<String>(json['status']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'healixProductId': serializer.toJson<int>(healixProductId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'mrp': serializer.toJson<String?>(mrp),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'ingredientsJson': serializer.toJson<String>(ingredientsJson),
      'benefitsJson': serializer.toJson<String>(benefitsJson),
      'status': serializer.toJson<String>(status),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
    };
  }

  LocalProductRef copyWith({
    int? healixProductId,
    String? name,
    Value<String?> category = const Value.absent(),
    Value<String?> mrp = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? ingredientsJson,
    String? benefitsJson,
    String? status,
    DateTime? lastSyncedAt,
  }) => LocalProductRef(
    healixProductId: healixProductId ?? this.healixProductId,
    name: name ?? this.name,
    category: category.present ? category.value : this.category,
    mrp: mrp.present ? mrp.value : this.mrp,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    description: description.present ? description.value : this.description,
    ingredientsJson: ingredientsJson ?? this.ingredientsJson,
    benefitsJson: benefitsJson ?? this.benefitsJson,
    status: status ?? this.status,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  LocalProductRef copyWithCompanion(LocalProductRefsCompanion data) {
    return LocalProductRef(
      healixProductId: data.healixProductId.present
          ? data.healixProductId.value
          : this.healixProductId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      mrp: data.mrp.present ? data.mrp.value : this.mrp,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      ingredientsJson: data.ingredientsJson.present
          ? data.ingredientsJson.value
          : this.ingredientsJson,
      benefitsJson: data.benefitsJson.present
          ? data.benefitsJson.value
          : this.benefitsJson,
      status: data.status.present ? data.status.value : this.status,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProductRef(')
          ..write('healixProductId: $healixProductId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('mrp: $mrp, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('ingredientsJson: $ingredientsJson, ')
          ..write('benefitsJson: $benefitsJson, ')
          ..write('status: $status, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    healixProductId,
    name,
    category,
    mrp,
    imageUrl,
    description,
    ingredientsJson,
    benefitsJson,
    status,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProductRef &&
          other.healixProductId == this.healixProductId &&
          other.name == this.name &&
          other.category == this.category &&
          other.mrp == this.mrp &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.ingredientsJson == this.ingredientsJson &&
          other.benefitsJson == this.benefitsJson &&
          other.status == this.status &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalProductRefsCompanion extends UpdateCompanion<LocalProductRef> {
  final Value<int> healixProductId;
  final Value<String> name;
  final Value<String?> category;
  final Value<String?> mrp;
  final Value<String?> imageUrl;
  final Value<String?> description;
  final Value<String> ingredientsJson;
  final Value<String> benefitsJson;
  final Value<String> status;
  final Value<DateTime> lastSyncedAt;
  const LocalProductRefsCompanion({
    this.healixProductId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.mrp = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.ingredientsJson = const Value.absent(),
    this.benefitsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  LocalProductRefsCompanion.insert({
    this.healixProductId = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.mrp = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.ingredientsJson = const Value.absent(),
    this.benefitsJson = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime lastSyncedAt,
  }) : name = Value(name),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<LocalProductRef> custom({
    Expression<int>? healixProductId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? mrp,
    Expression<String>? imageUrl,
    Expression<String>? description,
    Expression<String>? ingredientsJson,
    Expression<String>? benefitsJson,
    Expression<String>? status,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (healixProductId != null) 'healix_product_id': healixProductId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (mrp != null) 'mrp': mrp,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (ingredientsJson != null) 'ingredients_json': ingredientsJson,
      if (benefitsJson != null) 'benefits_json': benefitsJson,
      if (status != null) 'status': status,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  LocalProductRefsCompanion copyWith({
    Value<int>? healixProductId,
    Value<String>? name,
    Value<String?>? category,
    Value<String?>? mrp,
    Value<String?>? imageUrl,
    Value<String?>? description,
    Value<String>? ingredientsJson,
    Value<String>? benefitsJson,
    Value<String>? status,
    Value<DateTime>? lastSyncedAt,
  }) {
    return LocalProductRefsCompanion(
      healixProductId: healixProductId ?? this.healixProductId,
      name: name ?? this.name,
      category: category ?? this.category,
      mrp: mrp ?? this.mrp,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      ingredientsJson: ingredientsJson ?? this.ingredientsJson,
      benefitsJson: benefitsJson ?? this.benefitsJson,
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (healixProductId.present) {
      map['healix_product_id'] = Variable<int>(healixProductId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (mrp.present) {
      map['mrp'] = Variable<String>(mrp.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (ingredientsJson.present) {
      map['ingredients_json'] = Variable<String>(ingredientsJson.value);
    }
    if (benefitsJson.present) {
      map['benefits_json'] = Variable<String>(benefitsJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProductRefsCompanion(')
          ..write('healixProductId: $healixProductId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('mrp: $mrp, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('ingredientsJson: $ingredientsJson, ')
          ..write('benefitsJson: $benefitsJson, ')
          ..write('status: $status, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalVisitsTable extends LocalVisits
    with TableInfo<$LocalVisitsTable, LocalVisit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalVisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientOperationIdMeta = const VerificationMeta(
    'clientOperationId',
  );
  @override
  late final GeneratedColumn<String> clientOperationId =
      GeneratedColumn<String>(
        'client_operation_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      );
  static const VerificationMeta _doctorIdMeta = const VerificationMeta(
    'doctorId',
  );
  @override
  late final GeneratedColumn<String> doctorId = GeneratedColumn<String>(
    'doctor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitDatetimeMeta = const VerificationMeta(
    'visitDatetime',
  );
  @override
  late final GeneratedColumn<DateTime> visitDatetime =
      GeneratedColumn<DateTime>(
        'visit_datetime',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _visitTypeMeta = const VerificationMeta(
    'visitType',
  );
  @override
  late final GeneratedColumn<String> visitType = GeneratedColumn<String>(
    'visit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doctorResponseMeta = const VerificationMeta(
    'doctorResponse',
  );
  @override
  late final GeneratedColumn<String> doctorResponse = GeneratedColumn<String>(
    'doctor_response',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prescriptionPotentialMeta =
      const VerificationMeta('prescriptionPotential');
  @override
  late final GeneratedColumn<String> prescriptionPotential =
      GeneratedColumn<String>(
        'prescription_potential',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _doctorFeedbackMeta = const VerificationMeta(
    'doctorFeedback',
  );
  @override
  late final GeneratedColumn<String> doctorFeedback = GeneratedColumn<String>(
    'doctor_feedback',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientOperationId,
    doctorId,
    visitDatetime,
    visitType,
    doctorResponse,
    prescriptionPotential,
    doctorFeedback,
    notes,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalVisit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_operation_id')) {
      context.handle(
        _clientOperationIdMeta,
        clientOperationId.isAcceptableOrUnknown(
          data['client_operation_id']!,
          _clientOperationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientOperationIdMeta);
    }
    if (data.containsKey('doctor_id')) {
      context.handle(
        _doctorIdMeta,
        doctorId.isAcceptableOrUnknown(data['doctor_id']!, _doctorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_doctorIdMeta);
    }
    if (data.containsKey('visit_datetime')) {
      context.handle(
        _visitDatetimeMeta,
        visitDatetime.isAcceptableOrUnknown(
          data['visit_datetime']!,
          _visitDatetimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_visitDatetimeMeta);
    }
    if (data.containsKey('visit_type')) {
      context.handle(
        _visitTypeMeta,
        visitType.isAcceptableOrUnknown(data['visit_type']!, _visitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_visitTypeMeta);
    }
    if (data.containsKey('doctor_response')) {
      context.handle(
        _doctorResponseMeta,
        doctorResponse.isAcceptableOrUnknown(
          data['doctor_response']!,
          _doctorResponseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_doctorResponseMeta);
    }
    if (data.containsKey('prescription_potential')) {
      context.handle(
        _prescriptionPotentialMeta,
        prescriptionPotential.isAcceptableOrUnknown(
          data['prescription_potential']!,
          _prescriptionPotentialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prescriptionPotentialMeta);
    }
    if (data.containsKey('doctor_feedback')) {
      context.handle(
        _doctorFeedbackMeta,
        doctorFeedback.isAcceptableOrUnknown(
          data['doctor_feedback']!,
          _doctorFeedbackMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalVisit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_operation_id'],
      )!,
      doctorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doctor_id'],
      )!,
      visitDatetime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visit_datetime'],
      )!,
      visitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_type'],
      )!,
      doctorResponse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doctor_response'],
      )!,
      prescriptionPotential: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescription_potential'],
      )!,
      doctorFeedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doctor_feedback'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalVisitsTable createAlias(String alias) {
    return $LocalVisitsTable(attachedDatabase, alias);
  }
}

class LocalVisit extends DataClass implements Insertable<LocalVisit> {
  final String id;
  final String clientOperationId;
  final String doctorId;
  final DateTime visitDatetime;
  final String visitType;
  final String doctorResponse;
  final String prescriptionPotential;
  final String? doctorFeedback;
  final String? notes;
  final String syncStatus;
  final DateTime createdAt;
  const LocalVisit({
    required this.id,
    required this.clientOperationId,
    required this.doctorId,
    required this.visitDatetime,
    required this.visitType,
    required this.doctorResponse,
    required this.prescriptionPotential,
    this.doctorFeedback,
    this.notes,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_operation_id'] = Variable<String>(clientOperationId);
    map['doctor_id'] = Variable<String>(doctorId);
    map['visit_datetime'] = Variable<DateTime>(visitDatetime);
    map['visit_type'] = Variable<String>(visitType);
    map['doctor_response'] = Variable<String>(doctorResponse);
    map['prescription_potential'] = Variable<String>(prescriptionPotential);
    if (!nullToAbsent || doctorFeedback != null) {
      map['doctor_feedback'] = Variable<String>(doctorFeedback);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalVisitsCompanion toCompanion(bool nullToAbsent) {
    return LocalVisitsCompanion(
      id: Value(id),
      clientOperationId: Value(clientOperationId),
      doctorId: Value(doctorId),
      visitDatetime: Value(visitDatetime),
      visitType: Value(visitType),
      doctorResponse: Value(doctorResponse),
      prescriptionPotential: Value(prescriptionPotential),
      doctorFeedback: doctorFeedback == null && nullToAbsent
          ? const Value.absent()
          : Value(doctorFeedback),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory LocalVisit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalVisit(
      id: serializer.fromJson<String>(json['id']),
      clientOperationId: serializer.fromJson<String>(json['clientOperationId']),
      doctorId: serializer.fromJson<String>(json['doctorId']),
      visitDatetime: serializer.fromJson<DateTime>(json['visitDatetime']),
      visitType: serializer.fromJson<String>(json['visitType']),
      doctorResponse: serializer.fromJson<String>(json['doctorResponse']),
      prescriptionPotential: serializer.fromJson<String>(
        json['prescriptionPotential'],
      ),
      doctorFeedback: serializer.fromJson<String?>(json['doctorFeedback']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientOperationId': serializer.toJson<String>(clientOperationId),
      'doctorId': serializer.toJson<String>(doctorId),
      'visitDatetime': serializer.toJson<DateTime>(visitDatetime),
      'visitType': serializer.toJson<String>(visitType),
      'doctorResponse': serializer.toJson<String>(doctorResponse),
      'prescriptionPotential': serializer.toJson<String>(prescriptionPotential),
      'doctorFeedback': serializer.toJson<String?>(doctorFeedback),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalVisit copyWith({
    String? id,
    String? clientOperationId,
    String? doctorId,
    DateTime? visitDatetime,
    String? visitType,
    String? doctorResponse,
    String? prescriptionPotential,
    Value<String?> doctorFeedback = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? syncStatus,
    DateTime? createdAt,
  }) => LocalVisit(
    id: id ?? this.id,
    clientOperationId: clientOperationId ?? this.clientOperationId,
    doctorId: doctorId ?? this.doctorId,
    visitDatetime: visitDatetime ?? this.visitDatetime,
    visitType: visitType ?? this.visitType,
    doctorResponse: doctorResponse ?? this.doctorResponse,
    prescriptionPotential: prescriptionPotential ?? this.prescriptionPotential,
    doctorFeedback: doctorFeedback.present
        ? doctorFeedback.value
        : this.doctorFeedback,
    notes: notes.present ? notes.value : this.notes,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalVisit copyWithCompanion(LocalVisitsCompanion data) {
    return LocalVisit(
      id: data.id.present ? data.id.value : this.id,
      clientOperationId: data.clientOperationId.present
          ? data.clientOperationId.value
          : this.clientOperationId,
      doctorId: data.doctorId.present ? data.doctorId.value : this.doctorId,
      visitDatetime: data.visitDatetime.present
          ? data.visitDatetime.value
          : this.visitDatetime,
      visitType: data.visitType.present ? data.visitType.value : this.visitType,
      doctorResponse: data.doctorResponse.present
          ? data.doctorResponse.value
          : this.doctorResponse,
      prescriptionPotential: data.prescriptionPotential.present
          ? data.prescriptionPotential.value
          : this.prescriptionPotential,
      doctorFeedback: data.doctorFeedback.present
          ? data.doctorFeedback.value
          : this.doctorFeedback,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalVisit(')
          ..write('id: $id, ')
          ..write('clientOperationId: $clientOperationId, ')
          ..write('doctorId: $doctorId, ')
          ..write('visitDatetime: $visitDatetime, ')
          ..write('visitType: $visitType, ')
          ..write('doctorResponse: $doctorResponse, ')
          ..write('prescriptionPotential: $prescriptionPotential, ')
          ..write('doctorFeedback: $doctorFeedback, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientOperationId,
    doctorId,
    visitDatetime,
    visitType,
    doctorResponse,
    prescriptionPotential,
    doctorFeedback,
    notes,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalVisit &&
          other.id == this.id &&
          other.clientOperationId == this.clientOperationId &&
          other.doctorId == this.doctorId &&
          other.visitDatetime == this.visitDatetime &&
          other.visitType == this.visitType &&
          other.doctorResponse == this.doctorResponse &&
          other.prescriptionPotential == this.prescriptionPotential &&
          other.doctorFeedback == this.doctorFeedback &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class LocalVisitsCompanion extends UpdateCompanion<LocalVisit> {
  final Value<String> id;
  final Value<String> clientOperationId;
  final Value<String> doctorId;
  final Value<DateTime> visitDatetime;
  final Value<String> visitType;
  final Value<String> doctorResponse;
  final Value<String> prescriptionPotential;
  final Value<String?> doctorFeedback;
  final Value<String?> notes;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalVisitsCompanion({
    this.id = const Value.absent(),
    this.clientOperationId = const Value.absent(),
    this.doctorId = const Value.absent(),
    this.visitDatetime = const Value.absent(),
    this.visitType = const Value.absent(),
    this.doctorResponse = const Value.absent(),
    this.prescriptionPotential = const Value.absent(),
    this.doctorFeedback = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalVisitsCompanion.insert({
    required String id,
    required String clientOperationId,
    required String doctorId,
    required DateTime visitDatetime,
    required String visitType,
    required String doctorResponse,
    required String prescriptionPotential,
    this.doctorFeedback = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientOperationId = Value(clientOperationId),
       doctorId = Value(doctorId),
       visitDatetime = Value(visitDatetime),
       visitType = Value(visitType),
       doctorResponse = Value(doctorResponse),
       prescriptionPotential = Value(prescriptionPotential),
       createdAt = Value(createdAt);
  static Insertable<LocalVisit> custom({
    Expression<String>? id,
    Expression<String>? clientOperationId,
    Expression<String>? doctorId,
    Expression<DateTime>? visitDatetime,
    Expression<String>? visitType,
    Expression<String>? doctorResponse,
    Expression<String>? prescriptionPotential,
    Expression<String>? doctorFeedback,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientOperationId != null) 'client_operation_id': clientOperationId,
      if (doctorId != null) 'doctor_id': doctorId,
      if (visitDatetime != null) 'visit_datetime': visitDatetime,
      if (visitType != null) 'visit_type': visitType,
      if (doctorResponse != null) 'doctor_response': doctorResponse,
      if (prescriptionPotential != null)
        'prescription_potential': prescriptionPotential,
      if (doctorFeedback != null) 'doctor_feedback': doctorFeedback,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalVisitsCompanion copyWith({
    Value<String>? id,
    Value<String>? clientOperationId,
    Value<String>? doctorId,
    Value<DateTime>? visitDatetime,
    Value<String>? visitType,
    Value<String>? doctorResponse,
    Value<String>? prescriptionPotential,
    Value<String?>? doctorFeedback,
    Value<String?>? notes,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalVisitsCompanion(
      id: id ?? this.id,
      clientOperationId: clientOperationId ?? this.clientOperationId,
      doctorId: doctorId ?? this.doctorId,
      visitDatetime: visitDatetime ?? this.visitDatetime,
      visitType: visitType ?? this.visitType,
      doctorResponse: doctorResponse ?? this.doctorResponse,
      prescriptionPotential:
          prescriptionPotential ?? this.prescriptionPotential,
      doctorFeedback: doctorFeedback ?? this.doctorFeedback,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientOperationId.present) {
      map['client_operation_id'] = Variable<String>(clientOperationId.value);
    }
    if (doctorId.present) {
      map['doctor_id'] = Variable<String>(doctorId.value);
    }
    if (visitDatetime.present) {
      map['visit_datetime'] = Variable<DateTime>(visitDatetime.value);
    }
    if (visitType.present) {
      map['visit_type'] = Variable<String>(visitType.value);
    }
    if (doctorResponse.present) {
      map['doctor_response'] = Variable<String>(doctorResponse.value);
    }
    if (prescriptionPotential.present) {
      map['prescription_potential'] = Variable<String>(
        prescriptionPotential.value,
      );
    }
    if (doctorFeedback.present) {
      map['doctor_feedback'] = Variable<String>(doctorFeedback.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalVisitsCompanion(')
          ..write('id: $id, ')
          ..write('clientOperationId: $clientOperationId, ')
          ..write('doctorId: $doctorId, ')
          ..write('visitDatetime: $visitDatetime, ')
          ..write('visitType: $visitType, ')
          ..write('doctorResponse: $doctorResponse, ')
          ..write('prescriptionPotential: $prescriptionPotential, ')
          ..write('doctorFeedback: $doctorFeedback, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSyncQueueTable extends LocalSyncQueue
    with TableInfo<$LocalSyncQueueTable, LocalSyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientOperationIdMeta = const VerificationMeta(
    'clientOperationId',
  );
  @override
  late final GeneratedColumn<String> clientOperationId =
      GeneratedColumn<String>(
        'client_operation_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientOperationId,
    entityType,
    payloadJson,
    status,
    retryCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_operation_id')) {
      context.handle(
        _clientOperationIdMeta,
        clientOperationId.isAcceptableOrUnknown(
          data['client_operation_id']!,
          _clientOperationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientOperationIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientOperationId};
  @override
  LocalSyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSyncQueueData(
      clientOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_operation_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalSyncQueueTable createAlias(String alias) {
    return $LocalSyncQueueTable(attachedDatabase, alias);
  }
}

class LocalSyncQueueData extends DataClass
    implements Insertable<LocalSyncQueueData> {
  final String clientOperationId;
  final String entityType;
  final String payloadJson;
  final String status;
  final int retryCount;
  final DateTime createdAt;
  const LocalSyncQueueData({
    required this.clientOperationId,
    required this.entityType,
    required this.payloadJson,
    required this.status,
    required this.retryCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_operation_id'] = Variable<String>(clientOperationId);
    map['entity_type'] = Variable<String>(entityType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalSyncQueueCompanion toCompanion(bool nullToAbsent) {
    return LocalSyncQueueCompanion(
      clientOperationId: Value(clientOperationId),
      entityType: Value(entityType),
      payloadJson: Value(payloadJson),
      status: Value(status),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
    );
  }

  factory LocalSyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSyncQueueData(
      clientOperationId: serializer.fromJson<String>(json['clientOperationId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientOperationId': serializer.toJson<String>(clientOperationId),
      'entityType': serializer.toJson<String>(entityType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalSyncQueueData copyWith({
    String? clientOperationId,
    String? entityType,
    String? payloadJson,
    String? status,
    int? retryCount,
    DateTime? createdAt,
  }) => LocalSyncQueueData(
    clientOperationId: clientOperationId ?? this.clientOperationId,
    entityType: entityType ?? this.entityType,
    payloadJson: payloadJson ?? this.payloadJson,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalSyncQueueData copyWithCompanion(LocalSyncQueueCompanion data) {
    return LocalSyncQueueData(
      clientOperationId: data.clientOperationId.present
          ? data.clientOperationId.value
          : this.clientOperationId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncQueueData(')
          ..write('clientOperationId: $clientOperationId, ')
          ..write('entityType: $entityType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientOperationId,
    entityType,
    payloadJson,
    status,
    retryCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSyncQueueData &&
          other.clientOperationId == this.clientOperationId &&
          other.entityType == this.entityType &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt);
}

class LocalSyncQueueCompanion extends UpdateCompanion<LocalSyncQueueData> {
  final Value<String> clientOperationId;
  final Value<String> entityType;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalSyncQueueCompanion({
    this.clientOperationId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSyncQueueCompanion.insert({
    required String clientOperationId,
    required String entityType,
    required String payloadJson,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : clientOperationId = Value(clientOperationId),
       entityType = Value(entityType),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<LocalSyncQueueData> custom({
    Expression<String>? clientOperationId,
    Expression<String>? entityType,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientOperationId != null) 'client_operation_id': clientOperationId,
      if (entityType != null) 'entity_type': entityType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSyncQueueCompanion copyWith({
    Value<String>? clientOperationId,
    Value<String>? entityType,
    Value<String>? payloadJson,
    Value<String>? status,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalSyncQueueCompanion(
      clientOperationId: clientOperationId ?? this.clientOperationId,
      entityType: entityType ?? this.entityType,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientOperationId.present) {
      map['client_operation_id'] = Variable<String>(clientOperationId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncQueueCompanion(')
          ..write('clientOperationId: $clientOperationId, ')
          ..write('entityType: $entityType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalAreasTable localAreas = $LocalAreasTable(this);
  late final $LocalAssociationsTable localAssociations =
      $LocalAssociationsTable(this);
  late final $LocalDoctorsTable localDoctors = $LocalDoctorsTable(this);
  late final $LocalProductRefsTable localProductRefs = $LocalProductRefsTable(
    this,
  );
  late final $LocalVisitsTable localVisits = $LocalVisitsTable(this);
  late final $LocalSyncQueueTable localSyncQueue = $LocalSyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localAreas,
    localAssociations,
    localDoctors,
    localProductRefs,
    localVisits,
    localSyncQueue,
  ];
}

typedef $$LocalAreasTableCreateCompanionBuilder =
    LocalAreasCompanion Function({
      required String id,
      required String name,
      required String code,
      Value<String?> description,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncState,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<DateTime?> localUpdatedAt,
      Value<int> rowid,
    });
typedef $$LocalAreasTableUpdateCompanionBuilder =
    LocalAreasCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> code,
      Value<String?> description,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncState,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<DateTime?> localUpdatedAt,
      Value<int> rowid,
    });

class $$LocalAreasTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAreasTable> {
  $$LocalAreasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAreasTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAreasTable> {
  $$LocalAreasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAreasTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAreasTable> {
  $$LocalAreasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );
}

class $$LocalAreasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAreasTable,
          LocalArea,
          $$LocalAreasTableFilterComposer,
          $$LocalAreasTableOrderingComposer,
          $$LocalAreasTableAnnotationComposer,
          $$LocalAreasTableCreateCompanionBuilder,
          $$LocalAreasTableUpdateCompanionBuilder,
          (
            LocalArea,
            BaseReferences<_$AppDatabase, $LocalAreasTable, LocalArea>,
          ),
          LocalArea,
          PrefetchHooks Function()
        > {
  $$LocalAreasTableTableManager(_$AppDatabase db, $LocalAreasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<DateTime?> localUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAreasCompanion(
                id: id,
                name: name,
                code: code,
                description: description,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                serverUpdatedAt: serverUpdatedAt,
                localUpdatedAt: localUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String code,
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<DateTime?> localUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAreasCompanion.insert(
                id: id,
                name: name,
                code: code,
                description: description,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                serverUpdatedAt: serverUpdatedAt,
                localUpdatedAt: localUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalAreasTable, LocalArea>(table),
                  BaseReferences<_$AppDatabase, $LocalAreasTable, LocalArea>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAreasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAreasTable,
      LocalArea,
      $$LocalAreasTableFilterComposer,
      $$LocalAreasTableOrderingComposer,
      $$LocalAreasTableAnnotationComposer,
      $$LocalAreasTableCreateCompanionBuilder,
      $$LocalAreasTableUpdateCompanionBuilder,
      (LocalArea, BaseReferences<_$AppDatabase, $LocalAreasTable, LocalArea>),
      LocalArea,
      PrefetchHooks Function()
    >;
typedef $$LocalAssociationsTableCreateCompanionBuilder =
    LocalAssociationsCompanion Function({
      required String id,
      required String name,
      Value<String?> code,
      Value<String?> description,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncState,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<DateTime?> localUpdatedAt,
      Value<int> rowid,
    });
typedef $$LocalAssociationsTableUpdateCompanionBuilder =
    LocalAssociationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> code,
      Value<String?> description,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncState,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<DateTime?> localUpdatedAt,
      Value<int> rowid,
    });

class $$LocalAssociationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAssociationsTable> {
  $$LocalAssociationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssociationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAssociationsTable> {
  $$LocalAssociationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssociationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAssociationsTable> {
  $$LocalAssociationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );
}

class $$LocalAssociationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAssociationsTable,
          LocalAssociation,
          $$LocalAssociationsTableFilterComposer,
          $$LocalAssociationsTableOrderingComposer,
          $$LocalAssociationsTableAnnotationComposer,
          $$LocalAssociationsTableCreateCompanionBuilder,
          $$LocalAssociationsTableUpdateCompanionBuilder,
          (
            LocalAssociation,
            BaseReferences<
              _$AppDatabase,
              $LocalAssociationsTable,
              LocalAssociation
            >,
          ),
          LocalAssociation,
          PrefetchHooks Function()
        > {
  $$LocalAssociationsTableTableManager(
    _$AppDatabase db,
    $LocalAssociationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssociationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAssociationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAssociationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<DateTime?> localUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssociationsCompanion(
                id: id,
                name: name,
                code: code,
                description: description,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                serverUpdatedAt: serverUpdatedAt,
                localUpdatedAt: localUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> code = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<DateTime?> localUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssociationsCompanion.insert(
                id: id,
                name: name,
                code: code,
                description: description,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                serverUpdatedAt: serverUpdatedAt,
                localUpdatedAt: localUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalAssociationsTable, LocalAssociation>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalAssociationsTable,
                    LocalAssociation
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAssociationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAssociationsTable,
      LocalAssociation,
      $$LocalAssociationsTableFilterComposer,
      $$LocalAssociationsTableOrderingComposer,
      $$LocalAssociationsTableAnnotationComposer,
      $$LocalAssociationsTableCreateCompanionBuilder,
      $$LocalAssociationsTableUpdateCompanionBuilder,
      (
        LocalAssociation,
        BaseReferences<
          _$AppDatabase,
          $LocalAssociationsTable,
          LocalAssociation
        >,
      ),
      LocalAssociation,
      PrefetchHooks Function()
    >;
typedef $$LocalDoctorsTableCreateCompanionBuilder =
    LocalDoctorsCompanion Function({
      required String id,
      required String name,
      required String normalizedPhone,
      required String phone,
      Value<String?> alternatePhone,
      Value<String?> email,
      required String medicalLicenseNumber,
      required String specialization,
      Value<String?> qualification,
      Value<String?> clinicName,
      Value<String?> address,
      required String areaId,
      Value<String?> areaName,
      Value<String?> associationId,
      Value<String?> associationName,
      Value<bool> isActive,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncState,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<DateTime?> localUpdatedAt,
      Value<int> rowid,
    });
typedef $$LocalDoctorsTableUpdateCompanionBuilder =
    LocalDoctorsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> normalizedPhone,
      Value<String> phone,
      Value<String?> alternatePhone,
      Value<String?> email,
      Value<String> medicalLicenseNumber,
      Value<String> specialization,
      Value<String?> qualification,
      Value<String?> clinicName,
      Value<String?> address,
      Value<String> areaId,
      Value<String?> areaName,
      Value<String?> associationId,
      Value<String?> associationName,
      Value<bool> isActive,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncState,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<DateTime?> localUpdatedAt,
      Value<int> rowid,
    });

class $$LocalDoctorsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDoctorsTable> {
  $$LocalDoctorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedPhone => $composableBuilder(
    column: $table.normalizedPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicalLicenseNumber => $composableBuilder(
    column: $table.medicalLicenseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualification => $composableBuilder(
    column: $table.qualification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaName => $composableBuilder(
    column: $table.areaName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get associationId => $composableBuilder(
    column: $table.associationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get associationName => $composableBuilder(
    column: $table.associationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDoctorsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDoctorsTable> {
  $$LocalDoctorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedPhone => $composableBuilder(
    column: $table.normalizedPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicalLicenseNumber => $composableBuilder(
    column: $table.medicalLicenseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualification => $composableBuilder(
    column: $table.qualification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaName => $composableBuilder(
    column: $table.areaName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get associationId => $composableBuilder(
    column: $table.associationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get associationName => $composableBuilder(
    column: $table.associationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDoctorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDoctorsTable> {
  $$LocalDoctorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedPhone => $composableBuilder(
    column: $table.normalizedPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get medicalLicenseNumber => $composableBuilder(
    column: $table.medicalLicenseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qualification => $composableBuilder(
    column: $table.qualification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<String> get areaName =>
      $composableBuilder(column: $table.areaName, builder: (column) => column);

  GeneratedColumn<String> get associationId => $composableBuilder(
    column: $table.associationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get associationName => $composableBuilder(
    column: $table.associationName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );
}

class $$LocalDoctorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDoctorsTable,
          LocalDoctor,
          $$LocalDoctorsTableFilterComposer,
          $$LocalDoctorsTableOrderingComposer,
          $$LocalDoctorsTableAnnotationComposer,
          $$LocalDoctorsTableCreateCompanionBuilder,
          $$LocalDoctorsTableUpdateCompanionBuilder,
          (
            LocalDoctor,
            BaseReferences<_$AppDatabase, $LocalDoctorsTable, LocalDoctor>,
          ),
          LocalDoctor,
          PrefetchHooks Function()
        > {
  $$LocalDoctorsTableTableManager(_$AppDatabase db, $LocalDoctorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDoctorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDoctorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDoctorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedPhone = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> alternatePhone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String> medicalLicenseNumber = const Value.absent(),
                Value<String> specialization = const Value.absent(),
                Value<String?> qualification = const Value.absent(),
                Value<String?> clinicName = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> areaId = const Value.absent(),
                Value<String?> areaName = const Value.absent(),
                Value<String?> associationId = const Value.absent(),
                Value<String?> associationName = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<DateTime?> localUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDoctorsCompanion(
                id: id,
                name: name,
                normalizedPhone: normalizedPhone,
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
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                serverUpdatedAt: serverUpdatedAt,
                localUpdatedAt: localUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String normalizedPhone,
                required String phone,
                Value<String?> alternatePhone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                required String medicalLicenseNumber,
                required String specialization,
                Value<String?> qualification = const Value.absent(),
                Value<String?> clinicName = const Value.absent(),
                Value<String?> address = const Value.absent(),
                required String areaId,
                Value<String?> areaName = const Value.absent(),
                Value<String?> associationId = const Value.absent(),
                Value<String?> associationName = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<DateTime?> localUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDoctorsCompanion.insert(
                id: id,
                name: name,
                normalizedPhone: normalizedPhone,
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
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                serverUpdatedAt: serverUpdatedAt,
                localUpdatedAt: localUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalDoctorsTable, LocalDoctor>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalDoctorsTable,
                    LocalDoctor
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDoctorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDoctorsTable,
      LocalDoctor,
      $$LocalDoctorsTableFilterComposer,
      $$LocalDoctorsTableOrderingComposer,
      $$LocalDoctorsTableAnnotationComposer,
      $$LocalDoctorsTableCreateCompanionBuilder,
      $$LocalDoctorsTableUpdateCompanionBuilder,
      (
        LocalDoctor,
        BaseReferences<_$AppDatabase, $LocalDoctorsTable, LocalDoctor>,
      ),
      LocalDoctor,
      PrefetchHooks Function()
    >;
typedef $$LocalProductRefsTableCreateCompanionBuilder =
    LocalProductRefsCompanion Function({
      Value<int> healixProductId,
      required String name,
      Value<String?> category,
      Value<String?> mrp,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<String> ingredientsJson,
      Value<String> benefitsJson,
      Value<String> status,
      required DateTime lastSyncedAt,
    });
typedef $$LocalProductRefsTableUpdateCompanionBuilder =
    LocalProductRefsCompanion Function({
      Value<int> healixProductId,
      Value<String> name,
      Value<String?> category,
      Value<String?> mrp,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<String> ingredientsJson,
      Value<String> benefitsJson,
      Value<String> status,
      Value<DateTime> lastSyncedAt,
    });

class $$LocalProductRefsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProductRefsTable> {
  $$LocalProductRefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get healixProductId => $composableBuilder(
    column: $table.healixProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mrp => $composableBuilder(
    column: $table.mrp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientsJson => $composableBuilder(
    column: $table.ingredientsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get benefitsJson => $composableBuilder(
    column: $table.benefitsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProductRefsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProductRefsTable> {
  $$LocalProductRefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get healixProductId => $composableBuilder(
    column: $table.healixProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mrp => $composableBuilder(
    column: $table.mrp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientsJson => $composableBuilder(
    column: $table.ingredientsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get benefitsJson => $composableBuilder(
    column: $table.benefitsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProductRefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProductRefsTable> {
  $$LocalProductRefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get healixProductId => $composableBuilder(
    column: $table.healixProductId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get mrp =>
      $composableBuilder(column: $table.mrp, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientsJson => $composableBuilder(
    column: $table.ingredientsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get benefitsJson => $composableBuilder(
    column: $table.benefitsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$LocalProductRefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProductRefsTable,
          LocalProductRef,
          $$LocalProductRefsTableFilterComposer,
          $$LocalProductRefsTableOrderingComposer,
          $$LocalProductRefsTableAnnotationComposer,
          $$LocalProductRefsTableCreateCompanionBuilder,
          $$LocalProductRefsTableUpdateCompanionBuilder,
          (
            LocalProductRef,
            BaseReferences<
              _$AppDatabase,
              $LocalProductRefsTable,
              LocalProductRef
            >,
          ),
          LocalProductRef,
          PrefetchHooks Function()
        > {
  $$LocalProductRefsTableTableManager(
    _$AppDatabase db,
    $LocalProductRefsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProductRefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProductRefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProductRefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> healixProductId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> mrp = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> ingredientsJson = const Value.absent(),
                Value<String> benefitsJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
              }) => LocalProductRefsCompanion(
                healixProductId: healixProductId,
                name: name,
                category: category,
                mrp: mrp,
                imageUrl: imageUrl,
                description: description,
                ingredientsJson: ingredientsJson,
                benefitsJson: benefitsJson,
                status: status,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> healixProductId = const Value.absent(),
                required String name,
                Value<String?> category = const Value.absent(),
                Value<String?> mrp = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> ingredientsJson = const Value.absent(),
                Value<String> benefitsJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime lastSyncedAt,
              }) => LocalProductRefsCompanion.insert(
                healixProductId: healixProductId,
                name: name,
                category: category,
                mrp: mrp,
                imageUrl: imageUrl,
                description: description,
                ingredientsJson: ingredientsJson,
                benefitsJson: benefitsJson,
                status: status,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalProductRefsTable, LocalProductRef>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalProductRefsTable,
                    LocalProductRef
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProductRefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProductRefsTable,
      LocalProductRef,
      $$LocalProductRefsTableFilterComposer,
      $$LocalProductRefsTableOrderingComposer,
      $$LocalProductRefsTableAnnotationComposer,
      $$LocalProductRefsTableCreateCompanionBuilder,
      $$LocalProductRefsTableUpdateCompanionBuilder,
      (
        LocalProductRef,
        BaseReferences<_$AppDatabase, $LocalProductRefsTable, LocalProductRef>,
      ),
      LocalProductRef,
      PrefetchHooks Function()
    >;
typedef $$LocalVisitsTableCreateCompanionBuilder =
    LocalVisitsCompanion Function({
      required String id,
      required String clientOperationId,
      required String doctorId,
      required DateTime visitDatetime,
      required String visitType,
      required String doctorResponse,
      required String prescriptionPotential,
      Value<String?> doctorFeedback,
      Value<String?> notes,
      Value<String> syncStatus,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalVisitsTableUpdateCompanionBuilder =
    LocalVisitsCompanion Function({
      Value<String> id,
      Value<String> clientOperationId,
      Value<String> doctorId,
      Value<DateTime> visitDatetime,
      Value<String> visitType,
      Value<String> doctorResponse,
      Value<String> prescriptionPotential,
      Value<String?> doctorFeedback,
      Value<String?> notes,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalVisitsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalVisitsTable> {
  $$LocalVisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientOperationId => $composableBuilder(
    column: $table.clientOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctorId => $composableBuilder(
    column: $table.doctorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitDatetime => $composableBuilder(
    column: $table.visitDatetime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitType => $composableBuilder(
    column: $table.visitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctorResponse => $composableBuilder(
    column: $table.doctorResponse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescriptionPotential => $composableBuilder(
    column: $table.prescriptionPotential,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctorFeedback => $composableBuilder(
    column: $table.doctorFeedback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalVisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalVisitsTable> {
  $$LocalVisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientOperationId => $composableBuilder(
    column: $table.clientOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctorId => $composableBuilder(
    column: $table.doctorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitDatetime => $composableBuilder(
    column: $table.visitDatetime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitType => $composableBuilder(
    column: $table.visitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctorResponse => $composableBuilder(
    column: $table.doctorResponse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescriptionPotential => $composableBuilder(
    column: $table.prescriptionPotential,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctorFeedback => $composableBuilder(
    column: $table.doctorFeedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalVisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalVisitsTable> {
  $$LocalVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientOperationId => $composableBuilder(
    column: $table.clientOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doctorId =>
      $composableBuilder(column: $table.doctorId, builder: (column) => column);

  GeneratedColumn<DateTime> get visitDatetime => $composableBuilder(
    column: $table.visitDatetime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visitType =>
      $composableBuilder(column: $table.visitType, builder: (column) => column);

  GeneratedColumn<String> get doctorResponse => $composableBuilder(
    column: $table.doctorResponse,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prescriptionPotential => $composableBuilder(
    column: $table.prescriptionPotential,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doctorFeedback => $composableBuilder(
    column: $table.doctorFeedback,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalVisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalVisitsTable,
          LocalVisit,
          $$LocalVisitsTableFilterComposer,
          $$LocalVisitsTableOrderingComposer,
          $$LocalVisitsTableAnnotationComposer,
          $$LocalVisitsTableCreateCompanionBuilder,
          $$LocalVisitsTableUpdateCompanionBuilder,
          (
            LocalVisit,
            BaseReferences<_$AppDatabase, $LocalVisitsTable, LocalVisit>,
          ),
          LocalVisit,
          PrefetchHooks Function()
        > {
  $$LocalVisitsTableTableManager(_$AppDatabase db, $LocalVisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalVisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientOperationId = const Value.absent(),
                Value<String> doctorId = const Value.absent(),
                Value<DateTime> visitDatetime = const Value.absent(),
                Value<String> visitType = const Value.absent(),
                Value<String> doctorResponse = const Value.absent(),
                Value<String> prescriptionPotential = const Value.absent(),
                Value<String?> doctorFeedback = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalVisitsCompanion(
                id: id,
                clientOperationId: clientOperationId,
                doctorId: doctorId,
                visitDatetime: visitDatetime,
                visitType: visitType,
                doctorResponse: doctorResponse,
                prescriptionPotential: prescriptionPotential,
                doctorFeedback: doctorFeedback,
                notes: notes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientOperationId,
                required String doctorId,
                required DateTime visitDatetime,
                required String visitType,
                required String doctorResponse,
                required String prescriptionPotential,
                Value<String?> doctorFeedback = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalVisitsCompanion.insert(
                id: id,
                clientOperationId: clientOperationId,
                doctorId: doctorId,
                visitDatetime: visitDatetime,
                visitType: visitType,
                doctorResponse: doctorResponse,
                prescriptionPotential: prescriptionPotential,
                doctorFeedback: doctorFeedback,
                notes: notes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalVisitsTable, LocalVisit>(table),
                  BaseReferences<_$AppDatabase, $LocalVisitsTable, LocalVisit>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalVisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalVisitsTable,
      LocalVisit,
      $$LocalVisitsTableFilterComposer,
      $$LocalVisitsTableOrderingComposer,
      $$LocalVisitsTableAnnotationComposer,
      $$LocalVisitsTableCreateCompanionBuilder,
      $$LocalVisitsTableUpdateCompanionBuilder,
      (
        LocalVisit,
        BaseReferences<_$AppDatabase, $LocalVisitsTable, LocalVisit>,
      ),
      LocalVisit,
      PrefetchHooks Function()
    >;
typedef $$LocalSyncQueueTableCreateCompanionBuilder =
    LocalSyncQueueCompanion Function({
      required String clientOperationId,
      required String entityType,
      required String payloadJson,
      Value<String> status,
      Value<int> retryCount,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalSyncQueueTableUpdateCompanionBuilder =
    LocalSyncQueueCompanion Function({
      Value<String> clientOperationId,
      Value<String> entityType,
      Value<String> payloadJson,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalSyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSyncQueueTable> {
  $$LocalSyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientOperationId => $composableBuilder(
    column: $table.clientOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSyncQueueTable> {
  $$LocalSyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientOperationId => $composableBuilder(
    column: $table.clientOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSyncQueueTable> {
  $$LocalSyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientOperationId => $composableBuilder(
    column: $table.clientOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalSyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSyncQueueTable,
          LocalSyncQueueData,
          $$LocalSyncQueueTableFilterComposer,
          $$LocalSyncQueueTableOrderingComposer,
          $$LocalSyncQueueTableAnnotationComposer,
          $$LocalSyncQueueTableCreateCompanionBuilder,
          $$LocalSyncQueueTableUpdateCompanionBuilder,
          (
            LocalSyncQueueData,
            BaseReferences<
              _$AppDatabase,
              $LocalSyncQueueTable,
              LocalSyncQueueData
            >,
          ),
          LocalSyncQueueData,
          PrefetchHooks Function()
        > {
  $$LocalSyncQueueTableTableManager(
    _$AppDatabase db,
    $LocalSyncQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientOperationId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncQueueCompanion(
                clientOperationId: clientOperationId,
                entityType: entityType,
                payloadJson: payloadJson,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientOperationId,
                required String entityType,
                required String payloadJson,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncQueueCompanion.insert(
                clientOperationId: clientOperationId,
                entityType: entityType,
                payloadJson: payloadJson,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSyncQueueTable, LocalSyncQueueData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalSyncQueueTable,
                    LocalSyncQueueData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSyncQueueTable,
      LocalSyncQueueData,
      $$LocalSyncQueueTableFilterComposer,
      $$LocalSyncQueueTableOrderingComposer,
      $$LocalSyncQueueTableAnnotationComposer,
      $$LocalSyncQueueTableCreateCompanionBuilder,
      $$LocalSyncQueueTableUpdateCompanionBuilder,
      (
        LocalSyncQueueData,
        BaseReferences<_$AppDatabase, $LocalSyncQueueTable, LocalSyncQueueData>,
      ),
      LocalSyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalAreasTableTableManager get localAreas =>
      $$LocalAreasTableTableManager(_db, _db.localAreas);
  $$LocalAssociationsTableTableManager get localAssociations =>
      $$LocalAssociationsTableTableManager(_db, _db.localAssociations);
  $$LocalDoctorsTableTableManager get localDoctors =>
      $$LocalDoctorsTableTableManager(_db, _db.localDoctors);
  $$LocalProductRefsTableTableManager get localProductRefs =>
      $$LocalProductRefsTableTableManager(_db, _db.localProductRefs);
  $$LocalVisitsTableTableManager get localVisits =>
      $$LocalVisitsTableTableManager(_db, _db.localVisits);
  $$LocalSyncQueueTableTableManager get localSyncQueue =>
      $$LocalSyncQueueTableTableManager(_db, _db.localSyncQueue);
}
