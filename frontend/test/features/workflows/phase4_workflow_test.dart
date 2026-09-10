import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/theme/app_theme.dart';
import 'package:rgwin_crm/features/doctors/domain/models/doctor_model.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_detail_screen.dart';
import 'package:rgwin_crm/features/followups/domain/models/follow_up_model.dart';
import 'package:rgwin_crm/features/followups/presentation/follow_up_controller.dart';
import 'package:rgwin_crm/features/followups/presentation/followups_shell_screen.dart';
import 'package:rgwin_crm/features/sales/domain/models/purchase_model.dart';
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';
import 'package:rgwin_crm/features/sales/presentation/record_purchase_screen.dart';
import 'package:rgwin_crm/features/sales/presentation/sales_shell_screen.dart';
import 'package:rgwin_crm/features/visits/domain/models/visit_model.dart';
import 'package:rgwin_crm/features/visits/presentation/record_visit_screen.dart';
import 'package:rgwin_crm/features/visits/presentation/visit_controller.dart';

final testDoctor = DoctorModel(
  id: "doc_test_1",
  name: "Dr. Arvind Swamy",
  phone: "+919876543210",
  medicalLicenseNumber: "MCI-55443",
  specialization: "Cardiology",
  clinicName: "Swamy Heart Centre",
  areaId: "area_1",
  areaName: "North Zone",
  status: "ACTIVE",
  isActive: true,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

class _MockDoctorController extends DoctorController {
  @override
  DoctorState build() => DoctorState(doctors: [testDoctor], isLoading: false);
}

class _MockVisitController extends VisitController {
  @override
  VisitState build() => VisitState(
    visits: [
      VisitModel(
        id: "vst_1",
        doctorId: "doc_test_1",
        doctorName: "Dr. Arvind Swamy",
        clinicName: "Swamy Heart Centre",
        visitDatetime: DateTime(2026, 9, 10, 10, 30),
        doctorResponse: "POSITIVE",
        discussedProducts: "Discussed Healix-500 efficacy",
        samplesGiven: "2 sample boxes",
        status: "COMPLETED",
      ),
    ],
    isLoading: false,
  );
}

class _MockPurchaseController extends PurchaseController {
  @override
  PurchaseState build() => PurchaseState(
    purchases: [
      PurchaseModel(
        id: "pch_1",
        doctorId: "doc_test_1",
        doctorName: "Dr. Arvind Swamy",
        clinicName: "Swamy Heart Centre",
        purchaseDate: DateTime(2026, 9, 11),
        purchaseAmount: 50000.0,
        gstAmount: 9000.0,
        totalAmount: 59000.0,
        ptsRate: null,
        ptsValue: null,
        status: "CONFIRMED",
        createdAt: DateTime(2026, 9, 11),
      ),
    ],
    isLoading: false,
  );
}

class _MockFollowUpController extends FollowUpController {
  @override
  FollowUpState build() => FollowUpState(
    followUps: [
      FollowUpModel(
        id: "fu_1",
        doctorId: "doc_test_1",
        doctorName: "Dr. Arvind Swamy",
        clinicName: "Swamy Heart Centre",
        dueDate: DateTime(2026, 9, 15),
        taskReason: "Call regarding stockist purchase requirement",
        status: "PENDING",
        syncStatus: "SYNCED",
      ),
    ],
    isLoading: false,
  );
}

Widget createWorkflowApp(Widget child) {
  return ProviderScope(
    overrides: [
      doctorControllerProvider.overrideWith(_MockDoctorController.new),
      visitControllerProvider.overrideWith(_MockVisitController.new),
      purchaseControllerProvider.overrideWith(_MockPurchaseController.new),
      followUpControllerProvider.overrideWith(_MockFollowUpController.new),
    ],
    child: MaterialApp(theme: AppTheme.lightTheme, home: child),
  );
}

void main() {
  group('Phase 4 Field Workflow Widget Tests', () {
    testWidgets('Visit Logging reveals Record Purchase and Follow-up options', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWorkflowApp(
          const RecordVisitScreen(preselectedDoctorId: "doc_test_1"),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Log Doctor Visit'), findsOneWidget);
      expect(find.text('Immediate Purchase Opportunity?'), findsOneWidget);
      expect(find.text('Follow-up Required?'), findsOneWidget);

      // Toggle Immediate Purchase Opportunity
      final purchaseToggle = find.widgetWithText(
        SwitchListTile,
        'Immediate Purchase Opportunity?',
      );
      await tester.ensureVisible(purchaseToggle);
      await tester.pumpAndSettle();
      await tester.tap(purchaseToggle);
      await tester.pumpAndSettle();

      // Record Purchase button appears
      expect(find.text('Record Purchase'), findsOneWidget);

      // Toggle Follow-up Required
      final followUpToggle = find.widgetWithText(
        SwitchListTile,
        'Follow-up Required?',
      );
      await tester.ensureVisible(followUpToggle);
      await tester.pumpAndSettle();
      await tester.tap(followUpToggle);
      await tester.pumpAndSettle();

      // Next Follow-up Date and Follow-up Task field appear
      expect(find.text('Next Follow-up Date'), findsOneWidget);
      expect(find.text('Follow-up Task'), findsOneWidget);
    });

    testWidgets(
      'Record Purchase enforces user-entered GST and PTS placeholder',
      (tester) async {
        await tester.pumpWidget(
          createWorkflowApp(
            const RecordPurchaseScreen(preselectedDoctorId: "doc_test_1"),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Record Purchase'), findsOneWidget);
        expect(find.text('Not configured'), findsOneWidget);
        expect(find.text('—'), findsOneWidget);

        // Enter amount 50000
        final amountField = find.widgetWithText(TextField, 'e.g. 50000');
        await tester.enterText(amountField, '50000');
        await tester.pumpAndSettle();

        // Enter GST 9000
        final gstField = find.widgetWithText(TextField, 'e.g. 9000');
        await tester.enterText(gstField, '9000');
        await tester.pumpAndSettle();

        // Total must be 59,000.00
        expect(find.text('₹59,000.00'), findsOneWidget);
      },
    );

    testWidgets(
      'Follow-up screen renders tabs and cards with clean status chips',
      (tester) async {
        await tester.pumpWidget(
          createWorkflowApp(const FollowupsShellScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Follow-up Tasks'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Pending'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
        expect(
          find.text('Call regarding stockist purchase requirement'),
          findsOneWidget,
        );
        expect(find.text('Dr. Arvind Swamy'), findsOneWidget);
      },
    );

    testWidgets(
      'Doctor Detail screen renders Activity Timeline and Upcoming Follow-ups',
      (tester) async {
        await tester.pumpWidget(
          createWorkflowApp(DoctorDetailScreen(doctorId: testDoctor.id)),
        );
        await tester.pumpAndSettle();

        // Header and Doctor Info
        expect(find.text('Dr. Arvind Swamy'), findsOneWidget);

        // Upcoming Follow-ups widget
        expect(find.text('Upcoming Follow-ups'), findsOneWidget);
        expect(
          find.text('Call regarding stockist purchase requirement'),
          findsNWidgets(2),
        );

        // Relationship Activity Timeline (Visits, Purchases, Follow-ups)
        expect(find.text('Relationship Activity Timeline'), findsOneWidget);
        expect(find.text('Visit'), findsAtLeastNWidgets(1));
        expect(find.text('Discussed Healix-500 efficacy'), findsOneWidget);
        expect(find.text('Purchase'), findsAtLeastNWidgets(1));
        expect(find.text('₹50,000.00 + GST'), findsOneWidget);

        // Commercial Summary with authoritative PTS placeholder
        expect(find.text('Purchase & Commercial Summary'), findsOneWidget);
        expect(find.text('Not configured'), findsOneWidget);
        expect(find.text('Revenue unavailable'), findsOneWidget);
        expect(find.text('Insufficient data'), findsOneWidget);
      },
    );

    testWidgets(
      'Sales screen shows compact purchase records with PTS unconfigured',
      (tester) async {
        await tester.pumpWidget(createWorkflowApp(const SalesShellScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Sales & Commercials'), findsOneWidget);
        expect(find.text('Total: ₹59,000.00'), findsOneWidget);
        expect(find.text('PTS: Not configured'), findsOneWidget);
        expect(find.text('Dr. Arvind Swamy'), findsOneWidget);
      },
    );
  });
}
