class VisitModel {
  final String id;
  final String doctorId;
  final String? doctorName;
  final String? clinicName;
  final String? specialization;
  final DateTime visitDatetime;
  final String visitType;
  final String
  doctorResponse; // "POSITIVE", "NEUTRAL", "HESITANT", "PRESCRIBING"
  final String prescriptionPotential; // "HIGH", "MEDIUM", "LOW"
  final String? discussedProducts;
  final String? samplesGiven;
  final bool purchaseOpportunity;
  final bool followUpRequired;
  final DateTime? followUpDate;
  final String? notes;
  final String status; // "COMPLETED", "UPCOMING", "CANCELLED"
  final String syncStatus;

  const VisitModel({
    required this.id,
    required this.doctorId,
    this.doctorName,
    this.clinicName,
    this.specialization,
    required this.visitDatetime,
    this.visitType = "ROUTINE",
    required this.doctorResponse,
    this.prescriptionPotential = "MEDIUM",
    this.discussedProducts,
    this.samplesGiven,
    this.purchaseOpportunity = false,
    this.followUpRequired = false,
    this.followUpDate,
    this.notes,
    this.status = "COMPLETED",
    this.syncStatus = "SYNCED",
  });
}
