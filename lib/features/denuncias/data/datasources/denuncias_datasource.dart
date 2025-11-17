import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/dio/dio_client.dart';
import '../../../../core/exceptions/denuncia_exceptions.dart';
import '../models/categoria_model.dart';
import '../models/create_denuncia_request.dart';
import '../models/delete_denuncia_response.dart';
import '../models/denuncia_model.dart';
import '../models/denuncia_response.dart';
import '../models/paginated_denuncias.dart';

/// Interface do datasource de denúncias
abstract class DenunciasDatasource {
  /// Busca todas as categorias disponíveis
  Future<List<CategoriaModel>> getCategorias();

  /// Cria uma nova denúncia
  Future<DenunciaResponse> createDenuncia(CreateDenunciaRequest request);

  /// Lista denúncias com paginação
  Future<PaginatedDenuncias> getDenuncias({
    int page = 1,
    int pageSize = 10,
    String? status,
    int? categoria,
  });

  /// Busca detalhes de uma denúncia
  Future<DenunciaModel> getDenunciaById(int id);

  /// Atualiza uma denúncia
  Future<DenunciaModel> updateDenuncia(int id, Map<String, dynamic> data);

  /// Deleta uma denúncia
  Future<DeleteDenunciaResponse> deleteDenuncia(int id);

  /// Marca denúncia como resolvida
  Future<DenunciaModel> resolverDenuncia(int id);

  /// Adiciona apoio a uma denúncia
  Future<void> apoiarDenuncia(int denunciaId);

  /// Altera status da denúncia (apenas gestores)
  Future<DenunciaModel> changeStatus(int id, String status);
}

/// Implementação do datasource de denúncias
class DenunciasDatasourceImpl implements DenunciasDatasource {
  final Dio _dio;

  DenunciasDatasourceImpl(this._dio);

  @override
  Future<List<CategoriaModel>> getCategorias() async {
    try {
      final response = await _dio.get('/api/denuncias/categorias/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => CategoriaModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw UnknownDenunciaException(
          'Erro ao buscar categorias: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<DenunciaResponse> createDenuncia(CreateDenunciaRequest request) async {
    try {
      // Prepara FormData para multipart/form-data
      final formData = FormData.fromMap(request.toFormData());

      // Adiciona foto se existir
      if (request.foto != null) {
        formData.files.add(
          MapEntry(
            'foto',
            await MultipartFile.fromFile(
              request.foto!.path,
              filename: request.foto!.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/api/denuncias/denuncias/',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('📝 Resposta da criação de denúncia:');
        print('📄 response.data: ${response.data}');
        print('📄 Tipo: ${response.data.runtimeType}');
        
        return DenunciaResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw UnknownDenunciaException(
          'Erro ao criar denúncia: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<PaginatedDenuncias> getDenuncias({
    int page = 1,
    int pageSize = 10,
    String? status,
    int? categoria,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (categoria != null) {
        queryParams['categoria'] = categoria;
      }

      final response = await _dio.get(
        '/api/denuncias/denuncias/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        try {
          // API pode retornar lista direta ou objeto paginado
          if (response.data is List) {
            // Formato: lista direta sem paginação
            final denuncias = (response.data as List<dynamic>)
                .map((e) => DenunciaModel.fromJson(e as Map<String, dynamic>))
                .toList();
            
            return PaginatedDenuncias(
              count: denuncias.length,
              next: null,
              previous: null,
              results: denuncias,
            );
          } else {
            // Formato: objeto paginado {count, next, previous, results}
            return PaginatedDenuncias.fromJson(
              response.data as Map<String, dynamic>,
            );
          }
        } catch (e, stackTrace) {
          print('❌ Erro ao parsear denúncias: $e');
          rethrow;
        }
      } else {
        throw UnknownDenunciaException(
          'Erro ao buscar denúncias: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<DenunciaModel> getDenunciaById(int id) async {
    try {
      final response = await _dio.get('/api/denuncias/denuncias/$id/');

      if (response.statusCode == 200) {
        return DenunciaModel.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw const DenunciaNotFoundException();
      } else {
        throw UnknownDenunciaException(
          'Erro ao buscar denúncia: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<DenunciaModel> updateDenuncia(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch(
        '/api/denuncias/denuncias/$id/',
        data: data,
      );

      if (response.statusCode == 200) {
        return DenunciaModel.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw const DenunciaNotFoundException();
      } else if (response.statusCode == 403) {
        throw const DenunciaUnauthorizedException();
      } else {
        throw UnknownDenunciaException(
          'Erro ao atualizar denúncia: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<DeleteDenunciaResponse> deleteDenuncia(int id) async {
    try {
      print('🌐 DELETE /api/denuncias/denuncias/$id/');
      final response = await _dio.delete('/api/denuncias/denuncias/$id/');

      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Resposta com informações sobre transferência de apoios
        return DeleteDenunciaResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else if (response.statusCode == 204) {
        // Deleção simples sem apoios
        return const DeleteDenunciaResponse(
          message: 'Denúncia deletada com sucesso!',
        );
      } else if (response.statusCode == 404) {
        throw const DenunciaNotFoundException();
      } else if (response.statusCode == 403) {
        throw const DenunciaUnauthorizedException();
      } else {
        throw UnknownDenunciaException(
          'Erro ao deletar denúncia: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('❌ Message: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      throw _handleDioException(e);
    }
  }

  @override
  Future<DenunciaModel> resolverDenuncia(int id) async {
    try {
      final response = await _dio.post('/api/denuncias/denuncias/$id/resolver/');

      if (response.statusCode == 200) {
        return DenunciaModel.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw const DenunciaNotFoundException();
      } else if (response.statusCode == 403) {
        throw const DenunciaUnauthorizedException();
      } else {
        throw UnknownDenunciaException(
          'Erro ao resolver denúncia: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<void> apoiarDenuncia(int denunciaId) async {
    try {
      final response = await _dio.post(
        '/api/denuncias/apoios/',
        data: {'denuncia': denunciaId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (response.statusCode == 404) {
          throw const DenunciaNotFoundException();
        } else if (response.statusCode == 400) {
          throw const InvalidDenunciaDataException('Você já apoiou esta denúncia');
        } else {
          throw UnknownDenunciaException(
            'Erro ao apoiar denúncia: ${response.statusCode}',
          );
        }
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<DenunciaModel> changeStatus(int id, String status) async {
    try {
      final response = await _dio.post(
        '/api/denuncias/denuncias/$id/change_status/',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return DenunciaModel.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw const DenunciaNotFoundException();
      } else if (response.statusCode == 403) {
        throw const DenunciaUnauthorizedException(
          'Apenas gestores podem alterar o status',
        );
      } else {
        throw UnknownDenunciaException(
          'Erro ao alterar status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Trata exceções do Dio e converte para exceções customizadas
  DenunciaException _handleDioException(DioException e) {
    if (e.response?.statusCode == 404) {
      return const DenunciaNotFoundException();
    } else if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
      return const DenunciaUnauthorizedException();
    } else if (e.response?.statusCode == 400) {
      final errorMsg = e.response?.data['error'] ??
          e.response?.data['detail'] ??
          'Dados inválidos';
      return InvalidDenunciaDataException(errorMsg);
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const DenunciaNetworkException();
    }
    return UnknownDenunciaException('Erro de conexão: ${e.message}');
  }
}

/// Provider do datasource
final denunciasDatasourceProvider = Provider<DenunciasDatasource>((ref) {
  return DenunciasDatasourceImpl(ref.watch(dioProvider));
});
