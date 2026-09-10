class PurchaseModel {
  final String id;
  final String? doctorId;
  final String? doctorName;
  final String? clinicName;
  final DateTime purchaseDate;
  final double purchaseAmount;
  final double gstAmount;
  final double totalAmount;
  final double? ptsRate;
  final double? ptsValue;
  final String? notes;
  final String status;
  final String syncState;
  final DateTime createdAt;

  const PurchaseModel({
    required this.id,
    this.doctorId,
    this.doctorName,
    this.clinicName,
    required this.purchaseDate,
    required this.purchaseAmount,
    required this.gstAmount,
    required this.totalAmount,
    this.ptsRate,
    this.ptsValue,
    this.notes,
    this.status = "CONFIRMED",
    this.syncState = "synced",
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'doctor_id': doctorId,
    'doctor_name': doctorName,
    'clinic_name': clinicName,
    'purchase_date': purchaseDate.toIso8601String(),
    'purchase_amount': purchaseAmount,
    'gst_amount': gstAmount,
    'total_amount': totalAmount,
    'pts_rate': ptsRate,
    'pts_value': ptsValue,
    'notes': notes,
    'status': status,
    'sync_state': syncState,
    'created_at': createdAt.toIso8601String(),
  };

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String?,
      doctorName: json['doctor_name'] as String?,
      clinicName: json['clinic_name'] as String?,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      purchaseAmount: (json['purchase_amount'] as num).toDouble(),
      gstAmount: (json['gst_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      ptsRate: (json['pts_rate'] as num?)?.toDouble(),
      ptsValue: (json['pts_value'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? "CONFIRMED",
      syncState: json['sync_state'] as String? ?? "synced",
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
