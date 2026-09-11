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

  Map<String, dynamic> toJson() => {
    'source': source,
    'status': status,
    'description': description,
  };
}

class FieldActivitySummaryModel {
  final int totalDoctors;
  final int totalVisits;
  final int totalPurchases;
  final int pendingFollowups;

  const FieldActivitySummaryModel({
    this.totalDoctors = 0,
    this.totalVisits = 0,
    this.totalPurchases = 0,
    this.pendingFollowups = 0,
  });

  factory FieldActivitySummaryModel.fromJson(Map<String, dynamic> json) {
    return FieldActivitySummaryModel(
      totalDoctors: parseInt(json['total_doctors']),
      totalVisits: parseInt(json['total_visits']),
      totalPurchases: parseInt(json['total_purchases']),
      pendingFollowups: parseInt(json['pending_followups']),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_doctors': totalDoctors,
    'total_visits': totalVisits,
    'total_purchases': totalPurchases,
    'pending_followups': pendingFollowups,
  };
}

class CategoryInvestmentItemModel {
  final String investmentType;
  final double totalAmount;
  final int count;

  const CategoryInvestmentItemModel({
    required this.investmentType,
    required this.totalAmount,
    this.count = 0,
  });

  factory CategoryInvestmentItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryInvestmentItemModel(
      investmentType: json['investment_type'] as String? ?? 'OTHER',
      totalAmount: parseDouble(json['total_amount']),
      count: parseInt(json['count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'investment_type': investmentType,
    'total_amount': totalAmount,
    'count': count,
  };
}

class TimeTrendPointModel {
  final String label;
  final String startDate;
  final String endDate;
  final int visitsCount;
  final double purchaseAmount;
  final double promoAmount;

  const TimeTrendPointModel({
    required this.label,
    required this.startDate,
    required this.endDate,
    this.visitsCount = 0,
    this.purchaseAmount = 0.0,
    this.promoAmount = 0.0,
  });

  factory TimeTrendPointModel.fromJson(Map<String, dynamic> json) {
    return TimeTrendPointModel(
      label: json['label'] as String? ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      visitsCount: parseInt(json['visits_count']),
      purchaseAmount: parseDouble(json['purchase_amount']),
      promoAmount: parseDouble(json['promo_amount']),
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'start_date': startDate,
    'end_date': endDate,
    'visits_count': visitsCount,
    'purchase_amount': purchaseAmount,
    'promo_amount': promoAmount,
  };
}

class DoctorRankItemModel {
  final String doctorId;
  final String doctorName;
  final String? clinicName;
  final String specialization;
  final String? areaId;
  final String? areaName;
  final int visitCount;
  final int purchaseCount;
  final double businessValue;
  final double promotionalInvestment;
  final double? commercialResult;
  final List<String> attentionSignals;
  final String? lastVisitDate;
  final String? lastPurchaseDate;
  final Map<String, FigureProvenanceModel> provenance;

  const DoctorRankItemModel({
    required this.doctorId,
    required this.doctorName,
    this.clinicName,
    required this.specialization,
    this.areaId,
    this.areaName,
    required this.visitCount,
    required this.purchaseCount,
    required this.businessValue,
    required this.promotionalInvestment,
    this.commercialResult,
    this.attentionSignals = const [],
    this.lastVisitDate,
    this.lastPurchaseDate,
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

    final signals = (json['attention_signals'] as List? ?? [])
        .map((s) => s.toString())
        .toList();

    return DoctorRankItemModel(
      doctorId: json['doctor_id']?.toString() ?? '',
      doctorName: json['doctor_name'] as String? ?? '',
      clinicName: json['clinic_name'] as String?,
      specialization: json['specialization'] as String? ?? '',
      areaId: json['area_id']?.toString(),
      areaName: json['area_name'] as String?,
      visitCount: parseInt(json['visit_count']),
      purchaseCount: parseInt(json['purchase_count']),
      businessValue: parseDouble(json['business_value']),
      promotionalInvestment: parseDouble(json['promotional_investment']),
      commercialResult: parseDoubleOrNull(json['commercial_result']),
      attentionSignals: signals,
      lastVisitDate: json['last_visit_date']?.toString(),
      lastPurchaseDate: json['last_purchase_date']?.toString(),
      provenance: provMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'doctor_id': doctorId,
    'doctor_name': doctorName,
    'clinic_name': clinicName,
    'specialization': specialization,
    'area_id': areaId,
    'area_name': areaName,
    'visit_count': visitCount,
    'purchase_count': purchaseCount,
    'business_value': businessValue,
    'promotional_investment': promotionalInvestment,
    'commercial_result': commercialResult,
    'attention_signals': attentionSignals,
    'last_visit_date': lastVisitDate,
    'last_purchase_date': lastPurchaseDate,
    'provenance': provenance.map((k, v) => MapEntry(k, v.toJson())),
  };
}

class AreaCommercialSummaryModel {
  final String areaId;
  final String areaName;
  final String areaCode;
  final int doctorCount;
  final int visitsCount;
  final int purchaseCount;
  final double avgPurchaseValue;
  final double businessValue;
  final double promotionalInvestment;
  final double? commercialResult;
  final Map<String, int> responseDistribution;
  final List<DoctorRankItemModel> doctors;
  final Map<String, FigureProvenanceModel> provenance;

  const AreaCommercialSummaryModel({
    required this.areaId,
    required this.areaName,
    required this.areaCode,
    required this.doctorCount,
    this.visitsCount = 0,
    this.purchaseCount = 0,
    this.avgPurchaseValue = 0.0,
    required this.businessValue,
    required this.promotionalInvestment,
    this.commercialResult,
    this.responseDistribution = const {},
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

    final respDist = <String, int>{};
    if (json['response_distribution'] is Map) {
      (json['response_distribution'] as Map).forEach((k, v) {
        respDist[k.toString()] = parseInt(v);
      });
    }

    return AreaCommercialSummaryModel(
      areaId: json['area_id']?.toString() ?? '',
      areaName: json['area_name'] as String? ?? '',
      areaCode: json['area_code'] as String? ?? '',
      doctorCount: parseInt(json['doctor_count']),
      visitsCount: parseInt(json['visits_count']),
      purchaseCount: parseInt(json['purchase_count']),
      avgPurchaseValue: parseDouble(json['avg_purchase_value']),
      businessValue: parseDouble(json['business_value']),
      promotionalInvestment: parseDouble(json['promotional_investment']),
      commercialResult: parseDoubleOrNull(json['commercial_result']),
      responseDistribution: respDist,
      doctors: docList,
      provenance: provMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'area_id': areaId,
    'area_name': areaName,
    'area_code': areaCode,
    'doctor_count': doctorCount,
    'visits_count': visitsCount,
    'purchase_count': purchaseCount,
    'avg_purchase_value': avgPurchaseValue,
    'business_value': businessValue,
    'promotional_investment': promotionalInvestment,
    'commercial_result': commercialResult,
    'response_distribution': responseDistribution,
    'doctors': doctors.map((d) => d.toJson()).toList(),
    'provenance': provenance.map((k, v) => MapEntry(k, v.toJson())),
  };
}

class OverallCommercialSummaryModel {
  final String period;
  final FieldActivitySummaryModel fieldActivity;
  final int totalDoctors;
  final int totalVisits;
  final int totalPurchases;
  final double businessValue;
  final double promotionalInvestment;
  final double operatingExpenses;
  final double? revenue;
  final double? profitLoss;
  final Map<String, int> responseDistribution;
  final List<CategoryInvestmentItemModel> categoryInvestments;
  final List<TimeTrendPointModel> trends;
  final List<AreaCommercialSummaryModel> areas;
  final List<DoctorRankItemModel> topDoctors;
  final List<DoctorRankItemModel> highPromoDoctors;
  final List<DoctorRankItemModel> attentionDoctors;
  final Map<String, FigureProvenanceModel> provenance;

  const OverallCommercialSummaryModel({
    required this.period,
    this.fieldActivity = const FieldActivitySummaryModel(),
    required this.totalDoctors,
    required this.totalVisits,
    required this.totalPurchases,
    required this.businessValue,
    required this.promotionalInvestment,
    this.operatingExpenses = 0.0,
    this.revenue,
    this.profitLoss,
    this.responseDistribution = const {},
    this.categoryInvestments = const [],
    this.trends = const [],
    required this.areas,
    required this.topDoctors,
    this.highPromoDoctors = const [],
    this.attentionDoctors = const [],
    this.provenance = const {},
  });

  factory OverallCommercialSummaryModel.fromJson(Map<String, dynamic> json) {
    final areaList = (json['areas'] as List? ?? [])
        .map((a) => AreaCommercialSummaryModel.fromJson(asStringKeyedMap(a)))
        .toList();
    final docList = (json['top_doctors'] as List? ?? [])
        .map((d) => DoctorRankItemModel.fromJson(asStringKeyedMap(d)))
        .toList();
    final promoDocList = (json['high_promo_doctors'] as List? ?? [])
        .map((d) => DoctorRankItemModel.fromJson(asStringKeyedMap(d)))
        .toList();
    final attDocList = (json['attention_doctors'] as List? ?? [])
        .map((d) => DoctorRankItemModel.fromJson(asStringKeyedMap(d)))
        .toList();
    final catList = (json['category_investments'] as List? ?? [])
        .map((c) => CategoryInvestmentItemModel.fromJson(asStringKeyedMap(c)))
        .toList();
    final trendList = (json['trends'] as List? ?? [])
        .map((t) => TimeTrendPointModel.fromJson(asStringKeyedMap(t)))
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

    final respDist = <String, int>{};
    if (json['response_distribution'] is Map) {
      (json['response_distribution'] as Map).forEach((k, v) {
        respDist[k.toString()] = parseInt(v);
      });
    }

    final fieldAct = json['field_activity'] is Map
        ? FieldActivitySummaryModel.fromJson(
            asStringKeyedMap(json['field_activity']),
          )
        : FieldActivitySummaryModel(
            totalDoctors: parseInt(json['total_doctors']),
            totalVisits: parseInt(json['total_visits']),
            totalPurchases: parseInt(json['total_purchases']),
          );

    return OverallCommercialSummaryModel(
      period: json['period'] as String? ?? 'this_month',
      fieldActivity: fieldAct,
      totalDoctors: parseInt(json['total_doctors']),
      totalVisits: parseInt(json['total_visits']),
      totalPurchases: parseInt(json['total_purchases']),
      businessValue: parseDouble(json['business_value']),
      promotionalInvestment: parseDouble(json['promotional_investment']),
      operatingExpenses: parseDouble(json['operating_expenses']),
      revenue: parseDoubleOrNull(json['revenue']),
      profitLoss: parseDoubleOrNull(json['profit_loss']),
      responseDistribution: respDist,
      categoryInvestments: catList,
      trends: trendList,
      areas: areaList,
      topDoctors: docList,
      highPromoDoctors: promoDocList,
      attentionDoctors: attDocList,
      provenance: provMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'period': period,
    'field_activity': fieldActivity.toJson(),
    'total_doctors': totalDoctors,
    'total_visits': totalVisits,
    'total_purchases': totalPurchases,
    'business_value': businessValue,
    'promotional_investment': promotionalInvestment,
    'operating_expenses': operatingExpenses,
    'revenue': revenue,
    'profit_loss': profitLoss,
    'response_distribution': responseDistribution,
    'category_investments': categoryInvestments.map((c) => c.toJson()).toList(),
    'trends': trends.map((t) => t.toJson()).toList(),
    'areas': areas.map((a) => a.toJson()).toList(),
    'top_doctors': topDoctors.map((d) => d.toJson()).toList(),
    'high_promo_doctors': highPromoDoctors.map((d) => d.toJson()).toList(),
    'attention_doctors': attentionDoctors.map((d) => d.toJson()).toList(),
    'provenance': provenance.map((k, v) => MapEntry(k, v.toJson())),
  };
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
  final List<String> attentionSignals;
  final String? lastVisitDate;
  final String? lastPurchaseDate;
  final Map<String, int> responseDistribution;
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
    this.attentionSignals = const [],
    this.lastVisitDate,
    this.lastPurchaseDate,
    this.responseDistribution = const {},
    this.recentInvestments = const [],
    this.provenance = const {},
  });

  factory DoctorCommercialSummaryModel.fromJson(Map<String, dynamic> json) {
    final invList = (json['recent_investments'] as List? ?? [])
        .map((i) => PromotionalInvestmentModel.fromJson(asStringKeyedMap(i)))
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

    final signals = (json['attention_signals'] as List? ?? [])
        .map((s) => s.toString())
        .toList();

    final respDist = <String, int>{};
    if (json['response_distribution'] is Map) {
      (json['response_distribution'] as Map).forEach((k, v) {
        respDist[k.toString()] = parseInt(v);
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
      attentionSignals: signals,
      lastVisitDate: json['last_visit_date']?.toString(),
      lastPurchaseDate: json['last_purchase_date']?.toString(),
      responseDistribution: respDist,
      recentInvestments: invList,
      provenance: provMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'doctor_id': doctorId,
    'doctor_name': doctorName,
    'clinic_name': clinicName,
    'specialization': specialization,
    'area_id': areaId,
    'area_name': areaName,
    'visit_count': visitCount,
    'purchase_count': purchaseCount,
    'business_value': businessValue,
    'promotional_investment': promotionalInvestment,
    'revenue': revenue,
    'commercial_result': commercialResult,
    'attention_signals': attentionSignals,
    'last_visit_date': lastVisitDate,
    'last_purchase_date': lastPurchaseDate,
    'response_distribution': responseDistribution,
    'recent_investments': recentInvestments.map((i) => i.toJson()).toList(),
    'provenance': provenance.map((k, v) => MapEntry(k, v.toJson())),
  };
}
