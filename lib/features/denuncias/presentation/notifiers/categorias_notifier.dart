import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/categoria_model.dart';
import '../../data/repositories/denuncias_repository.dart';

/// Estado das categorias
class CategoriasState {
  final List<CategoriaModel> categorias;
  final bool isLoading;
  final String? error;

  const CategoriasState({
    this.categorias = const [],
    this.isLoading = false,
    this.error,
  });

  CategoriasState copyWith({
    List<CategoriaModel>? categorias,
    bool? isLoading,
    String? error,
  }) {
    return CategoriasState(
      categorias: categorias ?? this.categorias,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier para gerenciar categorias
class CategoriasNotifier extends StateNotifier<CategoriasState> {
  final DenunciasRepository _repository;

  CategoriasNotifier(this._repository) : super(const CategoriasState());

  /// Carrega todas as categorias
  Future<void> loadCategorias() async {
    if (state.categorias.isNotEmpty && !state.isLoading) {
      // Já carregou, não precisa recarregar
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final categorias = await _repository.getCategorias();
      state = state.copyWith(
        categorias: categorias,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Força o recarregamento das categorias
  Future<void> refresh() async {
    state = const CategoriasState(isLoading: true);
    await loadCategorias();
  }

  /// Busca categoria por ID
  CategoriaModel? getCategoriaById(int id) {
    try {
      return state.categorias.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Provider do notifier de categorias
final categoriasNotifierProvider =
    StateNotifierProvider<CategoriasNotifier, CategoriasState>((ref) {
  return CategoriasNotifier(ref.watch(denunciasRepositoryProvider));
});

/// Provider para buscar categoria por ID
final categoriaByIdProvider =
    Provider.family<CategoriaModel?, int>((ref, id) {
  return ref.watch(categoriasNotifierProvider.notifier).getCategoriaById(id);
});
