import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../env/env.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('🌐 ${options.method} ${options.baseUrl}${options.path}');

        final publicEndpoints = [
          '/api/auth/login/',
          '/api/auth/register/',
          '/api/auth/verify-email/',
          '/api/auth/password-reset/request/',
          '/api/auth/password-reset/validate-code/',
          '/api/auth/password-reset/confirm/',
          '/api/health/',
        ];

        final isPublicEndpoint = publicEndpoints.any(
          (endpoint) => options.path.contains(endpoint),
        );

        if (!isPublicEndpoint) {
          final storage = ref.read(secureStorageProvider);
          final token = await storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🔑 Token adicionado à requisição');
          }
        } else {
          print('🌍 Endpoint público - sem token');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        print('❌ ERROR: ${e.type} - ${e.message}');
        print('🔗 URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}');
        print('📊 Status Code: ${e.response?.statusCode}');
        print('📄 Response Data: ${e.response?.data}');

        if (e.response?.statusCode == 403) {
          print('⛔ ERRO 403: Acesso negado');
          print('🔑 Headers enviados: ${e.requestOptions.headers}');
          print('💾 Data enviado: ${e.requestOptions.data}');
        }

        if (e.response?.statusCode == 401) {
          final storage = ref.read(secureStorageProvider);
          final refreshToken = await storage.read(key: 'refresh_token');

          if (refreshToken != null) {
            try {

              final refreshDio = Dio(BaseOptions(baseUrl: Env.apiUrl));
              final response = await refreshDio.post(
                '/auth/login/refresh/',
                data: {'refresh': refreshToken},
              );

              if (response.statusCode == 200) {
                final newAccessToken = response.data['access'];
                await storage.write(key: 'access_token', value: newAccessToken);

                e.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final originalResponse = await dio.fetch(e.requestOptions);
                return handler.resolve(originalResponse);
              }
            } catch (refreshError) {

              await storage.deleteAll();

            }
          }
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
