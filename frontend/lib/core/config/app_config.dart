import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String appName = "RG WIN - Healix CRM";
  static const String appVersion = "1.0.0";

  /// Base URL resolved appropriately depending on platform target
  static String get apiBaseUrl {
    if (kIsWeb) {
      return "http://localhost:8000/api/v1";
    }
    // Default to localhost for desktop (Windows), or 10.0.2.2 for Android emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:8000/api/v1";
    }
    return "http://localhost:8000/api/v1";
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

class ApiEndpoints {
  ApiEndpoints._();

  static const String health = "/health";
  static const String ready = "/ready";
  static const String login = "/auth/login";
  static const String refresh = "/auth/refresh";
  static const String logout = "/auth/logout";
  static const String me = "/auth/me";

  static const String doctors = "/doctors";
  static const String checkDoctorDuplicate = "/doctors/check-duplicate";
  static const String areas = "/areas";
  static const String associations = "/associations";

  static const String products = "/products";
  static const String visits = "/visits";
  static const String followups = "/follow-ups";
  static const String prescriptions = "/prescriptions";
  static const String orders = "/orders";
  static const String sales = "/sales";
  static const String expenses = "/expenses";
  static const String analyticsDashboard = "/analytics/dashboard";
  static const String sync = "/sync";
}
