import 'package:rgwin_crm/features/promotions/domain/models/promotional_investment_model.dart';

class FigureProvenanceModel {
  final String source;
  final String status;
  final String description;

  const FigureProvenanceModel({
    required this.source,
    required this.status,
    required this.description,
  });

  factory FigureProvenanceModel.fromJson(Map<String, dynamic> json) {
    return FigureProvenanceModel(
      source: json['source'] as String? ?? 'UNKNOWN',
      status: json['status'] as String? ?? 'UNKNOWN',
      description: json['description'] as String? ?? '',
    );
  }
}

class DoctorRankItemModel {
  final String doctorId;
  final String doctorName;
  final String? clinicName;
  final String specialization;
  final int visitCount;
  final int purchaseCount;
  final double businessValue;
  final double promotionalInvestment;
  final double? commercialResult;
  final Map<String, FigureProvenanceModel> provenance;

  const DoctorRankItemModel({
    required this.doctorId,
    required this.doctorName,
    this.clinicName,
    required this.specialization,
    required this.visitCount,
    required this.purchaseCount,
    required this.businessValue,
    required this.promotionalInvestment,
    this.commercialResult,
    this.provenance = const {},
  });

  factory DoctorRankItemModel.fromJson(Map<String, dynamic> json) {
    final provMap = <String, FigureProvenanceModel>{};
    if (json['provenance'] is Map) {
      (json['provenance'] as Map).forEach((k, v) {
        if (v is Map<String, dynamic>) {
          provMap[k.toString()] = FigureProvenanceModel.fromJson(v);
        }
      });
    }

    return DoctorRankItemModel(
      doctorId: json['doctor_id'] as String,
      doctorName: json['doctor_name'] as String,
      clinicName: json['clinic_name'] as String?,
      specialization: json['specialization'] as String? ?? '',
      visitCount: json['visit_count'] as int? ?? 0,
      purchaseCount: json['purchase_count'] as int? ?? 0,
      businessValue: (json['business_value'] as num?)?.toDouble() ?? 0.0,
      promotionalInvestment:
          (json['promotional_investment'] as num?)?.toDouble() ?? 0.0,
      commercialResult: (json['commercial_result'] as num?)?.toDouble(),
      provenance: provMap,
    );
  }
}

class AreaCommercialSummaryModel {
  final String areaId;
  final String areaName;
  final String areaCode;
  final int doctorCount;
  final double businessValue;
  final double promotionalInvestment;
  final double? commercialResult;
  final List<DoctorRankItemModel> doctors;
  final Map<String, FigureProvenanceModel> provenance;

  const AreaCommercialSummaryModel({
    required this.areaId,
    required this.areaName,
    required this.areaCode,
    required this.doctorCount,
    required this.businessValue,
    required this.promotionalInvestment,
    this.commercialResult,
    required this.doctors,
    this.provenance = const {},
  });

  factory AreaCommercialSummaryModel.fromJson(Map<String, dynamic> json) {
    final docList = (json['doctors'] as List? ?? [])
        .map((d) => DoctorRankItemModel.fromJson(d as Map<String, dynamic>))
        .toList();

    final provMap = <String, FigureProvenanceModel>{};
    if (json['provenance'] is Map) {
      (json['provenance'] as Map).forEach((k, v) {
        if (v is Map<String, dynamic>) {
          provMap[k.toString()] = FigureProvenanceModel.fromJson(v);
        }
      });
    }

    return AreaCommercialSummaryModel(
      areaId: json['area_id'] as String,
      areaName: json['area_name'] as String,
      areaCode: json['area_code'] as String? ?? '',
      doctorCount: json['doctor_count'] as int? ?? 0,
      businessValue: (json['business_value'] as num?)?.toDouble() ?? 0.0,
      promotionalInvestment:
          (json['promotional_investment'] as num?)?.toDouble() ?? 0.0,
      commercialResult: (json['commercial_result'] as num?)?.toDouble(),
      doctors: docList,
      provenance: provMap,
    );
  }
}

class OverallCommercialSummaryModel {
  final String period;
  final int totalDoctors;
  final int totalVisits;
  final int totalPurchases;
  final double businessValue;
  final double promotionalInvestment;
  final double operatingExpenses;
  final double? revenue;
  final double? profitLoss;
  final List<AreaCommercialSummaryModel> areas;
  final List<DoctorRankItemModel> topDoctors;
  final Map<String, FigureProvenanceModel> provenance;

