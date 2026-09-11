import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/theme/app_theme.dart';
import 'package:rgwin_crm/features/analytics/domain/models/analytics_models.dart';
import 'package:rgwin_crm/features/analytics/presentation/analytics_controller.dart';
import 'package:rgwin_crm/features/analytics/presentation/analytics_screen.dart';

class _FakePhase6AnalyticsController extends AnalyticsController {
  final OverallCommercialSummaryModel _summary;
  final bool _isCached;
  final DateTime? _lastUpdated;

  _FakePhase6AnalyticsController(
    this._summary, {
    this._isCached = false,
    this._lastUpdated,
  });

  @override
  AnalyticsState build() {
    return AnalyticsState(
      period: 'this_month',
      overallSummary: _summary,
      isCached: _isCached,
      lastUpdated: _lastUpdated,
      isLoading: false,
    );
  }
}

void main() {
  final sampleDoc1 = DoctorRankItemModel(
    doctorId: 'doc_1',
    doctorName: 'Dr. Ramesh Sundaram',
    clinicName: 'Sundaram Heart Care',
    specialization: 'Cardiology',
    visitCount: 6,
    purchaseCount: 3,
    businessValue: 95000.0,
    promotionalInvestment: 4200.0,
    attentionSignals: const ['TOP_PRESCRIBER'],
  );

  final sampleDoc2 = DoctorRankItemModel(
    doctorId: 'doc_2',
    doctorName: 'Dr. Priya Shankar',
    clinicName: 'Apollo Specialty',
    specialization: 'Neurology',
    visitCount: 3,
    purchaseCount: 0,
    businessValue: 0.0,
    promotionalInvestment: 5000.0,
    attentionSignals: const ['NO_PURCHASE_RECENTLY', 'HIGH_PROMO_SPEND'],
  );

  final sampleArea = AreaCommercialSummaryModel(
    areaId: 'area_1',
    areaName: 'Central District',
    areaCode: 'CENT-01',
    doctorCount: 8,
    visitsCount: 14,
    purchaseCount: 5,
    avgPurchaseValue: 19000.0,
    businessValue: 95000.0,
    promotionalInvestment: 9200.0,
    responseDistribution: const {'PRESCRIBING': 4, 'POSITIVE': 6},
    doctors: [sampleDoc1, sampleDoc2],
  );

  final sampleSummary = OverallCommercialSummaryModel(
    period: 'this_month',
    fieldActivity: const FieldActivitySummaryModel(
      totalDoctors: 8,
      totalVisits: 14,
      totalPurchases: 5,
      pendingFollowups: 3,
    ),
    totalDoctors: 8,
    totalVisits: 14,
    totalPurchases: 5,
    businessValue: 95000.0,
    promotionalInvestment: 9200.0,
    responseDistribution: const {
      'PRESCRIBING': 4,
      'POSITIVE': 6,
      'HESITANT': 2,
    },
    categoryInvestments: const [
      CategoryInvestmentItemModel(
        investmentType: 'SAMPLE',
        totalAmount: 6000.0,
        count: 12,
      ),
      CategoryInvestmentItemModel(
        investmentType: 'PROMOTIONAL_UNIT',
        totalAmount: 3200.0,
        count: 4,
      ),
    ],
    trends: [
      TimeTrendPointModel(
        label: 'This week',
        startDate: '2026-09-05',
        endDate: '2026-09-11',
        visitsCount: 6,
        purchaseAmount: 45000.0,
        promoAmount: 2000.0,
      ),
    ],
    areas: [sampleArea],
    topDoctors: [sampleDoc1, sampleDoc2],
    highPromoDoctors: [sampleDoc2, sampleDoc1],
    attentionDoctors: [sampleDoc2],
  );

  Widget createWidget({
    OverallCommercialSummaryModel? summary,
    bool isCached = false,
    DateTime? lastUpdated,
  }) {
    return ProviderScope(
      overrides: [
        analyticsControllerProvider.overrideWith(
          () => _FakePhase6AnalyticsController(
            summary ?? sampleSummary,
            isCached: isCached,
            lastUpdated: lastUpdated,
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AnalyticsScreen(),
      ),
    );
  }

  group('Phase 6 Management Intelligence Tests', () {
    testWidgets('Renders Field Activity Summary metrics', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Field Activity Summary'), findsOneWidget);
      expect(find.text('Doctors'), findsOneWidget);
      expect(find.text('Visits'), findsOneWidget);
      expect(find.text('Purchases'), findsOneWidget);
      expect(find.text('Follow-ups'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('Renders Response Breakdown and Category spend', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Doctor Response Breakdown'), findsOneWidget);
      expect(find.textContaining('PRESCRIBING: 4'), findsOneWidget);
      expect(find.textContaining('POSITIVE: 6'), findsOneWidget);

      expect(find.text('Promotional Spend by Category'), findsOneWidget);
      expect(find.text('SAMPLE'), findsOneWidget);
      expect(find.text('PROMOTIONAL UNIT'), findsOneWidget);
    });

    testWidgets('Renders Doctor Attention Signal chips', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Top Prescriber'), findsOneWidget);
      expect(find.text('No Purchases'), findsOneWidget);
      expect(find.text('High Promo'), findsOneWidget);
    });

    testWidgets('Renders Offline Cache banner when isCached is true', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cachedTime = DateTime(2026, 9, 11, 10, 30);
      await tester.pumpWidget(
        createWidget(isCached: true, lastUpdated: cachedTime),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Showing cached data'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
    });
  });
}
