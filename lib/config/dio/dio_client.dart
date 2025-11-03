import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../env/env.dart';

// Provider para o flutter_secure_storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Provider principal do Dio
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  // Interceptor para logs (útil para debug)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('🌐 ${options.method} ${options.baseUrl}${options.path}');

        // Lista de endpoints públicos que não precisam de token
        final publicEndpoints = [
          '/api/auth/login/',
          '/api/auth/register/',
          '/api/auth/verify-email/',
          '/api/auth/password-reset/request/',
          '/api/auth/password-reset/validate-code/',
          '/api/auth/password-reset/confirm/',
          '/api/health/',
        ];

        // Verifica se o endpoint é público
        final isPublicEndpoint = publicEndpoints.any(
          (endpoint) => options.path.contains(endpoint),
        );

        // Adiciona o token apenas se NÃO for endpoint público
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

        // Tratamento específico para erro 403 (Forbidden)
        if (e.response?.statusCode == 403) {
          print('⛔ ERRO 403: Acesso negado');
          print('🔑 Headers enviados: ${e.requestOptions.headers}');
          print('💾 Data enviado: ${e.requestOptions.data}');
        }

        // Se o token expirar (erro 401), tenta renová-lo
        if (e.response?.statusCode == 401) {
          final storage = ref.read(secureStorageProvider);
          final refreshToken = await storage.read(key: 'refresh_token');

          if (refreshToken != null) {
            try {
              // Cria uma nova instância do Dio para a requisição de refresh
              final refreshDio = Dio(BaseOptions(baseUrl: Env.apiUrl));
              final response = await refreshDio.post(
                '/auth/login/refresh/',
                data: {'refresh': refreshToken},
              );

              if (response.statusCode == 200) {
                final newAccessToken = response.data['access'];
                await storage.write(key: 'access_token', value: newAccessToken);

                // Repete a requisição original com o novo token
                e.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final originalResponse = await dio.fetch(e.requestOptions);
                return handler.resolve(originalResponse);
              }
            } catch (refreshError) {
              // Se o refresh falhar, faz o logout
              await storage.deleteAll();
              // Aqui você pode redirecionar para a tela de login
            }
          }
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
