import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/storage/local_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // In-memory Drift SQLite database for test isolation
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift Offline SQLite Database Tests', () {
    test('Can insert and query LocalArea with sync metadata', () async {
      final now = DateTime.now();
      final area = LocalArea(
        id: 'area_1',
        name: 'Anna Nagar',
        code: 'CHEN-AN-01',
        description: 'Doctor cluster',
        isActive: true,
        createdAt: now,
        updatedAt: now,
        syncState: 'synced',
        lastSyncedAt: now,
        serverUpdatedAt: now,
        localUpdatedAt: now,
      );

      await db.upsertAreas([area]);
      final retrieved = await db.getAreaById('area_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Anna Nagar');
      expect(retrieved.code, 'CHEN-AN-01');
      expect(retrieved.syncState, 'synced');
    });

    test('Can insert and query LocalAssociation with sync metadata', () async {
      final now = DateTime.now();
      final assoc = LocalAssociation(
        id: 'assoc_1',
        name: 'Indian Medical Association',
        code: 'IMA',
        description: 'National doctors body',
        isActive: true,
        createdAt: now,
        updatedAt: now,
        syncState: 'synced',
        lastSyncedAt: now,
        serverUpdatedAt: now,
        localUpdatedAt: now,
      );

      await db.upsertAssociations([assoc]);
      final retrieved = await db.getAssociationById('assoc_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Indian Medical Association');
      expect(retrieved.code, 'IMA');
    });

    test('Can insert, search, filter and count LocalDoctors', () async {
      final now = DateTime.now();
      final doc1 = LocalDoctor(
        id: 'doc_1',
        name: 'Dr. Anitha Ramesh',
        normalizedPhone: '9876543210',
        phone: '+91 98765 43210',
        alternatePhone: '044-24567890',
        email: 'anitha@apollo.com',
        medicalLicenseNumber: 'MCI-12345',
        specialization: 'Cardiology',
        qualification: 'MBBS, MD',
        clinicName: 'Apollo Heart Clinic',
        address: 'Greams Road, Chennai',
        areaId: 'area_1',
        areaName: 'Anna Nagar',
        associationId: 'assoc_1',
        associationName: 'IMA',
        isActive: true,
        notes: 'VIP Doctor',
        createdAt: now,
        updatedAt: now,
        syncState: 'synced',
        lastSyncedAt: now,
        serverUpdatedAt: now,
        localUpdatedAt: now,
      );

      final doc2 = LocalDoctor(
        id: 'doc_2',
        name: 'Dr. Bala Kumar',
        normalizedPhone: '9811122233',
        phone: '+91 98111 22233',
        medicalLicenseNumber: 'MCI-54321',
        specialization: 'Pediatrics',
        clinicName: 'Children Clinic',
        areaId: 'area_2',
        areaName: 'T Nagar',
        isActive: false,
        createdAt: now,
        updatedAt: now,
        syncState: 'synced',
      );

      await db.saveLocalDoctor(doc1);
      await db.saveLocalDoctor(doc2);

      // Search by name
      final searchResults = await db.getDoctors(searchQuery: 'Anitha');
      expect(searchResults.length, 1);
      expect(searchResults.first.name, 'Dr. Anitha Ramesh');

      // Search by clinic
      final clinicResults = await db.getDoctors(searchQuery: 'Children');
      expect(clinicResults.length, 1);
      expect(clinicResults.first.name, 'Dr. Bala Kumar');

      // Filter by area
      final areaResults = await db.getDoctors(areaId: 'area_1');
      expect(areaResults.length, 1);
      expect(areaResults.first.id, 'doc_1');

      // Filter active only
      final activeResults = await db.getDoctors(activeOnly: true);
      expect(activeResults.length, 1);
      expect(activeResults.first.id, 'doc_1');

      // Total count
      final total = await db.countDoctors();
      expect(total, 2);
    });

    test('Pending sync tracking and protecting unsynced changes', () async {
      final now = DateTime.now();
      // Offline created doctor
      final pendingDoc = LocalDoctor(
        id: 'doc_offline_1',
        name: 'Dr. Offline Created',
        normalizedPhone: '9555544444',
        phone: '+91 95555 44444',
        medicalLicenseNumber: 'MCI-OFFLINE-01',
        specialization: 'General',
        areaId: 'area_1',
        isActive: true,
        createdAt: now,
        updatedAt: now,
        syncState: 'pendingCreate',
      );

      await db.saveLocalDoctor(pendingDoc);

      // Verify it is flagged in pending sync list
      final pendingList = await db.getPendingSyncDoctors();
      expect(pendingList.length, 1);
      expect(pendingList.first.id, 'doc_offline_1');
      expect(pendingList.first.syncState, 'pendingCreate');

      // Attempting to upsert a synced remote doctor with same ID must NOT overwrite the pending local doctor
      final remoteSyncedVersion = LocalDoctor(
        id: 'doc_offline_1',
        name: 'Dr. Remote Overwrite Attempt',
        normalizedPhone: '9555544444',
        phone: '+91 95555 44444',
        medicalLicenseNumber: 'MCI-OFFLINE-01',
        specialization: 'General',
        areaId: 'area_1',
        isActive: true,
        createdAt: now,
        updatedAt: now,
        syncState: 'synced',
      );

      await db.upsertDoctors([remoteSyncedVersion]);

      final preservedDoc = await db.getDoctorById('doc_offline_1');
      expect(preservedDoc, isNotNull);
      expect(preservedDoc!.name, 'Dr. Offline Created'); // Still local version!
      expect(preservedDoc.syncState, 'pendingCreate');
    });
  });
}
