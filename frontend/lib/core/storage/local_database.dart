import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/storage/connection/connection.dart' as impl;

part 'local_database.g.dart';

// Sync states for offline-first replication
enum LocalSyncState {
  synced,
  pendingCreate,
  pendingUpdate,
  pendingDelete,
  failed,
}

// ---------------------------------------------------------------------------
// Table Definitions
// ---------------------------------------------------------------------------

class LocalAreas extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync Metadata
  TextColumn get syncState => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalAssociations extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync Metadata
  TextColumn get syncState => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalDoctors extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get normalizedPhone => text()();
  TextColumn get phone => text()();
  TextColumn get alternatePhone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get medicalLicenseNumber => text()();
  TextColumn get specialization => text()();
  TextColumn get qualification => text().nullable()();
  TextColumn get clinicName => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get areaId => text()();
  TextColumn get areaName => text().nullable()();
  TextColumn get associationId => text().nullable()();
  TextColumn get associationName => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync Metadata
  TextColumn get syncState => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalProductRefs extends Table {
  IntColumn get healixProductId => integer()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();
  TextColumn get mrp => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get ingredientsJson => text().withDefault(const Constant('[]'))();
  TextColumn get benefitsJson => text().withDefault(const Constant('[]'))();
  TextColumn get status => text().withDefault(const Constant('ACTIVE'))();
  DateTimeColumn get lastSyncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {healixProductId};
}

