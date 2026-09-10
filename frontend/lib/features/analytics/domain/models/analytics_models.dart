import 'package:rgwin_crm/core/utils/numeric_utils.dart';
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
        if (v is Map) {
          provMap[k.toString()] = FigureProvenanceModel.fromJson(
            asStringKeyedMap(v),
          );
        }
      });
    }

    return DoctorRankItemModel(
      doctorId: json['doctor_id']?.toString() ?? '',
      doctorName: json['doctor_name'] as String? ?? '',
      clinicName: json['clinic_name'] as String?,
      specialization: json['specialization'] as String? ?? '',
      visitCount: parseInt(json['visit_count']),
      purchaseCount: parseInt(json['purchase_count']),
      businessValue: parseDouble(json['business_value']),
      promotionalInvestment: parseDouble(json['promotional_investment']),
      commercialResult: parseDoubleOrNull(json['commercial_result']),
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
        .map((d) => DoctorRankItemModel.fromJson(asStringKeyedMap(d)))
        .toList();

    final provMap = <String, FigureProvenanceModel>{};
    if (json['provenance'] is Map) {
      (json['provenance'] as Map).forEach((k, v) {
        if (v is Map) {
          provMap[k.toString()] = FigureProvenanceModel.fromJson(
            asStringKeyedMap(v),
          );
        }
      });
    }

    return AreaCommercialSummaryModel(
      areaId: json['area_id']?.toString() ?? '',
      areaName: json['area_name'] as String? ?? '',
      areaCode: json['area_code'] as String? ?? '',
      doctorCount: parseInt(json['doctor_count']),
      businessValue: parseDouble(json['business_value']),
      promotionalInvestment: parseDouble(json['promotional_investment']),
      commercialResult: parseDoubleOrNull(json['commercial_result']),
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
          (a) => AreaCommercialSummaryModel.fromJson(asStringKeyedMap(a)),
        )
        .toList();
    final docList = (json['top_doctors'] as List? ?? [])
        .map((d) => DoctorRankItemModel.fromJson(asStringKeyedMap(d)))
        .toList();

    final provMap = <String, FigureProvenanceModel>{};
    if (json['provenance'] is Map) {
      (json['provenance'] as Map).forEach((k, v) {
        if (v is Map) {
          provMap[k.toString()] = FigureProvenanceModel.fromJson(
            asStringKeyedMap(v),
          );
        }
      });
    }

    return OverallCommercialSummaryModel(
      period: json['period'] as String? ?? 'this_month',
      totalDoctors: parseInt(json['total_doctors']),
      totalVisits: parseInt(json['total_visits']),
      totalPurchases: parseInt(json['total_purchases']),
      businessValue: parseDouble(json['business_value']),
      promotionalInvestment: parseDouble(json['promotional_investment']),
      operatingExpenses: parseDouble(json['operating_expenses']),
      revenue: parseDoubleOrNull(json['revenue']),
      profitLoss: parseDoubleOrNull(json['profit_loss']),
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
          (i) => PromotionalInvestmentModel.fromJson(asStringKeyedMap(i)),
        )
        .toList();

    final provMap = <String, FigureProvenanceModel>{};
    if (json['provenance'] is Map) {
      (json['provenance'] as Map).forEach((k, v) {
        if (v is Map) {
          provMap[k.toString()] = FigureProvenanceModel.fromJson(
            asStringKeyedMap(v),
          );
        }
      });
    }

    return DoctorCommercialSummaryModel(
      doctorId: json['doctor_id']?.toString() ?? '',
      doctorName: json['doctor_name'] as String? ?? '',
      clinicName: json['clinic_name'] as String?,
      specialization: json['specialization'] as String? ?? '',
      areaId: json['area_id']?.toString() ?? '',
      areaName: json['area_name'] as String?,
      visitCount: parseInt(json['visit_count']),
      purchaseCount: parseInt(json['purchase_count']),
      businessValue: parseDouble(json['business_value']),
      promotionalInvestment: parseDouble(json['promotional_investment']),
      revenue: parseDoubleOrNull(json['revenue']),
      commercialResult: parseDoubleOrNull(json['commercial_result']),
      recentInvestments: invList,
      provenance: provMap,
    );
  }
}
