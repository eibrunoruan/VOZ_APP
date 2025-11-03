import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../config/dio/dio_client.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

// Contrato da fonte de dados de autenticação
abstract class AuthDatasource {
  Future<LoginResponse> login(String username, String password);
  Future<User> register(RegisterRequest request);
  Future<void> verifyEmail(String email, String code);
  Future<void> resendVerificationCode(String email);
  Future<void> requestPasswordReset(String email);
  Future<void> validatePasswordResetCode(String email, String code);
  Future<void> confirmPasswordReset(
    String email,
    String code,
    String newPassword,
  );
  Future<void> logout();
}

// Implementação da fonte de dados
class AuthDatasourceImpl implements AuthDatasource {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthDatasourceImpl(this._dio, this._storage);

  @override
  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login/',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        // Armazena os tokens de forma segura
        await _storage.write(key: 'access_token', value: loginResponse.access);
        await _storage.write(
          key: 'refresh_token',
          value: loginResponse.refresh,
        );
        return loginResponse;
      } else {
        throw UnknownAuthException('Erro no login: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMsg =
            e.response?.data['error'] ?? e.response?.data['detail'] ?? '';
        if (errorMsg.toLowerCase().contains('email') &&
            errorMsg.toLowerCase().contains('verific')) {
          throw const EmailNotVerifiedException();
        }
        throw InvalidCredentialsException(errorMsg);
      } else if (e.response?.statusCode == 401) {
        throw const InvalidCredentialsException();
      } else if (e.response?.statusCode == 403) {
        final errorMsg =
            e.response?.data['error'] ??
            e.response?.data['detail'] ??
            'Acesso negado. Verifique suas credenciais.';
        throw UnknownAuthException(errorMsg);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw UnknownAuthException('Erro de conexão: ${e.message}');
    }
  }

  @override
  Future<User> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/api/auth/register/',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return User.fromJson(response.data);
      } else {
        throw UnknownAuthException('Erro no registro: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;

        // Verifica erros específicos de campo
        if (data is Map) {
          if (data['email'] != null) {
            throw EmailAlreadyExistsException(data['email'][0]);
          }
          if (data['username'] != null) {
            throw UsernameAlreadyExistsException(data['username'][0]);
          }
        }

        throw UnknownAuthException('Dados inválidos: ${e.response?.data}');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw UnknownAuthException('Erro de conexão: ${e.message}');
    }
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    try {
      final response = await _dio.post(
        '/api/auth/verify-email/',
        data: {'email': email, 'code': code},
      );

      if (response.statusCode != 200) {
        throw UnknownAuthException(
          'Erro na verificação: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw const InvalidVerificationCodeException();
      } else if (e.response?.statusCode == 403) {
        throw UnknownAuthException(
          e.response?.data['error'] ?? 'Acesso negado',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw UnknownAuthException('Erro de conexão: ${e.message}');
    }
  }

  @override
  Future<void> resendVerificationCode(String email) async {
    try {
      final response = await _dio.post(
        '/api/auth/resend-verification/',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw UnknownAuthException(
          'Erro ao reenviar código: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw UnknownAuthException(
          e.response?.data['error'] ?? 'Acesso negado',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw UnknownAuthException('Erro de conexão: ${e.message}');
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        '/api/auth/password-reset/request/',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw UnknownAuthException(
          'Erro ao solicitar reset: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw UnknownAuthException(
          e.response?.data['error'] ??
              'Acesso negado ao solicitar reset de senha',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw UnknownAuthException('Erro de conexão: ${e.message}');
    }
  }

  @override
  Future<void> validatePasswordResetCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '/api/auth/password-reset/validate-code/',
        data: {'email': email, 'code': code},
      );

      if (response.statusCode != 200) {
        throw UnknownAuthException(
          'Erro ao validar código: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMsg =
            e.response?.data['error'] ??
            e.response?.data['detail'] ??
            'Código de verificação inválido ou expirado';
        throw InvalidVerificationCodeException(errorMsg);
      } else if (e.response?.statusCode == 403) {
        throw UnknownAuthException(
          e.response?.data['error'] ?? 'Acesso negado',
        );
      } else if (e.response?.statusCode == 404) {
        throw UnknownAuthException('Usuário não encontrado');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw UnknownAuthException('Erro de conexão: ${e.message}');
    }
  }

  @override
  Future<void> confirmPasswordReset(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/password-reset/confirm/',
        data: {'email': email, 'code': code, 'password': newPassword},
      );

      if (response.statusCode != 200) {
        throw UnknownAuthException(
          'Erro ao redefinir senha: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw const InvalidVerificationCodeException(
          'Código de redefinição inválido ou expirado',
        );
      } else if (e.response?.statusCode == 403) {
        throw UnknownAuthException(
          e.response?.data['error'] ?? 'Acesso negado ao redefinir senha',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw UnknownAuthException('Erro de conexão: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    // Limpa os tokens do armazenamento seguro
    await _storage.deleteAll();
  }
}

// Provider para a implementação do datasource
final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  return AuthDatasourceImpl(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  );
});
