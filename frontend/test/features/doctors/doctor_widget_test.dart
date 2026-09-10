import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/theme/app_theme.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/features/doctors/data/doctor_api_service.dart';
import 'package:rgwin_crm/features/doctors/data/doctor_repository.dart';
import 'package:rgwin_crm/features/doctors/domain/models/area_model.dart';
import 'package:rgwin_crm/features/doctors/domain/models/association_model.dart';
import 'package:rgwin_crm/features/doctors/domain/models/doctor_model.dart';
import 'package:rgwin_crm/features/doctors/presentation/add_edit_doctor_screen.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_detail_screen.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctors_shell_screen.dart';

class MockDoctorRepository implements DoctorRepository {
  List<DoctorModel> mockDoctors = [];
  List<AreaModel> mockAreas = [];
  List<AssociationModel> mockAssociations = [];
  bool isOfflineMode = false;
  bool throwDuplicateOnCreate = false;

  @override
  get db => throw UnimplementedError();

  @override
  Future<List<AreaModel>> getAreas({bool? isActive}) async => mockAreas;

  @override
  Future<List<AssociationModel>> getAssociations({bool? isActive}) async =>
      mockAssociations;

  @override
  Future<DoctorListResult> getDoctors({
    String? areaId,
    String? associationId,
    String? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    var filtered = List<DoctorModel>.from(mockDoctors);

    if (areaId != null && areaId.isNotEmpty) {
      filtered = filtered.where((d) => d.areaId == areaId).toList();
    }
    if (associationId != null && associationId.isNotEmpty) {
      filtered = filtered
          .where((d) => d.associationId == associationId)
          .toList();
    }
    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((d) => d.status == status).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final term = search.trim().toLowerCase();
      filtered = filtered
          .where(
            (d) =>
                d.name.toLowerCase().contains(term) ||
                d.clinicName?.toLowerCase().contains(term) == true ||
                d.phone.contains(term),
          )
          .toList();
    }

    return DoctorListResult(
      doctors: filtered,
      total: filtered.length,
      isOffline: isOfflineMode,
    );
  }

  @override
  Future<DoctorModel> getDoctorById(String id) async {
    return mockDoctors.firstWhere((d) => d.id == id);
  }

  @override
  Future<Map<String, dynamic>> checkDuplicate({
    String? phone,
    String? medicalLicenseNumber,
    String? excludeDoctorId,
  }) async {
    if (throwDuplicateOnCreate) {
      return {
        'is_duplicate': true,
        'duplicate_field': 'phone',
        'message': 'Phone is duplicate',
      };
    }
    return {'is_duplicate': false};
  }

  @override
  Future<DoctorModel> createDoctor(Map<String, dynamic> payload) async {
    if (throwDuplicateOnCreate) {
      throw DuplicateDoctorException(
        message: 'Phone number is already registered to Dr. Existing.',
        field: 'phone',
        existingDoctorName: 'Dr. Existing',
      );
    }

    final newDoc = DoctorModel(
      id: 'doc_new_${mockDoctors.length + 1}',
      name: payload['name'] as String,
      phone: payload['phone'] as String,
      medicalLicenseNumber: payload['medical_license_number'] as String,
      specialization: payload['specialization'] as String,
      clinicName: payload['clinic_name'] as String?,
      areaId: payload['area_id'] as String,
      status: 'ACTIVE',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncState: isOfflineMode ? 'pendingCreate' : 'synced',
    );
    mockDoctors.add(newDoc);
    return newDoc;
  }

  @override
  Future<DoctorModel> updateDoctor(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final index = mockDoctors.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updated = mockDoctors[index].copyWith(
        name: payload['name'] as String?,
        phone: payload['phone'] as String?,
        specialization: payload['specialization'] as String?,
        clinicName: payload['clinic_name'] as String?,
      );
      mockDoctors[index] = updated;
      return updated;
    }
    throw Exception('Doctor not found');
  }

  @override
  Future<DoctorModel> setDoctorStatus(String id, String status) async {
    final index = mockDoctors.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updated = mockDoctors[index].copyWith(
        status: status,
        isActive: status == 'ACTIVE',
      );
      mockDoctors[index] = updated;
      return updated;
    }
    throw Exception('Doctor not found');
  }
}

