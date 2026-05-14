import 'package:dio/dio.dart';

/// Configured Dio HTTP client for VR telemetry API integration.
///
/// Base URL should point to the backend ingesting Unity VR telemetry data.
/// Currently configured for local development; update for production deployment.
class ApiClient {
  static const String _baseUrl = 'https://api.neurolift.dev/v1';
  static const Duration _connectTimeout = Duration(seconds: 15);
  static const Duration _receiveTimeout = Duration(seconds: 15);

  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _loggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // ignore: avoid_print
        print('[API] --> ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        // ignore: avoid_print
        print('[API] <-- ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) {
        // ignore: avoid_print
        print('[API] ERROR: ${error.message}');
        handler.next(error);
      },
    );
  }
}
