import 'package:dio/dio.dart';
import '../models/user_profile_model.dart';

abstract class ProfileDatasource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data);
}

class ProfileDatasourceImpl implements ProfileDatasource {
  final Dio _dio;

  ProfileDatasourceImpl(this._dio);

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await _dio.get('/api/auth/me/');

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw Exception('Erro ao buscar perfil: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Não autorizado. Faça login novamente.');
      }
      throw Exception('Erro ao buscar perfil: ${e.message}');
    }
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/api/auth/me/', data: data);

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw Exception('Erro ao atualizar perfil: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Não autorizado. Faça login novamente.');
      } else if (e.response?.statusCode == 400) {
        final errors = e.response?.data;
        if (errors is Map) {
          final errorMessages = errors.entries
              .map((entry) => '${entry.key}: ${entry.value}')
              .join(', ');
          throw Exception(errorMessages);
        }
      }
      throw Exception('Erro ao atualizar perfil: ${e.message}');
    }
  }
}
