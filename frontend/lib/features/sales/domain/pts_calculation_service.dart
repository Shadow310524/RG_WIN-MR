/// Service architecture for PTS (Price to Stockist) calculation.
///
/// NOTE: The exact PTS calculation formula has NOT been finalized by business operations.
/// This service acts as a clean architectural placeholder.
/// It displays "Calculating / Not configured" for PTS Rate and "—" for PTS Value
/// until the official formula is provided and plugged in.
/// No business formula is assumed or hardcoded.
class PtsResult {
  final double? rate;
  final double? value;
  final bool isConfigured;
  final String rateDisplayText;
  final String valueDisplayText;

  const PtsResult({
    this.rate,
    this.value,
    required this.isConfigured,
    required this.rateDisplayText,
    required this.valueDisplayText,
  });

  factory PtsResult.unconfigured() {
    return const PtsResult(
      rate: null,
      value: null,
      isConfigured: false,
      rateDisplayText: "Calculating / Not configured",
      valueDisplayText: "—",
    );
  }
}

class PtsCalculationService {
  PtsCalculationService._();

  /// Calculates PTS metrics based on purchase amount and GST.
  ///
  /// Currently returns unconfigured placeholder state as per business requirements.
  /// When the official PTS formula is finalized, update this method to compute
  /// exact rate and value.
  static PtsResult calculate({
    required double purchaseAmount,
    required double gstAmount,
  }) {
    // [PTS FORMULA PLACEHOLDER]
    // The exact formula has not been finalized yet.
    // Return unconfigured status without inventing or hardcoding business rules.
    return PtsResult.unconfigured();
  }
}
