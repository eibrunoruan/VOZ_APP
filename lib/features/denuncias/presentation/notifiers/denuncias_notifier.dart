import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/denuncia_exceptions.dart';
import '../../data/models/create_denuncia_request.dart';
import '../../data/models/delete_denuncia_response.dart';
import '../../data/models/denuncia_model.dart';
import '../../data/models/denuncia_response.dart';
import '../../data/repositories/denuncias_repository.dart';

/// Estado das denúncias
class DenunciasState {
  final List<DenunciaModel> denuncias;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? statusFilter;
  final int? categoriaFilter;

  const DenunciasState({
    this.denuncias = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.statusFilter,
    this.categoriaFilter,
  });

  DenunciasState copyWith({
    List<DenunciaModel>? denuncias,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? statusFilter,
    int? categoriaFilter,
    bool clearError = false,
  }) {
    return DenunciasState(
      denuncias: denuncias ?? this.denuncias,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      statusFilter: statusFilter ?? this.statusFilter,
      categoriaFilter: categoriaFilter ?? this.categoriaFilter,
    );
  }
}

/// Notifier para gerenciar denúncias
class DenunciasNotifier extends StateNotifier<DenunciasState> {
  final DenunciasRepository _repository;

  DenunciasNotifier(this._repository) : super(const DenunciasState());

  /// Carrega TODAS as denúncias (para o mapa)
  Future<void> loadAllDenuncias({
    String? status,
    int? categoria,
    bool forceRefresh = false,
  }) async {
    // Se já está carregando, não faz nada
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      clearError: true,
      statusFilter: status,
      categoriaFilter: categoria,
    );

    try {
      final result = await _repository.getDenuncias(
        page: 1,
        status: status,
        categoria: categoria,
        minhasDenuncias: false, // Carrega TODAS as denúncias
      );

      state = state.copyWith(
        denuncias: result.results,
        isLoading: false,
        currentPage: 1,
        hasMore: result.hasMore,
        clearError: true,
      );
    } on DenunciaException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar denúncias',
      );
    }
  }

  /// Carrega denúncias DO USUÁRIO (para lista "Minhas Denúncias")
  Future<void> loadDenuncias({
    String? status,
    int? categoria,
    bool forceRefresh = false,
  }) async {
    // Se já está carregando, não faz nada
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      clearError: true,
      statusFilter: status,
      categoriaFilter: categoria,
    );

    try {
      final result = await _repository.getDenuncias(
        page: 1,
        status: status,
        categoria: categoria,
        minhasDenuncias: true, // Apenas denúncias do usuário
      );

      state = state.copyWith(
        denuncias: result.results,
        isLoading: false,
        currentPage: 1,
        hasMore: result.hasMore,
        clearError: true,
      );
    } on DenunciaException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar denúncias',
      );
    }
  }

  /// Carrega mais denúncias (paginação)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getDenuncias(
        page: nextPage,
        status: state.statusFilter,
        categoria: state.categoriaFilter,
        minhasDenuncias: true, // Sempre filtrar para usuário atual
      );

      state = state.copyWith(
        denuncias: [...state.denuncias, ...result.results],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: result.hasMore,
        clearError: true,
      );
    } on DenunciaException catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Erro ao carregar mais denúncias',
      );
    }
  }

  /// Atualiza filtros e recarrega
  Future<void> updateFilters({String? status, int? categoria}) async {
    state = state.copyWith(
      denuncias: [],
      currentPage: 1,
      hasMore: true,
      statusFilter: status,
      categoriaFilter: categoria,
      clearError: true,
    );
    await loadDenuncias(status: status, categoria: categoria);
  }

  /// Recarrega denúncias (pull to refresh)
  Future<void> refresh() async {
    state = const DenunciasState();
    await loadDenuncias(
      status: state.statusFilter,
      categoria: state.categoriaFilter,
      forceRefresh: true,
    );
  }

  /// Cria uma nova denúncia
  Future<DenunciaResponse> createDenuncia(
    CreateDenunciaRequest request,
  ) async {
    try {
      final response = await _repository.createDenuncia(request);
      
      // Atualiza a lista localmente adicionando a denúncia
      final updatedList = [response.denuncia, ...state.denuncias];
      state = state.copyWith(denuncias: updatedList);
      
      return response;
    } on DenunciaException {
      rethrow;
    } catch (e) {
      throw UnknownDenunciaException('Erro ao criar denúncia: $e');
    }
  }

  /// Deleta uma denúncia
  Future<DeleteDenunciaResponse> deleteDenuncia(int id) async {
    try {
      final response = await _repository.deleteDenuncia(id);
      
      // Remove da lista local
      final updatedList = state.denuncias.where((d) => d.id != id).toList();
      state = state.copyWith(denuncias: updatedList);
      
      return response;
    } on DenunciaException {
      rethrow;
    }
  }

  /// Marca denúncia como resolvida
  Future<void> resolverDenuncia(int id) async {
    try {
      final updated = await _repository.resolverDenuncia(id);
      
      // Atualiza na lista local
      final updatedList = state.denuncias.map((d) {
        return d.id == id ? updated : d;
      }).toList();
      
      state = state.copyWith(denuncias: updatedList);
    } on DenunciaException {
      rethrow;
    }
  }

  /// Apoia uma denúncia
  Future<void> apoiarDenuncia(int denunciaId) async {
    try {
      await _repository.apoiarDenuncia(denunciaId);
      
      // Atualiza contador de apoios localmente
      final updatedList = state.denuncias.map((d) {
        if (d.id == denunciaId) {
          return d.copyWith(
            totalApoios: d.totalApoios + 1,
            usuarioApoiou: true,
          );
        }
        return d;
      }).toList();
      
      state = state.copyWith(denuncias: updatedList);
    } on DenunciaException {
      rethrow;
    }
  }

  /// Busca denúncia por ID na lista local
  DenunciaModel? getDenunciaById(int id) {
    try {
      return state.denuncias.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Provider do notifier de denúncias
final denunciasNotifierProvider =
    StateNotifierProvider<DenunciasNotifier, DenunciasState>((ref) {
  return DenunciasNotifier(ref.watch(denunciasRepositoryProvider));
});

/// Provider para buscar denúncia por ID (carrega da API se necessário)
final denunciaByIdProvider =
    FutureProvider.family<DenunciaModel, int>((ref, id) async {
  // Primeiro tenta buscar na lista local
  final localDenuncia = ref
      .watch(denunciasNotifierProvider.notifier)
      .getDenunciaById(id);
  
  if (localDenuncia != null) {
    return localDenuncia;
  }
  
  // Se não encontrar localmente, busca na API
  final repository = ref.watch(denunciasRepositoryProvider);
  return await repository.getDenunciaById(id);
});
