import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/features/sales/data/purchase_repository.dart';
import 'package:rgwin_crm/features/sales/domain/models/purchase_model.dart';

class PurchaseState {
  final List<PurchaseModel> purchases;
  final bool isLoading;
  final String? errorMessage;

  const PurchaseState({
    this.purchases = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  double get totalPurchaseAmount =>
      purchases.fold(0.0, (sum, p) => sum + p.purchaseAmount);

  double get totalRevenue =>
      purchases.fold(0.0, (sum, p) => sum + p.totalAmount);

  PurchaseState copyWith({
    List<PurchaseModel>? purchases,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PurchaseState(
      purchases: purchases ?? this.purchases,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PurchaseController extends Notifier<PurchaseState> {
  @override
  PurchaseState build() {
    // Load initial purchases on build
    Future.microtask(() => loadPurchases());
    return const PurchaseState(isLoading: true);
  }

  Future<void> loadPurchases({String? doctorId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(purchaseRepositoryProvider);
      final list = await repo.getPurchases(doctorId: doctorId);
      state = state.copyWith(purchases: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Unable to load purchase records.",
      );
    }
  }

  Future<bool> recordPurchase({
    required String? doctorId,
    required String? doctorName,
    required String? clinicName,
    required DateTime purchaseDate,
    required double purchaseAmount,
    required double gstAmount,
    required String? notes,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(purchaseRepositoryProvider);
      final created = await repo.recordPurchase(
        doctorId: doctorId,
        doctorName: doctorName,
        clinicName: clinicName,
        purchaseDate: purchaseDate,
        purchaseAmount: purchaseAmount,
        gstAmount: gstAmount,
        notes: notes,
      );
      state = state.copyWith(
        purchases: [created, ...state.purchases],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to record purchase. Please try again.",
      );
      return false;
    }
  }
}

final purchaseControllerProvider =
    NotifierProvider<PurchaseController, PurchaseState>(() {
      return PurchaseController();
    });
