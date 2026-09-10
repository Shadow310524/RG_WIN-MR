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
  final String? errorMessage;

  const AnalyticsState({
    this.period = 'this_month',
    this.overallSummary,
    this.selectedAreaSummary,
    this.isLoading = false,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    String? period,
    OverallCommercialSummaryModel? overallSummary,
    AreaCommercialSummaryModel? selectedAreaSummary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AnalyticsState(
      period: period ?? this.period,
      overallSummary: overallSummary ?? this.overallSummary,
      selectedAreaSummary: selectedAreaSummary ?? this.selectedAreaSummary,
      isLoading: isLoading ?? this.isLoading,
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

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repo.getOverallSummary(period: state.period);
      if (summary != null) {
        state = state.copyWith(overallSummary: summary, isLoading: false);
        return;
      }
    } catch (_) {}

    // Fallback: derive client-side from available doctor & purchase state
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
      final docItems = <DoctorRankItemModel>[];

      for (final doc in areaDocs) {
        final docPurchases = purchaseState.purchases
            .where((p) => p.doctorId == doc.id)
            .fold(0.0, (acc, p) => acc + p.totalAmount);
        final docInvest = investState.investments
            .where((i) => i.doctorId == doc.id)
            .fold(0.0, (acc, i) => acc + i.amount);

        areaPurchases += docPurchases;
        areaInvestments += docInvest;

        docItems.add(
          DoctorRankItemModel(
            doctorId: doc.id,
            doctorName: doc.name,
            clinicName: doc.clinicName,
            specialization: doc.specialization,
            visitCount: 0,
            purchaseCount: purchaseState.purchases
                .where((p) => p.doctorId == doc.id)
                .length,
            businessValue: docPurchases,
            promotionalInvestment: docInvest,
          ),
        );
      }

      docItems.sort((a, b) => b.businessValue.compareTo(a.businessValue));

      areaMap[area.id] = AreaCommercialSummaryModel(
        areaId: area.id,
        areaName: area.name,
        areaCode: area.code,
        doctorCount: areaDocs.length,
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
        totalDoctors: docState.doctors.length,
        totalVisits: 0,
        totalPurchases: purchaseState.purchases.length,
        businessValue: totalPurchasesVal,
        promotionalInvestment: totalInvestVal,
        areas: areaMap.values.toList(),
        topDoctors: topDoctors.take(10).toList(),
      ),
      isLoading: false,
    );
  }

  Future<void> selectAreaForDrilldown(String areaId) async {
    // Check if in current overall summary
    final existing = state.overallSummary?.areas.where(
      (a) => a.areaId == areaId,
    );
    if (existing != null && existing.isNotEmpty) {
      state = state.copyWith(selectedAreaSummary: existing.first);
      return;
    }

    try {
      final areaSummary = await _repo.getAreaSummary(areaId);
      if (areaSummary != null) {
        state = state.copyWith(selectedAreaSummary: areaSummary);
      }
    } catch (_) {}
  }
}
