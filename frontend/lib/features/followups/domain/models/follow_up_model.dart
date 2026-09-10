class FollowUpModel {
  final String id;
  final String doctorId;
  final String? doctorName;
  final String? clinicName;
  final String? visitId;
  final DateTime dueDate;
  final String taskReason;
  final String status; // "PENDING", "COMPLETED", "CANCELLED"
  final DateTime? completedAt;
  final String syncStatus;

  const FollowUpModel({
    required this.id,
    required this.doctorId,
    this.doctorName,
    this.clinicName,
    this.visitId,
    required this.dueDate,
    required this.taskReason,
    this.status = "PENDING",
    this.completedAt,
    this.syncStatus = "SYNCED",
  });

  bool get isCompleted => status == "COMPLETED";

  FollowUpModel copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? clinicName,
    String? visitId,
    DateTime? dueDate,
    String? taskReason,
    String? status,
    DateTime? completedAt,
    String? syncStatus,
  }) {
    return FollowUpModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      clinicName: clinicName ?? this.clinicName,
      visitId: visitId ?? this.visitId,
      dueDate: dueDate ?? this.dueDate,
      taskReason: taskReason ?? this.taskReason,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
