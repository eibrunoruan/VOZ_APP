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

        // Token expirado pode retornar 401 ou 403 dependendo da configuração do backend
        final isTokenExpired = (e.response?.statusCode == 401 || 
                               e.response?.statusCode == 403) &&
                              e.response?.data.toString().contains('token') == true;

        if (isTokenExpired) {
          print('🔄 Token expirado. Tentando renovar...');
          final storage = ref.read(secureStorageProvider);
          final refreshToken = await storage.read(key: 'refresh_token');

          if (refreshToken != null) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: Env.apiUrl));
              final response = await refreshDio.post(
                '/api/auth/login/refresh/',
                data: {'refresh': refreshToken},
              );

              if (response.statusCode == 200) {
                final newAccessToken = response.data['access'];
                await storage.write(key: 'access_token', value: newAccessToken);
                print('✅ Token renovado com sucesso');

                // Retry da requisição original com novo token
                e.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final originalResponse = await dio.fetch(e.requestOptions);
                return handler.resolve(originalResponse);
              }
            } catch (refreshError) {
              print('❌ Erro ao renovar token: $refreshError');
              print('🚪 Fazendo logout automático...');
              await storage.deleteAll();
              // Aqui você pode adicionar navegação para tela de login se necessário
            }
          } else {
            print('⚠️ Refresh token não encontrado');
          }
        }
        
        return handler.next(e);
      },
    ),
  );

  return dio;
});
