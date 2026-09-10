import 'package:rgwin_crm/core/utils/numeric_utils.dart';

class PromotionalInvestmentModel {
  final String id;
  final String doctorId;
  final String? doctorName;
  final String? visitId;
  final double amount;
  final String
  investmentType; // SAMPLE | PROMOTIONAL_UNIT | FREE_SUPPLY | PROMOTIONAL_MATERIAL | OTHER
  final DateTime investmentDate;
  final String? notes;
  final String syncState; // synced | pending | failed
  final String provenanceSource;
  final DateTime createdAt;

  const PromotionalInvestmentModel({
    required this.id,
    required this.doctorId,
    this.doctorName,
    this.visitId,
    required this.amount,
    required this.investmentType,
    required this.investmentDate,
    this.notes,
    this.syncState = 'synced',
    this.provenanceSource = 'EXPLICIT_PROMOTIONAL_INVESTMENT',
    required this.createdAt,
  });

  String get typeDisplay {
    switch (investmentType) {
      case 'SAMPLE':
        return 'Sample';
      case 'PROMOTIONAL_UNIT':
        return 'Promotional Unit';
      case 'FREE_SUPPLY':
        return 'Free Supply';
      case 'PROMOTIONAL_MATERIAL':
        return 'Promotional Material';
      default:
        return 'Other Promotional';
    }
  }

  factory PromotionalInvestmentModel.fromJson(Map<String, dynamic> json) {
    return PromotionalInvestmentModel(
      id: json['id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      doctorName: json['doctor_name'] as String?,
      visitId: json['visit_id']?.toString(),
      amount: parseDouble(json['amount']),
      investmentType: json['investment_type'] as String? ?? 'SAMPLE',
      investmentDate:
          DateTime.tryParse(json['investment_date']?.toString() ?? '') ??
          DateTime.now(),
      notes: json['notes'] as String?,
      syncState: json['sync_state'] as String? ?? 'synced',
      provenanceSource:
          json['provenance_source'] as String? ??
          'EXPLICIT_PROMOTIONAL_INVESTMENT',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'visit_id': visitId,
      'amount': amount,
      'investment_type': investmentType,
      'investment_date': investmentDate.toIso8601String().split('T').first,
      'notes': notes,
      'sync_state': syncState,
      'provenance_source': provenanceSource,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PromotionalInvestmentModel copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? visitId,
    double? amount,
    String? investmentType,
    DateTime? investmentDate,
    String? notes,
    String? syncState,
    String? provenanceSource,
    DateTime? createdAt,
  }) {
    return PromotionalInvestmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      visitId: visitId ?? this.visitId,
      amount: amount ?? this.amount,
      investmentType: investmentType ?? this.investmentType,
      investmentDate: investmentDate ?? this.investmentDate,
      notes: notes ?? this.notes,
      syncState: syncState ?? this.syncState,
      provenanceSource: provenanceSource ?? this.provenanceSource,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
