import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/estado_model.dart';
import '../../data/models/cidade_model.dart';
import '../../data/repositories/localidades_repository.dart';
import '../../../../core/exceptions/localidades_exceptions.dart';

/// Estado do notifier de estados
class EstadosState extends Equatable {
  final List<EstadoModel> estados;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastLoadedAt;

  const EstadosState({
    this.estados = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastLoadedAt,
  });

  EstadosState copyWith({
    List<EstadoModel>? estados,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastLoadedAt,
  }) {
    return EstadosState(
      estados: estados ?? this.estados,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastLoadedAt: lastLoadedAt ?? this.lastLoadedAt,
    );
  }

  @override
  List<Object?> get props => [estados, isLoading, errorMessage, lastLoadedAt];
}

/// Notifier para gerenciar estados com cache
class EstadosNotifier extends StateNotifier<EstadosState> {
  final LocalidadesRepository _repository;
  static const _cacheDuration = Duration(hours: 24);

  EstadosNotifier(this._repository) : super(const EstadosState());

  /// Carrega lista de estados com cache
  Future<void> loadEstados({bool forceRefresh = false}) async {
    // Verifica se cache ainda é válido
    if (!forceRefresh &&
        state.estados.isNotEmpty &&
        state.lastLoadedAt != null &&
        DateTime.now().difference(state.lastLoadedAt!) < _cacheDuration) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final estados = await _repository.getEstados();
      state = state.copyWith(
        estados: estados,
        isLoading: false,
        lastLoadedAt: DateTime.now(),
      );
    } on LocalidadesException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado ao carregar estados',
      );
    }
  }

  /// Busca estado por ID
  EstadoModel? getEstadoById(int id) {
    try {
      return state.estados.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Força recarregamento dos dados
  Future<void> refresh() async {
    await loadEstados(forceRefresh: true);
  }
}

/// Provider do notifier de estados
final estadosNotifierProvider =
    StateNotifierProvider<EstadosNotifier, EstadosState>((ref) {
  return EstadosNotifier(ref.read(localidadesRepositoryProvider));
});

/// Estado do notifier de cidades
class CidadesState extends Equatable {
  final Map<int, List<CidadeModel>> cidadesPorEstado;
  final bool isLoading;
  final String? errorMessage;
  final int? currentEstadoId;

  const CidadesState({
    this.cidadesPorEstado = const {},
    this.isLoading = false,
    this.errorMessage,
    this.currentEstadoId,
  });

  List<CidadeModel> get cidades {
    if (currentEstadoId == null) return [];
    return cidadesPorEstado[currentEstadoId] ?? [];
  }

  CidadesState copyWith({
    Map<int, List<CidadeModel>>? cidadesPorEstado,
    bool? isLoading,
    String? errorMessage,
    int? currentEstadoId,
  }) {
    return CidadesState(
      cidadesPorEstado: cidadesPorEstado ?? this.cidadesPorEstado,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentEstadoId: currentEstadoId ?? this.currentEstadoId,
    );
  }

  @override
  List<Object?> get props =>
      [cidadesPorEstado, isLoading, errorMessage, currentEstadoId];
}

/// Notifier para gerenciar cidades com cache por estado
class CidadesNotifier extends StateNotifier<CidadesState> {
  final LocalidadesRepository _repository;

  CidadesNotifier(this._repository) : super(const CidadesState());

  /// Carrega cidades de um estado específico
  Future<void> loadCidades(int estadoId, {bool forceRefresh = false}) async {
    // Verifica se já tem cache para este estado
    if (!forceRefresh && state.cidadesPorEstado.containsKey(estadoId)) {
      state = state.copyWith(currentEstadoId: estadoId);
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentEstadoId: estadoId,
    );

    try {
      final cidades = await _repository.getCidades(estadoId: estadoId);
      final newCache = Map<int, List<CidadeModel>>.from(state.cidadesPorEstado);
      newCache[estadoId] = cidades;

      state = state.copyWith(
        cidadesPorEstado: newCache,
        isLoading: false,
      );
    } on LocalidadesException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado ao carregar cidades',
      );
    }
  }

  /// Busca cidade por ID no cache
  CidadeModel? getCidadeById(int id) {
    for (final cidades in state.cidadesPorEstado.values) {
      try {
        return cidades.firstWhere((c) => c.id == id);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Limpa cache e estado atual
  void clear() {
    state = const CidadesState();
  }

  /// Força recarregamento das cidades do estado atual
  Future<void> refresh() async {
    if (state.currentEstadoId != null) {
      await loadCidades(state.currentEstadoId!, forceRefresh: true);
    }
  }
}

/// Provider do notifier de cidades
final cidadesNotifierProvider =
    StateNotifierProvider<CidadesNotifier, CidadesState>((ref) {
  return CidadesNotifier(ref.read(localidadesRepositoryProvider));
});
