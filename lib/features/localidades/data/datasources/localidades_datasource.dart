import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/dio/dio_client.dart';
import '../models/estado_model.dart';
import '../models/cidade_model.dart';
import '../models/analisar_localizacao_response.dart';
import '../../../../core/exceptions/localidades_exceptions.dart';

/// Provider do datasource de localidades
final localidadesDatasourceProvider = Provider<LocalidadesDatasource>((ref) {
  return LocalidadesDatasource(ref.read(dioProvider));
});

/// Datasource responsável por comunicação com API de localidades
class LocalidadesDatasource {
  final Dio _dio;

  LocalidadesDatasource(this._dio);

  /// Lista todos os estados do Brasil
  Future<List<EstadoModel>> getEstados() async {
    try {
      final response = await _dio.get('/api/localidades/estados/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => EstadoModel.fromJson(json)).toList();
      } else {
        throw LocalidadesException(
          'Erro ao buscar estados: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw EstadoNotFoundException('Estados não encontrados');
      }
      throw LocalidadesException(
        'Erro de conexão ao buscar estados: ${e.message}',
      );
    } catch (e) {
      throw LocalidadesException('Erro inesperado ao buscar estados: $e');
    }
  }

  /// Busca detalhes de um estado específico
  Future<EstadoModel> getEstadoById(int id) async {
    try {
      final response = await _dio.get('/api/localidades/estados/$id/');

      if (response.statusCode == 200) {
        return EstadoModel.fromJson(response.data);
      } else {
        throw EstadoNotFoundException('Estado com ID $id não encontrado');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw EstadoNotFoundException('Estado com ID $id não encontrado');
      }
      throw LocalidadesException(
        'Erro de conexão ao buscar estado: ${e.message}',
      );
    } catch (e) {
      throw LocalidadesException('Erro inesperado ao buscar estado: $e');
    }
  }

  /// Lista cidades (opcionalmente filtradas por estado)
  Future<List<CidadeModel>> getCidades({int? estadoId}) async {
    try {
      final queryParams = estadoId != null ? {'estado': estadoId} : null;
      final response = await _dio.get(
        '/api/localidades/cidades/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => CidadeModel.fromJson(json)).toList();
      } else {
        throw LocalidadesException(
          'Erro ao buscar cidades: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw CidadeNotFoundException('Cidades não encontradas');
      }
      throw LocalidadesException(
        'Erro de conexão ao buscar cidades: ${e.message}',
      );
    } catch (e) {
      throw LocalidadesException('Erro inesperado ao buscar cidades: $e');
    }
  }

  /// Busca detalhes de uma cidade específica
  Future<CidadeModel> getCidadeById(int id) async {
    try {
      final response = await _dio.get('/api/localidades/cidades/$id/');

      if (response.statusCode == 200) {
        return CidadeModel.fromJson(response.data);
      } else {
        throw CidadeNotFoundException('Cidade com ID $id não encontrada');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw CidadeNotFoundException('Cidade com ID $id não encontrada');
      }
      throw LocalidadesException(
        'Erro de conexão ao buscar cidade: ${e.message}',
      );
    } catch (e) {
      throw LocalidadesException('Erro inesperado ao buscar cidade: $e');
    }
  }

  /// Analisa coordenadas geográficas e retorna cidade, estado e jurisdição
  Future<AnalisarLocalizacaoResponse> analisarLocalizacao({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '/api/localidades/analisar/',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        print('📍 Resposta da API analisar localização:');
        print('📄 response.data: ${response.data}');
        print('📄 Tipo: ${response.data.runtimeType}');
        
        return AnalisarLocalizacaoResponse.fromJson(response.data);
      } else {
        throw LocalizacaoNaoEncontradaException(
          'Não foi possível determinar a localização para as coordenadas fornecidas',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw LocalizacaoNaoEncontradaException(
          'Localização não encontrada para as coordenadas fornecidas',
        );
      }
      throw LocalidadesException(
        'Erro de conexão ao analisar localização: ${e.message}',
      );
    } catch (e) {
      throw LocalidadesException(
        'Erro inesperado ao analisar localização: $e',
      );
    }
  }
}