void main() {
  late MockDoctorRepository mockRepo;
  late AreaModel sampleArea;
  late AssociationModel sampleAssoc;
  late DoctorModel sampleDoctor;

  setUp(() {
    mockRepo = MockDoctorRepository();
    final now = DateTime.now();

    sampleArea = AreaModel(
      id: 'area_1',
      name: 'Anna Nagar',
      code: 'CHEN-AN-01',
      status: 'ACTIVE',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    sampleAssoc = AssociationModel(
      id: 'assoc_1',
      name: 'Indian Medical Association',
      code: 'IMA',
      status: 'ACTIVE',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    sampleDoctor = DoctorModel(
      id: 'doc_1',
      name: 'Dr. Anitha Ramesh',
      phone: '+919876543210',
      medicalLicenseNumber: 'MCI/2012/12345',
      specialization: 'Cardiology',
      clinicName: 'Apollo Heart Clinic',
      areaId: 'area_1',
      areaName: 'Anna Nagar',
      associationId: 'assoc_1',
      associationName: 'IMA',
      status: 'ACTIVE',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    mockRepo.mockAreas = [sampleArea];
    mockRepo.mockAssociations = [sampleAssoc];
    mockRepo.mockDoctors = [sampleDoctor];
  });

  Widget createTestWidget(Widget child, {List<dynamic> overrides = const []}) {
    return ProviderScope(
      overrides: [
        doctorRepositoryProvider.overrideWithValue(mockRepo),
        ...overrides,
      ],
      child: MaterialApp(theme: AppTheme.lightTheme, home: child),
    );
  }

  group('Doctor Directory Widget Tests', () {
    testWidgets(
      'Renders Doctor Directory title, cards, specialization, and clinic',
      (tester) async {
        await tester.pumpWidget(createTestWidget(const DoctorsShellScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Doctor Directory'), findsOneWidget);
        expect(find.text('1 doctor enrolled'), findsOneWidget);
        expect(find.text('Dr. Anitha Ramesh'), findsOneWidget);
        expect(find.text('Cardiology'), findsOneWidget);
        expect(find.text('Apollo Heart Clinic'), findsOneWidget);
        expect(find.text('+919876543210'), findsOneWidget);
        expect(find.byKey(const Key('add_doctor_fab')), findsOneWidget);
      },
    );

    testWidgets('Search query filters doctor list dynamically', (tester) async {
      mockRepo.mockDoctors = [
        sampleDoctor,
        DoctorModel(
          id: 'doc_2',
          name: 'Dr. Bala Kumar',
          phone: '+919811122233',
          medicalLicenseNumber: 'MCI/2015/67890',
          specialization: 'Pediatrics',
          clinicName: 'Children Hospital',
          areaId: 'area_1',
          status: 'ACTIVE',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(createTestWidget(const DoctorsShellScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Anitha Ramesh'), findsOneWidget);
      expect(find.text('Dr. Bala Kumar'), findsOneWidget);

      // Type search query
      await tester.enterText(find.byType(TextField), 'Bala');
      await tester.pumpAndSettle();

      expect(find.text('Dr. Bala Kumar'), findsOneWidget);
      expect(find.text('Dr. Anitha Ramesh'), findsNothing);
    });

    testWidgets('Displays empty state when no doctors match', (tester) async {
      mockRepo.mockDoctors = [];

      await tester.pumpWidget(createTestWidget(const DoctorsShellScreen()));
      await tester.pumpAndSettle();

      expect(find.text('No doctors found'), findsOneWidget);
      expect(
        find.text('Add Doctor'),
        findsNWidgets(2),
      ); // FAB + Empty state action
    });

    testWidgets('Displays offline banner when isOffline is true', (
      tester,
    ) async {
      mockRepo.isOfflineMode = true;

      await tester.pumpWidget(createTestWidget(const DoctorsShellScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('Offline Mode — Showing cached doctor data'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });
  });

  group('Add Doctor Screen Tests', () {
    testWidgets('Displays validation errors on empty submission', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const AddEditDoctorScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Add New Doctor'), findsOneWidget);

      // Tap Enroll Doctor button without entering fields
      await tester.tap(find.widgetWithText(AppButton, 'Enroll Doctor'));
      await tester.pumpAndSettle();

      expect(find.text('Doctor name is required'), findsOneWidget);
      expect(find.text('Medical license number is required'), findsOneWidget);
      expect(find.text('Specialization is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);
    });

    testWidgets(
      'Displays duplicate warning banner when duplicate error occurs',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        mockRepo.throwDuplicateOnCreate = true;

        await tester.pumpWidget(createTestWidget(const AddEditDoctorScreen()));
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Dr. Duplicate Test'); // Name
        await tester.enterText(textFields.at(1), 'MCI-DUP-01'); // License
        await tester.enterText(
          textFields.at(2),
          'Cardiology',
        ); // Specialization
        await tester.enterText(textFields.at(4), '9876543210'); // Phone

        // Select territory area from dropdown
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Anna Nagar (CHEN-AN-01)').last);
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(AppButton, 'Enroll Doctor'));
        await tester.pumpAndSettle();

        // Verify Duplicate Warning Banner rendered
        expect(find.text('Duplicate Doctor Warning'), findsOneWidget);
        expect(
          find.text('Phone number is already registered to Dr. Existing.'),
          findsOneWidget,
        );
      },
    );
  });

  group('Doctor Detail Screen Tests', () {
    testWidgets('Renders credentials, quick actions and Phase 4 placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(DoctorDetailScreen(doctorId: sampleDoctor.id)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Anitha Ramesh'), findsOneWidget);
      expect(find.text('Cardiology'), findsWidgets);
      expect(find.text('ACTIVE'), findsOneWidget);

      // Quick action buttons
      expect(find.widgetWithText(AppButton, 'Call'), findsOneWidget);

      // Credentials & Territory
      expect(find.text('MCI/2012/12345'), findsOneWidget);
      expect(find.text('Anna Nagar'), findsOneWidget);
      expect(find.text('IMA'), findsOneWidget);

      // Phase 4 Visits Placeholder
      expect(find.text('Visits & Product Interactions'), findsOneWidget);
      expect(
        find.text(
          'Coming in Phase 4 — Field visits, discussed products, sample distributions, and prescription tracking.',
        ),
        findsOneWidget,
      );

      // Edit Button
      expect(
        find.widgetWithText(AppButton, 'Edit Doctor Details'),
        findsOneWidget,
      );
    });
  });
}
