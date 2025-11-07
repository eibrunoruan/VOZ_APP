import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/auth_datasource.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';
import '../../../../config/dio/dio_client.dart'; // Para o secureStorageProvider

class AuthRepository {
  final AuthDatasource _datasource;
  final FlutterSecureStorage _secureStorage;

  AuthRepository(this._datasource, this._secureStorage);

  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await _datasource.login(username, password);
      await _secureStorage.write(key: 'access_token', value: response.access);
      await _secureStorage.write(key: 'refresh_token', value: response.refresh);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> register(RegisterRequest request) async {
    final user = await _datasource.register(request);
    return user;
  }

  Future<void> verifyEmail(String email, String code) async {
    await _datasource.verifyEmail(email, code);
  }

  Future<void> resendVerificationCode(String email) async {
    await _datasource.resendVerificationCode(email);
  }

  Future<void> requestPasswordReset(String email) async {
    await _datasource.requestPasswordReset(email);
  }

  Future<void> validatePasswordResetCode(String email, String code) async {
    await _datasource.validatePasswordResetCode(email, code);
  }

  Future<void> confirmPasswordReset(
    String email,
    String code,
    String newPassword,
  ) async {
    await _datasource.confirmPasswordReset(email, code, newPassword);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authDatasource = ref.watch(authDatasourceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(authDatasource, secureStorage);
});
