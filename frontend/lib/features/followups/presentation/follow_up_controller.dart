import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/features/followups/data/follow_up_repository.dart';
import 'package:rgwin_crm/features/followups/domain/models/follow_up_model.dart';

class FollowUpState {
  final List<FollowUpModel> followUps;
  final bool isLoading;
  final String? errorMessage;
  final String activeFilter; // "ALL", "PENDING", "COMPLETED"

  const FollowUpState({
    this.followUps = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeFilter = "ALL",
  });

  List<FollowUpModel> get filteredFollowUps {
    switch (activeFilter) {
      case "PENDING":
        return followUps.where((f) => f.status == "PENDING").toList();
      case "COMPLETED":
        return followUps.where((f) => f.status == "COMPLETED").toList();
      default:
        return followUps;
    }
  }

  List<FollowUpModel> get pendingFollowUps =>
      followUps.where((f) => f.status == "PENDING").toList();

  List<FollowUpModel> get completedFollowUps =>
      followUps.where((f) => f.status == "COMPLETED").toList();

  List<FollowUpModel> get upcomingFollowUps {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return followUps
        .where(
          (f) =>
              f.status == "PENDING" &&
              (f.dueDate.isAfter(todayStart) ||
                  (f.dueDate.year == now.year &&
                      f.dueDate.month == now.month &&
                      f.dueDate.day == now.day)),
        )
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  FollowUpState copyWith({
    List<FollowUpModel>? followUps,
    bool? isLoading,
    String? errorMessage,
    String? activeFilter,
  }) {
    return FollowUpState(
      followUps: followUps ?? this.followUps,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class FollowUpController extends Notifier<FollowUpState> {
  @override
  FollowUpState build() {
    Future.microtask(() => loadFollowUps());
    return const FollowUpState(isLoading: true);
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<void> loadFollowUps({String? doctorId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(followUpRepositoryProvider);
      final list = await repo.getFollowUps(doctorId: doctorId);
      state = state.copyWith(followUps: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Unable to load follow-ups",
      );
    }
  }

  Future<bool> createFollowUp({
    required String doctorId,
    String? doctorName,
    String? clinicName,
    String? visitId,
    required DateTime dueDate,
    required String taskReason,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(followUpRepositoryProvider);
      final created = await repo.createFollowUp(
        doctorId: doctorId,
        doctorName: doctorName,
        clinicName: clinicName,
        visitId: visitId,
        dueDate: dueDate,
        taskReason: taskReason,
      );
      state = state.copyWith(
        followUps: [created, ...state.followUps],
        isLoading: false,
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to schedule follow-up",
      );
      return false;
    }
  }

  Future<void> toggleStatus(String followUpId) async {
    final match = state.followUps.where((f) => f.id == followUpId).firstOrNull;
    if (match == null) return;

    final newStatus = match.status == "COMPLETED" ? "PENDING" : "COMPLETED";
    final repo = ref.read(followUpRepositoryProvider);

    final updatedList = state.followUps.map((f) {
      if (f.id == followUpId) {
        return f.copyWith(
          status: newStatus,
          completedAt: newStatus == "COMPLETED" ? DateTime.now() : null,
        );
      }
      return f;
    }).toList();

    state = state.copyWith(followUps: updatedList);
    await repo.updateStatus(followUpId: followUpId, newStatus: newStatus);
  }
}

final followUpControllerProvider =
    NotifierProvider<FollowUpController, FollowUpState>(() {
      return FollowUpController();
    });
