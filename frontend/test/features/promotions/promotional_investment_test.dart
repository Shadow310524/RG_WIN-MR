import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/theme/app_theme.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/features/doctors/domain/models/doctor_model.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_detail_screen.dart';
import 'package:rgwin_crm/features/promotions/domain/models/promotional_investment_model.dart';
import 'package:rgwin_crm/features/promotions/presentation/promotional_investment_controller.dart';
import 'package:rgwin_crm/features/promotions/presentation/record_promotional_investment_dialog.dart';
import 'package:rgwin_crm/features/sales/domain/models/purchase_model.dart';
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';
import 'package:rgwin_crm/features/visits/presentation/record_visit_screen.dart';
import 'package:rgwin_crm/features/visits/presentation/visit_controller.dart';

class _FakeDoctorController extends DoctorController {
  final DoctorModel _doctor;
  _FakeDoctorController(this._doctor);

  @override
  DoctorState build() => DoctorState(isLoading: false, doctors: [_doctor]);
}

class _FakePurchaseController extends PurchaseController {
  final List<PurchaseModel> _purchases;
  _FakePurchaseController(this._purchases);

  @override
  PurchaseState build() =>
      PurchaseState(isLoading: false, purchases: _purchases);
}

class _FakeVisitController extends VisitController {
  @override
  VisitState build() => const VisitState(isLoading: false);
}

class _FakePromotionalInvestmentController
    extends PromotionalInvestmentController {
  final List<PromotionalInvestmentModel> _investments;
  _FakePromotionalInvestmentController(this._investments);

  @override
  PromotionalInvestmentState build() =>
      PromotionalInvestmentState(isLoading: false, investments: _investments);
}

