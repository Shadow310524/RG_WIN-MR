import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/features/analytics/data/analytics_repository.dart';
import 'package:rgwin_crm/features/analytics/domain/models/analytics_models.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';
import 'package:rgwin_crm/features/promotions/presentation/promotional_investment_controller.dart';

class AnalyticsState {
  final String period; // today | this_week | this_month | all
  final OverallCommercialSummaryModel? overallSummary;
  final AreaCommercialSummaryModel? selectedAreaSummary;
  final bool isLoading;
  final bool isCached;
  final DateTime? lastUpdated;
  final bool sortByPromoSpend;
  final String? selectedCategory;
  final String? errorMessage;

  const AnalyticsState({
    this.period = 'this_month',
    this.overallSummary,
    this.selectedAreaSummary,
    this.isLoading = false,
    this.isCached = false,
    this.lastUpdated,
    this.sortByPromoSpend = false,
    this.selectedCategory,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    String? period,
    OverallCommercialSummaryModel? overallSummary,
    AreaCommercialSummaryModel? selectedAreaSummary,
    bool? isLoading,
    bool? isCached,
    DateTime? lastUpdated,
    bool? sortByPromoSpend,
    String? selectedCategory,
    String? errorMessage,
  }) {
    return AnalyticsState(
      period: period ?? this.period,
      overallSummary: overallSummary ?? this.overallSummary,
      selectedAreaSummary: selectedAreaSummary ?? this.selectedAreaSummary,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      sortByPromoSpend: sortByPromoSpend ?? this.sortByPromoSpend,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage,
    );
  }
}

final analyticsControllerProvider =
    NotifierProvider<AnalyticsController, AnalyticsState>(
      AnalyticsController.new,
    );

class AnalyticsController extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    Future.microtask(() => loadAnalytics());
    return const AnalyticsState(isLoading: true);
  }

  AnalyticsRepository get _repo => ref.read(analyticsRepositoryProvider);

  Future<void> setPeriod(String newPeriod) async {
    if (state.period == newPeriod) return;
    state = state.copyWith(period: newPeriod, isLoading: true);
    await loadAnalytics();
  }

  void toggleSort() {
    state = state.copyWith(sortByPromoSpend: !state.sortByPromoSpend);
  }

  void filterCategory(String? category) {
    if (state.selectedCategory == category) {
      state = state.copyWith(selectedCategory: null);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repo.getOverallSummary(period: state.period);
      if (result.summary != null) {
        state = state.copyWith(
          overallSummary: result.summary,
          isCached: result.isCached,
          lastUpdated: result.cachedTimestamp ?? DateTime.now(),
          isLoading: false,
        );
        return;
      }
    } catch (_) {}

    // Fallback: derive client-side from available doctor, visit & purchase state
    _buildLocalFallback();
  }

  void _buildLocalFallback() {
    final docState = ref.read(doctorControllerProvider);
    final purchaseState = ref.read(purchaseControllerProvider);
    final investState = ref.read(promotionalInvestmentControllerProvider);

    final totalPurchasesVal = purchaseState.purchases.fold(
      0.0,
      (acc, p) => acc + p.totalAmount,
    );
    final totalInvestVal = investState.investments.fold(
      0.0,
      (acc, i) => acc + i.amount,
    );

    final areaMap = <String, AreaCommercialSummaryModel>{};

    for (final area in docState.areas) {
      final areaDocs = docState.doctors
          .where((d) => d.areaId == area.id)
          .toList();
      double areaPurchases = 0.0;
      double areaInvestments = 0.0;
      int areaPurchaseCount = 0;
      final docItems = <DoctorRankItemModel>[];

      for (final doc in areaDocs) {
        final docPurchases = purchaseState.purchases
            .where((p) => p.doctorId == doc.id)
            .fold(0.0, (acc, p) => acc + p.totalAmount);
        final docInvest = investState.investments
            .where((i) => i.doctorId == doc.id)
            .fold(0.0, (acc, i) => acc + i.amount);
        final pCount = purchaseState.purchases
            .where((p) => p.doctorId == doc.id)
            .length;

        areaPurchases += docPurchases;
        areaInvestments += docInvest;
        areaPurchaseCount += pCount;

        final signals = <String>[];
        if (docInvest > 0 && docPurchases == 0) {
          signals.add("HIGH_PROMO_SPEND");
        }

        docItems.add(
          DoctorRankItemModel(
            doctorId: doc.id,
            doctorName: doc.name,
            clinicName: doc.clinicName,
            specialization: doc.specialization,
            areaId: area.id,
            areaName: area.name,
            visitCount: 0,
            purchaseCount: pCount,
            businessValue: docPurchases,
            promotionalInvestment: docInvest,
            attentionSignals: signals,
          ),
        );
      }

      docItems.sort((a, b) => b.businessValue.compareTo(a.businessValue));

      areaMap[area.id] = AreaCommercialSummaryModel(
        areaId: area.id,
        areaName: area.name,
        areaCode: area.code,
        doctorCount: areaDocs.length,
        purchaseCount: areaPurchaseCount,
        avgPurchaseValue: areaPurchaseCount > 0
            ? (areaPurchases / areaPurchaseCount)
            : 0.0,
        businessValue: areaPurchases,
        promotionalInvestment: areaInvestments,
        doctors: docItems,
      );
    }

    final topDoctors = <DoctorRankItemModel>[];
    for (final area in areaMap.values) {
      topDoctors.addAll(area.doctors);
    }
    topDoctors.sort((a, b) => b.businessValue.compareTo(a.businessValue));

    state = state.copyWith(
      overallSummary: OverallCommercialSummaryModel(
        period: state.period,
        fieldActivity: FieldActivitySummaryModel(
          totalDoctors: docState.doctors.length,
          totalVisits: 0,
          totalPurchases: purchaseState.purchases.length,
        ),
        totalDoctors: docState.doctors.length,
        totalVisits: 0,
        totalPurchases: purchaseState.purchases.length,
        businessValue: totalPurchasesVal,
        promotionalInvestment: totalInvestVal,
        areas: areaMap.values.toList(),
        topDoctors: topDoctors.take(10).toList(),
      ),
      isCached: true,
      lastUpdated: DateTime.now(),
      isLoading: false,
    );
  }

  Future<void> selectAreaForDrilldown(String areaId) async {
    final existing = state.overallSummary?.areas.where(
      (a) => a.areaId == areaId,
    );
    if (existing != null && existing.isNotEmpty) {
      state = state.copyWith(selectedAreaSummary: existing.first);
      return;
    }

    try {
      final areaSummary = await _repo.getAreaSummary(
        areaId,
        period: state.period,
      );
      if (areaSummary != null) {
        state = state.copyWith(selectedAreaSummary: areaSummary);
      }
    } catch (_) {}
  }

  void clearSelectedArea() {
    state = state.copyWith(selectedAreaSummary: null);
  }
}
