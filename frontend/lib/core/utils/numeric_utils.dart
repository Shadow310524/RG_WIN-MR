/// Safe numeric utilities for handling API responses where numbers may arrive
/// as [num], [int], [double], or serialized Decimal [String].
double parseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

double? parseDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

int parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

Map<String, dynamic> asStringKeyedMap(dynamic map) {
  if (map is Map<String, dynamic>) return map;
  if (map is Map) {
    return Map<String, dynamic>.from(map);
  }
  return {};
}
