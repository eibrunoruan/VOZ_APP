import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/localidades_datasource.dart';
import '../models/estado_model.dart';
import '../models/cidade_model.dart';
import '../models/analisar_localizacao_response.dart';

/// Provider do repository de localidades
final localidadesRepositoryProvider = Provider<LocalidadesRepository>((ref) {
  return LocalidadesRepository(ref.read(localidadesDatasourceProvider));
});

/// Repository que abstrai a lógica de acesso a dados de localidades
class LocalidadesRepository {
  final LocalidadesDatasource _datasource;

  LocalidadesRepository(this._datasource);

  /// Lista todos os estados
  Future<List<EstadoModel>> getEstados() async {
    return await _datasource.getEstados();
  }

  /// Busca estado por ID
  Future<EstadoModel> getEstadoById(int id) async {
    return await _datasource.getEstadoById(id);
  }

  /// Lista cidades (opcionalmente por estado)
  Future<List<CidadeModel>> getCidades({int? estadoId}) async {
    return await _datasource.getCidades(estadoId: estadoId);
  }

  /// Busca cidade por ID
  Future<CidadeModel> getCidadeById(int id) async {
    return await _datasource.getCidadeById(id);
  }

  /// Analisa localização por coordenadas
  Future<AnalisarLocalizacaoResponse> analisarLocalizacao({
    required double latitude,
    required double longitude,
  }) async {
    return await _datasource.analisarLocalizacao(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
