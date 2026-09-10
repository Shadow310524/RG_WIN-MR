import 'package:dio/dio.dart';

class NetworkExceptions {
  NetworkExceptions._();

  static String getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timed out. Please check your internet connection.";
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        // Try extracting user-facing message from unified error envelope
        if (data is Map && data.containsKey('error') && data['error'] is Map) {
          final errMap = data['error'] as Map;
          if (errMap.containsKey('message') && errMap['message'] is String) {
            return errMap['message'] as String;
          }
        }

        switch (statusCode) {
          case 400:
            return "Invalid request. Please verify your information.";
          case 401:
            return "Session expired. Please log in again.";
          case 403:
            return "You do not have permission to perform this action.";
          case 404:
            return "The requested record was not found.";
          case 409:
            return "A conflict occurred with an existing record.";
          case 422:
            return "Validation error. Please verify the entered fields.";
          case 500:
          case 502:
          case 503:
            return "Server temporarily unavailable. Please try again shortly.";
          default:
            return "An unexpected error occurred (HTTP $statusCode).";
        }
      case DioExceptionType.cancel:
        return "The request was cancelled.";
      case DioExceptionType.connectionError:
        return "Unable to connect to the server. You can continue working offline.";
      case DioExceptionType.unknown:
      default:
        return "A network error occurred. Please check your connection.";
    }
  }
}
