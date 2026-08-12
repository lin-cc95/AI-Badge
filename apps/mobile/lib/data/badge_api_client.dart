import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BadgeApiClient {
  BadgeApiClient({Dio? dio, FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _normalizedBaseUrl(),
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 30),
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) options.headers['authorization'] = 'Bearer $token';
          options.headers['x-request-id'] =
              '${DateTime.now().microsecondsSinceEpoch}';
          handler.next(options);
        },
      ),
    );
  }

  static const configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  final Dio _dio;
  final FlutterSecureStorage _storage;

  bool get enabled => _dio.options.baseUrl.isNotEmpty;

  static String _normalizedBaseUrl() {
    if (configuredApiBaseUrl.isEmpty || configuredApiBaseUrl.endsWith('/')) {
      return configuredApiBaseUrl;
    }
    return '$configuredApiBaseUrl/';
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/login',
        data: {'username': username, 'password': password},
      );
      final body = response.data!;
      await _storage.write(
        key: 'access_token',
        value: body['accessToken'] as String,
      );
      await _storage.write(
        key: 'refresh_token',
        value: body['refreshToken'] as String,
      );
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) return false;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createGenerationTask({
    required String styleId,
    required String personaId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'generation-tasks',
      data: {'styleId': styleId, 'personaId': personaId, 'tags': <String>[]},
      options: Options(headers: {'Idempotency-Key': _idempotencyKey()}),
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> generationTask(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'generation-tasks/$id',
    );
    return response.data!;
  }

  Future<void> bindVirtualDevice() async {
    await _dio.post<void>(
      'devices/bindings',
      data: {'deviceId': 'sim-badge-001', 'pairingToken': 'virtual-device'},
      options: Options(headers: {'Idempotency-Key': _idempotencyKey()}),
    );
  }

  Future<void> saveAction({
    required String eventType,
    required String text,
  }) async {
    await _dio.put<void>(
      'action-bindings',
      data: {
        'deviceId': 'sim-badge-001',
        'eventType': eventType,
        'feedbackType': 'emotion_text',
        'text': text,
      },
      options: Options(headers: {'Idempotency-Key': _idempotencyKey()}),
    );
  }

  String _idempotencyKey() => 'mobile-${DateTime.now().microsecondsSinceEpoch}';
}
