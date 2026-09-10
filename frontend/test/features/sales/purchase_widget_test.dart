import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/theme/app_theme.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/core/widgets/metric_card.dart';
import 'package:rgwin_crm/features/sales/domain/pts_calculation_service.dart';
import 'package:rgwin_crm/features/sales/presentation/record_purchase_screen.dart';
import 'package:rgwin_crm/features/sales/presentation/sales_shell_screen.dart';
import 'package:rgwin_crm/features/visits/presentation/record_visit_screen.dart';

import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';
import 'package:rgwin_crm/features/visits/presentation/visit_controller.dart';

class _FakeDoctorController extends DoctorController {
  @override
  DoctorState build() => const DoctorState(isLoading: false);
}

class _FakePurchaseController extends PurchaseController {
  @override
  PurchaseState build() => const PurchaseState(isLoading: false);
}

class _FakeVisitController extends VisitController {
  @override
  VisitState build() => const VisitState(isLoading: false);
}

Widget createTestApp(Widget child) {
  return ProviderScope(
    overrides: [
      doctorControllerProvider.overrideWith(_FakeDoctorController.new),
      purchaseControllerProvider.overrideWith(_FakePurchaseController.new),
      visitControllerProvider.overrideWith(_FakeVisitController.new),
    ],
    child: MaterialApp(theme: AppTheme.lightTheme, home: child),
  );
}

void main() {
  group('PTS Calculation Architecture Tests', () {
    test('PTS calculation returns clean unconfigured placeholder', () {
      final result = PtsCalculationService.calculate(
        purchaseAmount: 50000.0,
        gstAmount: 9000.0,
      );

      expect(result.isConfigured, false);
      expect(result.rate, isNull);
      expect(result.value, isNull);
      expect(result.rateDisplayText, 'Not configured');
      expect(result.valueDisplayText, '—');
    });
  });

  group('Record Purchase Screen Tests', () {
    testWidgets(
      'Overall value entry calculates total and displays PTS placeholder',
      (tester) async {
        await tester.pumpWidget(createTestApp(const RecordPurchaseScreen()));
        await tester.pumpAndSettle();

        // Screen title
        expect(find.text('Record Purchase'), findsOneWidget);
        expect(find.text('Overall Purchase Value'), findsOneWidget);

        // Verify PTS placeholder is visible
        expect(find.text('PTS Rate'), findsOneWidget);
        expect(find.text('Not configured'), findsOneWidget);
        expect(find.text('PTS Value'), findsOneWidget);

        // Enter purchase amount
        final amountField = find.widgetWithText(TextField, 'e.g. 50000');
        await tester.enterText(amountField, '50000');
        await tester.pumpAndSettle();

        // Enter user-entered GST amount (Section 11: GST remains user-entered)
        final gstField = find.widgetWithText(TextField, 'e.g. 9000');
        await tester.enterText(gstField, '9000');
        await tester.pumpAndSettle();

        // Verify total payable is calculated (50000 + GST 9000 = 59,000)
        expect(find.text('Total Payable'), findsOneWidget);
        expect(find.text('₹59,000.00'), findsOneWidget);

        // Verify save button exists
        expect(find.widgetWithText(AppButton, 'Save Purchase'), findsOneWidget);
      },
    );
  });

  group('Record Visit Screen Tests', () {
    testWidgets('Renders fast one-handed visit logging form', (tester) async {
      await tester.pumpWidget(createTestApp(const RecordVisitScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Log Doctor Visit'), findsOneWidget);
      expect(find.text('Doctor & Clinic'), findsOneWidget);
      expect(find.text('Visit Schedule & Time'), findsOneWidget);
      expect(find.text("Doctor's Response"), findsOneWidget);
      expect(find.text('Immediate Purchase Opportunity?'), findsOneWidget);
      expect(find.text('Follow-up Required?'), findsOneWidget);

      // Save button
      expect(find.widgetWithText(AppButton, 'Save Visit'), findsOneWidget);
    });
  });

  group('Sales Shell Screen Tests', () {
    testWidgets(
      'Renders financial snapshot and displays P&L unavailable rule',
      (tester) async {
        await tester.pumpWidget(createTestApp(const SalesShellScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Sales & Commercials'), findsOneWidget);
        expect(find.text('Total Purchases'), findsOneWidget);
        expect(find.text('Realized Revenue'), findsOneWidget);

        // Verify Profit/Loss is marked as Insufficient data, never ₹0
        expect(find.text('Insufficient data'), findsOneWidget);
        expect(find.text('Formula pending'), findsOneWidget);

        // Empty state
        expect(find.text('No purchases recorded yet'), findsOneWidget);
        expect(find.text('Record Purchase'), findsWidgets);
      },
    );
  });

  group('MetricCard Widget Tests', () {
    testWidgets('Renders insufficient data when isUnavailable is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          const MetricCard(
            title: 'Profit / Loss',
            value: '0',
            icon: Icons.query_stats,
            isUnavailable: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profit / Loss'), findsOneWidget);
      expect(find.text('Insufficient data'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });
}
