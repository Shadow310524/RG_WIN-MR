import 'package:dio/dio.dart';
import 'package:rgwin_crm/core/config/app_config.dart';
import 'package:rgwin_crm/core/network/network_exceptions.dart';

class DioClient {
  late final Dio dio;

  DioClient({String? baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Future Phase 2: Attach Bearer token from FlutterSecureStorage
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final mappedError = NetworkExceptions.getErrorMessage(error);
          return handler.next(error.copyWith(error: mappedError));
        },
      ),
    );
  }
}
