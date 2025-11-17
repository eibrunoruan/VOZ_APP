import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/denuncias_datasource.dart';
import '../models/categoria_model.dart';
import '../models/create_denuncia_request.dart';
import '../models/delete_denuncia_response.dart';
import '../models/denuncia_model.dart';
import '../models/denuncia_response.dart';
import '../models/paginated_denuncias.dart';

/// Interface do repositório de denúncias
abstract class DenunciasRepository {
  Future<List<CategoriaModel>> getCategorias();
  Future<DenunciaResponse> createDenuncia(CreateDenunciaRequest request);
  Future<PaginatedDenuncias> getDenuncias({
    int page = 1,
    int pageSize = 10,
    String? status,
    int? categoria,
  });
  Future<DenunciaModel> getDenunciaById(int id);
  Future<DenunciaModel> updateDenuncia(int id, Map<String, dynamic> data);
  Future<DeleteDenunciaResponse> deleteDenuncia(int id);
  Future<DenunciaModel> resolverDenuncia(int id);
  Future<void> apoiarDenuncia(int denunciaId);
  Future<DenunciaModel> changeStatus(int id, String status);
}

/// Implementação do repositório de denúncias
class DenunciasRepositoryImpl implements DenunciasRepository {
  final DenunciasDatasource _datasource;

  DenunciasRepositoryImpl(this._datasource);

  @override
  Future<List<CategoriaModel>> getCategorias() async {
    return await _datasource.getCategorias();
  }

  @override
  Future<DenunciaResponse> createDenuncia(CreateDenunciaRequest request) async {
    return await _datasource.createDenuncia(request);
  }

  @override
  Future<PaginatedDenuncias> getDenuncias({
    int page = 1,
    int pageSize = 10,
    String? status,
    int? categoria,
  }) async {
    return await _datasource.getDenuncias(
      page: page,
      pageSize: pageSize,
      status: status,
      categoria: categoria,
    );
  }

  @override
  Future<DenunciaModel> getDenunciaById(int id) async {
    return await _datasource.getDenunciaById(id);
  }

  @override
  Future<DenunciaModel> updateDenuncia(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _datasource.updateDenuncia(id, data);
  }

  @override
  Future<DeleteDenunciaResponse> deleteDenuncia(int id) async {
    return await _datasource.deleteDenuncia(id);
  }

  @override
  Future<DenunciaModel> resolverDenuncia(int id) async {
    return await _datasource.resolverDenuncia(id);
  }

  @override
  Future<void> apoiarDenuncia(int denunciaId) async {
    return await _datasource.apoiarDenuncia(denunciaId);
  }

  @override
  Future<DenunciaModel> changeStatus(int id, String status) async {
    return await _datasource.changeStatus(id, status);
  }
}

/// Provider do repositório
final denunciasRepositoryProvider = Provider<DenunciasRepository>((ref) {
  return DenunciasRepositoryImpl(ref.watch(denunciasDatasourceProvider));
});
