import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/theme/app_theme.dart';
import 'package:rgwin_crm/core/widgets/discard_dialog.dart';
import 'package:rgwin_crm/features/auth/domain/models/user_model.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_controller.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_state.dart';
import 'package:rgwin_crm/features/dashboard/presentation/dashboard_shell_screen.dart';
import 'package:rgwin_crm/features/doctors/domain/models/doctor_model.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_detail_screen.dart';
import 'package:rgwin_crm/features/followups/presentation/follow_up_controller.dart';
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';
import 'package:rgwin_crm/features/sales/presentation/record_purchase_screen.dart';
import 'package:rgwin_crm/features/visits/presentation/record_visit_screen.dart';
import 'package:rgwin_crm/features/visits/presentation/visit_controller.dart';

final _testDoctor = DoctorModel(
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
  DoctorState build() => DoctorState(doctors: [_testDoctor], isLoading: false);
}

class _MockVisitController extends VisitController {
  @override
  VisitState build() => const VisitState(visits: [], isLoading: false);
}

class _MockPurchaseController extends PurchaseController {
  @override
  PurchaseState build() => const PurchaseState(purchases: [], isLoading: false);
}

class _MockFollowUpController extends FollowUpController {
  @override
  FollowUpState build() => const FollowUpState(followUps: [], isLoading: false);
}

class _MockAuthController extends AuthController {
  @override
  AuthState build() => const AuthState(
    status: AuthStatus.authenticated,
    user: UserModel(
      id: "mr_1",
      email: "mr@healix.com",
      fullName: "Harish Renganathan",
      role: "MR",
      status: "ACTIVE",
    ),
  );
}

Widget createTestApp(Widget child) {
  return ProviderScope(
    overrides: [
      doctorControllerProvider.overrideWith(_MockDoctorController.new),
      visitControllerProvider.overrideWith(_MockVisitController.new),
      purchaseControllerProvider.overrideWith(_MockPurchaseController.new),
      followUpControllerProvider.overrideWith(_MockFollowUpController.new),
      authProvider.overrideWith(_MockAuthController.new),
    ],
    child: MaterialApp(theme: AppTheme.lightTheme, home: child),
  );
}

void main() {
  group('Phase 4.1 Production UX Polish Tests', () {
    testWidgets('Discard dialog renders Cancel and Discard buttons', (
      tester,
    ) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  dialogResult = await showDiscardChangesDialog(context);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
      expect(
        find.text('Your entered information will be lost.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(dialogResult, false);

      // Re-open and tap Discard
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(dialogResult, true);
    });

    testWidgets('Doctor Profile screen renders explicit leading back button', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(DoctorDetailScreen(doctorId: _testDoctor.id)),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Back to Doctors'), findsOneWidget);
      expect(find.text('Doctor Profile'), findsOneWidget);
    });

    testWidgets(
      'Record Visit screen has leading back button and handles discard on dirty input',
      (tester) async {
        await tester.pumpWidget(
          createTestApp(
            const RecordVisitScreen(preselectedDoctorId: 'doc_test_1'),
          ),
        );
        await tester.pumpAndSettle();

        final backButton = find.byTooltip('Back');
        expect(backButton, findsOneWidget);

        // Type in notes to make it dirty
        final notesField = find.widgetWithText(
          TextField,
          'e.g. Prefers visits after 6 PM, interested in pediatric syrups',
        );
        await tester.enterText(notesField, 'New doctor visit notes');
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Discard dialog must be shown
        expect(find.text('Discard changes?'), findsOneWidget);

        // Cancel keeps the screen
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Log Doctor Visit'), findsOneWidget);
      },
    );

    testWidgets(
      'Record Purchase screen has leading back button and handles discard on dirty input',
      (tester) async {
        await tester.pumpWidget(
          createTestApp(
            const RecordPurchaseScreen(preselectedDoctorId: 'doc_test_1'),
          ),
        );
        await tester.pumpAndSettle();

        final backButton = find.byTooltip('Back');
        expect(backButton, findsOneWidget);

        // Enter amount to make it dirty
        final amountField = find.widgetWithText(TextField, 'e.g. 50000');
        await tester.enterText(amountField, '25000');
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Discard dialog must be shown
        expect(find.text('Discard changes?'), findsOneWidget);

        // Cancel keeps the screen
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Record Purchase'), findsOneWidget);
      },
    );

    testWidgets(
      'Dashboard displays authenticated user greeting dynamically without hardcoding',
      (tester) async {
        await tester.pumpWidget(createTestApp(const DashboardShellScreen()));
        await tester.pumpAndSettle();

        // Greeting with user's first name
        expect(find.textContaining('Harish'), findsOneWidget);
        expect(find.text('Field Sales Overview'), findsOneWidget);

        // 4 Overview cards exist
        expect(find.text("Today's Visits"), findsOneWidget);
        expect(find.text("Today's Purchases"), findsOneWidget);
        expect(find.text('Follow-ups'), findsOneWidget);
        expect(find.text('Doctors'), findsOneWidget);

        // Period switching
        expect(find.text('This Week'), findsOneWidget);
        await tester.tap(find.text('This Week'));
        await tester.pumpAndSettle();

        expect(find.text('Weekly Visits'), findsOneWidget);
        expect(find.text('Weekly Purchases'), findsOneWidget);
      },
    );
  });
}
