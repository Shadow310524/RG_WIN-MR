import 'package:drift/drift.dart';

// Tables for offline field persistence
class LocalProductRefs extends Table {
  IntColumn get healixProductId => integer()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();
  TextColumn get mrp => text().nullable()(); // Null when unavailable
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
  TextColumn get id => text()(); // UUID
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