class LocalVisits extends Table {
  TextColumn get id => text()();
  TextColumn get clientOperationId => text().unique()();
  TextColumn get doctorId => text()();
  DateTimeColumn get visitDatetime => dateTime()();
  TextColumn get visitType => text()();
  TextColumn get doctorResponse => text()();
  TextColumn get prescriptionPotential => text()();
  TextColumn get doctorFeedback => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalSyncQueue extends Table {
  TextColumn get clientOperationId => text()();
  TextColumn get entityType => text()();
  TextColumn get payloadJson => text()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {clientOperationId};
}

// ---------------------------------------------------------------------------
// Drift Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    LocalAreas,
    LocalAssociations,
    LocalDoctors,
    LocalProductRefs,
    LocalVisits,
    LocalSyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? impl.connect());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  // --- Areas Operations ---
  Future<void> upsertAreas(List<LocalArea> areas) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(localAreas, areas);
    });
  }

  Future<List<LocalArea>> getAllAreas({bool? activeOnly}) {
    final query = select(localAreas);
    if (activeOnly != null) {
      query.where((t) => t.isActive.equals(activeOnly));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.get();
  }

  Future<LocalArea?> getAreaById(String id) {
    return (select(
      localAreas,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // --- Associations Operations ---
  Future<void> upsertAssociations(List<LocalAssociation> associations) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(localAssociations, associations);
    });
  }

  Future<List<LocalAssociation>> getAllAssociations({bool? activeOnly}) {
    final query = select(localAssociations);
    if (activeOnly != null) {
      query.where((t) => t.isActive.equals(activeOnly));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.get();
  }

  Future<LocalAssociation?> getAssociationById(String id) {
    return (select(
      localAssociations,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // --- Doctors Operations ---
  Future<void> upsertDoctors(List<LocalDoctor> doctors) async {
    // Avoid overwriting unsynced local modifications (pendingCreate, pendingUpdate)
    await batch((b) {
      for (final doc in doctors) {
        b.customStatement(
          'INSERT INTO local_doctors ('
          'id, name, normalized_phone, phone, alternate_phone, email, medical_license_number, '
          'specialization, qualification, clinic_name, address, area_id, area_name, '
          'association_id, association_name, is_active, notes, created_at, updated_at, '
          'sync_state, last_synced_at, server_updated_at, local_updated_at'
          ') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
          'ON CONFLICT(id) DO UPDATE SET '
          'name=excluded.name, normalized_phone=excluded.normalized_phone, phone=excluded.phone, '
          'alternate_phone=excluded.alternate_phone, email=excluded.email, '
          'medical_license_number=excluded.medical_license_number, specialization=excluded.specialization, '
          'qualification=excluded.qualification, clinic_name=excluded.clinic_name, address=excluded.address, '
          'area_id=excluded.area_id, area_name=excluded.area_name, association_id=excluded.association_id, '
          'association_name=excluded.association_name, is_active=excluded.is_active, notes=excluded.notes, '
          'updated_at=excluded.updated_at, server_updated_at=excluded.server_updated_at, '
          'last_synced_at=excluded.last_synced_at '
          "WHERE local_doctors.sync_state = 'synced'",
          [
            doc.id,
            doc.name,
            doc.normalizedPhone,
            doc.phone,
            doc.alternatePhone,
            doc.email,
            doc.medicalLicenseNumber,
            doc.specialization,
            doc.qualification,
            doc.clinicName,
            doc.address,
            doc.areaId,
            doc.areaName,
            doc.associationId,
            doc.associationName,
            doc.isActive ? 1 : 0,
            doc.notes,
            doc.createdAt.millisecondsSinceEpoch ~/ 1000,
            doc.updatedAt.millisecondsSinceEpoch ~/ 1000,
            doc.syncState,
            doc.lastSyncedAt != null
                ? doc.lastSyncedAt!.millisecondsSinceEpoch ~/ 1000
                : null,
            doc.serverUpdatedAt != null
                ? doc.serverUpdatedAt!.millisecondsSinceEpoch ~/ 1000
                : null,
            doc.localUpdatedAt != null
                ? doc.localUpdatedAt!.millisecondsSinceEpoch ~/ 1000
                : null,
          ],
        );
      }
    });
  }

  Future<void> saveLocalDoctor(LocalDoctor doctor) async {
    await into(localDoctors).insertOnConflictUpdate(doctor);
  }

  Future<LocalDoctor?> getDoctorById(String id) {
    return (select(
      localDoctors,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<LocalDoctor>> getDoctors({
    String? areaId,
    String? associationId,
    bool? activeOnly,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) {
    final query = select(localDoctors);

    if (areaId != null && areaId.isNotEmpty) {
      query.where((t) => t.areaId.equals(areaId));
    }
    if (associationId != null && associationId.isNotEmpty) {
      query.where((t) => t.associationId.equals(associationId));
    }
    if (activeOnly != null) {
      query.where((t) => t.isActive.equals(activeOnly));
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where(
        (t) =>
            t.name.lower().like(term) |
            t.phone.like(term) |
            t.medicalLicenseNumber.lower().like(term) |
            t.clinicName.lower().like(term) |
            t.specialization.lower().like(term),
      );
    }

    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    query.limit(limit, offset: offset);
    return query.get();
  }

  Future<int> countDoctors({
    String? areaId,
    String? associationId,
    bool? activeOnly,
    String? searchQuery,
  }) async {
    final query = selectOnly(localDoctors)
      ..addColumns([localDoctors.id.count()]);

    if (areaId != null && areaId.isNotEmpty) {
      query.where(localDoctors.areaId.equals(areaId));
    }
    if (associationId != null && associationId.isNotEmpty) {
      query.where(localDoctors.associationId.equals(associationId));
    }
    if (activeOnly != null) {
      query.where(localDoctors.isActive.equals(activeOnly));
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where(
        localDoctors.name.lower().like(term) |
            localDoctors.phone.like(term) |
            localDoctors.medicalLicenseNumber.lower().like(term) |
            localDoctors.clinicName.lower().like(term) |
            localDoctors.specialization.lower().like(term),
      );
    }

    final result = await query.getSingle();
    return result.read(localDoctors.id.count()) ?? 0;
  }

  Future<List<LocalDoctor>> getPendingSyncDoctors() {
    return (select(
      localDoctors,
    )..where((t) => t.syncState.isNotValue('synced'))).get();
  }

  Future<void> deleteDoctor(String id) {
    return (delete(localDoctors)..where((t) => t.id.equals(id))).go();
  }
}

// Global Drift Database Provider
final localDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