void main() {
  final now = DateTime.now();
  final sampleDoctor = DoctorModel(
    id: 'doc_123',
    name: 'Dr. Vikram Seth',
    phone: '+919876543210',
    medicalLicenseNumber: 'MCI/2015/99887',
    specialization: 'Cardiology',
    clinicName: 'City Heart Center',
    areaId: 'area_1',
    areaName: 'Central Zone',
    status: 'ACTIVE',
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );

  final sampleInvestment = PromotionalInvestmentModel(
    id: 'inv_1',
    doctorId: 'doc_123',
    doctorName: 'Dr. Vikram Seth',
    amount: 1500.00,
    investmentType: 'SAMPLE',
    investmentDate: now,
    notes: 'Sample pack for trial',
    provenanceSource: 'EXPLICIT_PROMOTIONAL_INVESTMENT',
    syncState: 'synced',
    createdAt: now,
  );

  final samplePurchase = PurchaseModel(
    id: 'pur_1',
    doctorId: 'doc_123',
    doctorName: 'Dr. Vikram Seth',
    purchaseAmount: 25000.0,
    gstAmount: 4500.0,
    totalAmount: 29500.0,
    purchaseDate: now,
    syncState: 'synced',
    createdAt: now,
  );

  Widget createTestWidget(
    Widget child, {
    List<PromotionalInvestmentModel> investments = const [],
    List<PurchaseModel> purchases = const [],
  }) {
    return ProviderScope(
      overrides: [
        doctorControllerProvider.overrideWith(
          () => _FakeDoctorController(sampleDoctor),
        ),
        purchaseControllerProvider.overrideWith(
          () => _FakePurchaseController(purchases),
        ),
        visitControllerProvider.overrideWith(_FakeVisitController.new),
        promotionalInvestmentControllerProvider.overrideWith(
          () => _FakePromotionalInvestmentController(investments),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  group('PromotionalInvestmentModel Tests', () {
    test(
      'Correctly serializes and deserializes with provenance and type label',
      () {
        final json = {
          'id': 'inv_99',
          'doctor_id': 'doc_123',
          'doctor_name': 'Dr. Vikram Seth',
          'amount': 2400.50,
          'investment_type': 'FREE_SUPPLY',
          'investment_date': '2026-09-11',
          'notes': 'Free diagnostic strips',
          'provenance_source': 'EXPLICIT_PROMOTIONAL_INVESTMENT',
          'sync_state': 'synced',
          'created_at': '2026-09-11T10:00:00Z',
        };

        final model = PromotionalInvestmentModel.fromJson(json);
        expect(model.id, 'inv_99');
        expect(model.doctorId, 'doc_123');
        expect(model.amount, 2400.50);
        expect(model.investmentType, 'FREE_SUPPLY');
        expect(model.typeDisplay, 'Free Supply');
        expect(model.provenanceSource, 'EXPLICIT_PROMOTIONAL_INVESTMENT');

        final serialized = model.toJson();
        expect(serialized['amount'], 2400.50);
        expect(serialized['investment_type'], 'FREE_SUPPLY');
        expect(
          serialized['provenance_source'],
          'EXPLICIT_PROMOTIONAL_INVESTMENT',
        );
      },
    );
  });

  group('RecordPromotionalInvestmentDialog Widget Tests', () {
    testWidgets('Renders all investment type chips, amount input, and notes', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RecordPromotionalInvestmentModal(
            doctorId: sampleDoctor.id,
            doctorName: sampleDoctor.name,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Record Promotional Investment'), findsOneWidget);
      expect(find.text('Dr. Vikram Seth'), findsOneWidget);

      // Investment type chips
      expect(find.text('Sample'), findsOneWidget);
      expect(find.text('Promotional Unit'), findsOneWidget);
      expect(find.text('Free Supply'), findsOneWidget);
      expect(find.text('Material'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);

      // Monetary amount input
      expect(find.text('Monetary Investment (₹)'), findsOneWidget);
      final amountField = find.widgetWithText(TextField, 'e.g. 750');
      expect(amountField, findsOneWidget);

      await tester.enterText(amountField, '2500');
      await tester.pumpAndSettle();

      // Submit button
      expect(
        find.widgetWithText(AppButton, 'Save Promotional Investment'),
        findsOneWidget,
      );
    });
  });

  group('Doctor Detail Screen Commercial Section Tests', () {
    testWidgets(
      'Displays Business Value vs Promotional Spend and Investment History',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            DoctorDetailScreen(doctorId: sampleDoctor.id),
            investments: [sampleInvestment],
            purchases: [samplePurchase],
          ),
        );
        await tester.pumpAndSettle();

        // Header
        expect(find.text('Purchase & Commercial Summary'), findsOneWidget);
        expect(
          find.text('Commercial Worth: Business Value vs Promotional Spend'),
          findsOneWidget,
        );

        // Provenance banner
        expect(
          find.textContaining('Provenance: General field expenses'),
          findsOneWidget,
        );

        // Business value & promo investment metrics
        expect(find.text('Business Value (Purchases)'), findsOneWidget);
        expect(find.text('₹25,000.00'), findsOneWidget);
        expect(find.text('Promotional Investment'), findsOneWidget);
        expect(find.text('₹1,500.00'), findsWidgets);

        // Honest placeholders
        expect(find.text('Realized Revenue'), findsOneWidget);
        expect(find.text('Revenue unavailable'), findsOneWidget);
        expect(find.text('PTS Formula Rate'), findsOneWidget);
        expect(find.text('Not configured'), findsOneWidget);

        // Promotional Investment History section
        expect(find.text('Promotional Investment History'), findsOneWidget);
        expect(find.text('Sample pack for trial'), findsOneWidget);
      },
    );
  });

  group('Record Visit Screen Promotional Investment Integration Tests', () {
    testWidgets('Contains Section 4b Promotional Investment toggle', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const RecordVisitScreen()));
      await tester.pumpAndSettle();

      final promoTitleFinder = find.text('Promotional Investment (Optional)');
      await tester.ensureVisible(promoTitleFinder);
      await tester.pumpAndSettle();

      expect(promoTitleFinder, findsOneWidget);
      expect(
        find.text('Record Monetary Promotional Investment?'),
        findsOneWidget,
      );

      // Toggle switch to reveal investment fields
      final promoSwitch = find.byKey(
        const Key('switch_promotional_investment'),
      );
      await tester.ensureVisible(promoSwitch);
      await tester.tap(promoSwitch);
      await tester.pumpAndSettle();

      // Revealed fields
      expect(find.text('INVESTMENT TYPE'), findsOneWidget);
      expect(find.text('Monetary Investment (₹)'), findsOneWidget);
      expect(find.text('Investment Details (Optional)'), findsOneWidget);
    });
  });
}
