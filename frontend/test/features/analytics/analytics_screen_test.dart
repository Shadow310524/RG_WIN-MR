import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/theme/app_theme.dart';
import 'package:rgwin_crm/features/analytics/domain/models/analytics_models.dart';
import 'package:rgwin_crm/features/analytics/presentation/analytics_controller.dart';
import 'package:rgwin_crm/features/analytics/presentation/analytics_screen.dart';

class _FakeAnalyticsController extends AnalyticsController {
  final OverallCommercialSummaryModel _summary;
  _FakeAnalyticsController(this._summary);

  @override
  AnalyticsState build() {
    return AnalyticsState(
      period: 'this_month',
      overallSummary: _summary,
      isLoading: false,
    );
  }
}

void main() {
  final sampleDoctorRank = DoctorRankItemModel(
    doctorId: 'doc_1',
    doctorName: 'Dr. Ramesh Sundaram',
    clinicName: 'Sundaram Heart Care',
    specialization: 'Cardiology',
    visitCount: 4,
    purchaseCount: 2,
    businessValue: 75000.0,
    promotionalInvestment: 3500.0,
  );

  final sampleArea = AreaCommercialSummaryModel(
    areaId: 'area_1',
    areaName: 'Anna Nagar',
    areaCode: 'CHEN-AN-01',
    doctorCount: 5,
    businessValue: 120000.0,
    promotionalInvestment: 8000.0,
    doctors: [sampleDoctorRank],
  );

  final sampleSummary = OverallCommercialSummaryModel(
    period: 'this_month',
    totalDoctors: 12,
    totalVisits: 18,
    totalPurchases: 6,
    businessValue: 185000.0,
    promotionalInvestment: 12500.0,
    operatingExpenses: 9400.0,
    areas: [sampleArea],
    topDoctors: [sampleDoctorRank],
  );

  Widget createTestWidget({OverallCommercialSummaryModel? summary}) {
    return ProviderScope(
      overrides: [
        analyticsControllerProvider.overrideWith(
          () => _FakeAnalyticsController(summary ?? sampleSummary),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AnalyticsScreen(),
      ),
    );
  }

  group('Analytics Screen Tests', () {
    testWidgets(
      'Renders header, period filters, and executive commercial overview',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Screen title
        expect(find.text('Commercial Analytics'), findsOneWidget);

        // Period selector chips
        expect(find.text('Today'), findsOneWidget);
        expect(find.text('This Week'), findsOneWidget);
        expect(find.text('This Month'), findsOneWidget);
        expect(find.text('All Time'), findsOneWidget);

        // Overview metrics
        expect(find.text('Business Overview'), findsOneWidget);
        expect(find.text('Business Value'), findsWidgets);
        expect(find.text('₹1,85,000.00'), findsOneWidget);

        expect(find.text('Promotional Spend'), findsWidgets);
        expect(find.text('₹12,500.00'), findsOneWidget);

        // P&L Honest Placeholder
        expect(find.text('Profit / Loss'), findsOneWidget);
        expect(find.text('Insufficient data'), findsOneWidget);
        expect(find.text('Pending product cost rules'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Provenance Info reveals Financial Data Provenance modal',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap info icon in app bar
        final infoButton = find.byIcon(Icons.info_outline);
        expect(infoButton, findsOneWidget);
        await tester.tap(infoButton);
        await tester.pumpAndSettle();

        // Modal bottom sheet appears
        expect(find.text('Financial Data Provenance'), findsOneWidget);
        expect(find.textContaining('Realized Purchases'), findsOneWidget);
        expect(find.textContaining('Explicit Doctor Spend'), findsOneWidget);
        expect(
          find.textContaining('Operating Expenses (Excluded)'),
          findsOneWidget,
        );
        expect(find.textContaining('Revenue unavailable'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders Area Performance section and expands doctor drilldown on tap',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Section header
        expect(find.text('Area Performance'), findsOneWidget);
        expect(find.text('Anna Nagar'), findsOneWidget);
        expect(find.textContaining('5 Doctors'), findsOneWidget);

        // Tap area card to expand drilldown
        await tester.tap(find.text('Anna Nagar'));
        await tester.pumpAndSettle();

        // Ranked doctor in Anna Nagar
        expect(find.text('Dr. Ramesh Sundaram'), findsWidgets);
        expect(find.textContaining('Sundaram Heart Care'), findsWidgets);
      },
    );

    testWidgets('Renders Top Performing Doctors by Commercial Value', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Doctor Performance'), findsOneWidget);
      expect(
        find.text('Top contributing doctors ranked by business value'),
        findsOneWidget,
      );
      expect(find.text('Dr. Ramesh Sundaram'), findsWidgets);
      expect(find.text('₹75,000.00'), findsWidgets);
      expect(find.text('Promo: ₹3,500.00'), findsWidgets);
    });
  });
}
