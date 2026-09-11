import 'package:rgwin_crm/core/utils/numeric_utils.dart';

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
      id: json['id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString(),
      doctorName: json['doctor_name'] as String?,
      clinicName: json['clinic_name'] as String?,
      purchaseDate:
          DateTime.tryParse(json['purchase_date']?.toString() ?? '') ??
          DateTime.tryParse(json['sale_date']?.toString() ?? '') ??
          DateTime.now(),
      purchaseAmount: parseDouble(
        json['purchase_amount'] ?? json['total_amount'],
      ),
      gstAmount: parseDouble(json['gst_amount']),
      totalAmount: parseDouble(json['total_amount']),
      ptsRate: parseDoubleOrNull(json['pts_rate']),
      ptsValue: parseDoubleOrNull(json['pts_value']),
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? "CONFIRMED",
      syncState: json['sync_state'] as String? ?? "synced",
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
