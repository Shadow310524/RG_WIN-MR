import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/features/promotions/data/promotional_investment_repository.dart';
import 'package:rgwin_crm/features/promotions/domain/models/promotional_investment_model.dart';

class PromotionalInvestmentState {
  final List<PromotionalInvestmentModel> investments;
  final bool isLoading;
  final String? errorMessage;

  const PromotionalInvestmentState({
    this.investments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PromotionalInvestmentState copyWith({
    List<PromotionalInvestmentModel>? investments,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PromotionalInvestmentState(
      investments: investments ?? this.investments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final promotionalInvestmentControllerProvider =
    NotifierProvider<
      PromotionalInvestmentController,
      PromotionalInvestmentState
    >(PromotionalInvestmentController.new);

class PromotionalInvestmentController
    extends Notifier<PromotionalInvestmentState> {
  @override
  PromotionalInvestmentState build() {
    Future.microtask(() => loadInvestments());
    return const PromotionalInvestmentState(isLoading: true);
  }

  PromotionalInvestmentRepository get _repo =>
      ref.read(promotionalInvestmentRepositoryProvider);

  Future<void> loadInvestments({String? doctorId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repo.getInvestments(doctorId: doctorId);
      state = state.copyWith(investments: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<PromotionalInvestmentModel?> recordInvestment({
    required String doctorId,
    String? doctorName,
    String? visitId,
    required double amount,
    required String investmentType,
    required DateTime investmentDate,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repo.recordInvestment(
        doctorId: doctorId,
        doctorName: doctorName,
        visitId: visitId,
        amount: amount,
        investmentType: investmentType,
        investmentDate: investmentDate,
        notes: notes,
      );

      final updated = [
        result,
        ...state.investments.where((i) => i.id != result.id),
      ];
      state = state.copyWith(investments: updated, isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }
}
