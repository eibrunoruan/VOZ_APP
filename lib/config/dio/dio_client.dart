import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/autenticacao/presentation/notifiers/auth_notifier.dart';
import '../env/env.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
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
          
          // Verifica se é usuário guest - não deve enviar token
          final authState = ref.read(authNotifierProvider);
          final isGuest = authState.isGuest;
          
          if (token != null && !isGuest) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🔑 Token adicionado à requisição');
          } else if (isGuest) {
            print('👤 Usuário guest - sem token');
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

        // Retry logic para timeouts e erros de rede
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.response?.statusCode == 503) {
          
          final retries = e.requestOptions.extra['retries'] ?? 0;
          const maxRetries = 3;
          
          if (retries < maxRetries) {
            // Exponential backoff: 2s, 4s, 8s
            final delaySeconds = 2 << retries;
            print('🔄 Tentando novamente em ${delaySeconds}s (tentativa ${retries + 1}/$maxRetries)');
            
            await Future.delayed(Duration(seconds: delaySeconds));
            
            // Incrementa contador de retries
            e.requestOptions.extra['retries'] = retries + 1;
            
            try {
              final response = await dio.fetch(e.requestOptions);
              return handler.resolve(response);
            } catch (retryError) {
              // Se falhar após todos os retries, propaga o erro
              if (retries + 1 >= maxRetries) {
                print('❌ Falhou após $maxRetries tentativas');
                return handler.next(e);
              }
            }
          }
        }

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
