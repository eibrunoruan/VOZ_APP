import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model simples para denúncia (apenas visual)
class DenunciaModel {
  final String id;
  final String titulo;
  final String categoria;
  final String descricao;
  final double latitude;
  final double longitude;
  final String endereco;
  final List<String> fotos;
  final DateTime dataCriacao;
  final String status;

  DenunciaModel({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    required this.endereco,
    required this.fotos,
    required this.dataCriacao,
    this.status = 'Aguardando Análise',
  });
}

// Provider para gerenciar a lista de denúncias
class DenunciasNotifier extends StateNotifier<List<DenunciaModel>> {
  DenunciasNotifier() : super([]);

  void addDenuncia(DenunciaModel denuncia) {
    state = [...state, denuncia];
  }

  void removeDenuncia(String id) {
    state = state.where((d) => d.id != id).toList();
  }
}

final denunciasProvider =
    StateNotifierProvider<DenunciasNotifier, List<DenunciaModel>>((ref) {
      return DenunciasNotifier();
    });