  const OverallCommercialSummaryModel({
    required this.period,
    required this.totalDoctors,
    required this.totalVisits,
    required this.totalPurchases,
    required this.businessValue,
    required this.promotionalInvestment,
    this.operatingExpenses = 0.0,
    this.revenue,
    this.profitLoss,
    required this.areas,
    required this.topDoctors,
    this.provenance = const {},
  });

  factory OverallCommercialSummaryModel.fromJson(Map<String, dynamic> json) {
    final areaList = (json['areas'] as List? ?? [])
        .map(
          (a) => AreaCommercialSummaryModel.fromJson(a as Map<String, dynamic>),
        )
        .toList();
    final docList = (json['top_doctors'] as List? ?? [])
        .map((d) => DoctorRankItemModel.fromJson(d as Map<String, dynamic>))
        .toList();

    final provMap = <String, FigureProvenanceModel>{};
    if (json['provenance'] is Map) {
      (json['provenance'] as Map).forEach((k, v) {
        if (v is Map<String, dynamic>) {
          provMap[k.toString()] = FigureProvenanceModel.fromJson(v);
        }
      });
    }

    return OverallCommercialSummaryModel(
      period: json['period'] as String? ?? 'this_month',
      totalDoctors: json['total_doctors'] as int? ?? 0,
      totalVisits: json['total_visits'] as int? ?? 0,
      totalPurchases: json['total_purchases'] as int? ?? 0,
      businessValue: (json['business_value'] as num?)?.toDouble() ?? 0.0,
      promotionalInvestment:
          (json['promotional_investment'] as num?)?.toDouble() ?? 0.0,
      operatingExpenses:
          (json['operating_expenses'] as num?)?.toDouble() ?? 0.0,
      revenue: (json['revenue'] as num?)?.toDouble(),
      profitLoss: (json['profit_loss'] as num?)?.toDouble(),
      areas: areaList,
      topDoctors: docList,
      provenance: provMap,
    );
  }
}

class DoctorCommercialSummaryModel {
  final String doctorId;
  final String doctorName;
  final String? clinicName;
  final String specialization;
  final String areaId;
  final String? areaName;
  final int visitCount;
  final int purchaseCount;
  final double businessValue;
  final double promotionalInvestment;
  final double? revenue;
  final double? commercialResult;
  final List<PromotionalInvestmentModel> recentInvestments;
  final Map<String, FigureProvenanceModel> provenance;

  const DoctorCommercialSummaryModel({
    required this.doctorId,
    required this.doctorName,
    this.clinicName,
    required this.specialization,
    required this.areaId,
    this.areaName,
    required this.visitCount,
    required this.purchaseCount,
    required this.businessValue,
    required this.promotionalInvestment,
    this.revenue,
    this.commercialResult,
    this.recentInvestments = const [],
    this.provenance = const {},
  });

  factory DoctorCommercialSummaryModel.fromJson(Map<String, dynamic> json) {
    final invList = (json['recent_investments'] as List? ?? [])
        .map(
          (i) => PromotionalInvestmentModel.fromJson(i as Map<String, dynamic>),
        )
        .toList();

    final provMap = <String, FigureProvenanceModel>{};
    if (json['provenance'] is Map) {
      (json['provenance'] as Map).forEach((k, v) {
        if (v is Map<String, dynamic>) {
          provMap[k.toString()] = FigureProvenanceModel.fromJson(v);
        }
      });
    }

    return DoctorCommercialSummaryModel(
      doctorId: json['doctor_id'] as String,
      doctorName: json['doctor_name'] as String,
      clinicName: json['clinic_name'] as String?,
      specialization: json['specialization'] as String? ?? '',
      areaId: json['area_id'] as String,
      areaName: json['area_name'] as String?,
      visitCount: json['visit_count'] as int? ?? 0,
      purchaseCount: json['purchase_count'] as int? ?? 0,
      businessValue: (json['business_value'] as num?)?.toDouble() ?? 0.0,
      promotionalInvestment:
          (json['promotional_investment'] as num?)?.toDouble() ?? 0.0,
      revenue: (json['revenue'] as num?)?.toDouble(),
      commercialResult: (json['commercial_result'] as num?)?.toDouble(),
      recentInvestments: invList,
      provenance: provMap,
    );
  }
}
