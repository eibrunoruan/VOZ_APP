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
  DenunciasNotifier() : super(_denunciasExemplo);

  void addDenuncia(DenunciaModel denuncia) {
    state = [...state, denuncia];
  }

  void removeDenuncia(String id) {
    state = state.where((d) => d.id != id).toList();
  }
}

// Denúncias de exemplo para visualização
final _denunciasExemplo = [
  DenunciaModel(
    id: '1',
    titulo: 'Buraco na Avenida Principal',
    categoria: 'Infraestrutura',
    descricao: 'Grande buraco no meio da pista causando risco de acidentes',
    latitude: -23.550520,
    longitude: -46.633308,
    endereco: 'Av. Paulista, 1000 - São Paulo, SP',
    fotos: ['foto1.jpg', 'foto2.jpg'],
    dataCriacao: DateTime.now().subtract(const Duration(days: 2)),
    status: 'Aguardando Análise',
  ),
  DenunciaModel(
    id: '2',
    titulo: 'Iluminação Pública Quebrada',
    categoria: 'Infraestrutura',
    descricao: 'Postes sem iluminação na rua gerando insegurança',
    latitude: -23.551520,
    longitude: -46.634308,
    endereco: 'Rua Augusta, 500 - São Paulo, SP',
    fotos: [],
    dataCriacao: DateTime.now().subtract(const Duration(days: 5)),
    status: 'Em Análise',
  ),
  DenunciaModel(
    id: '3',
    titulo: 'Lixo Acumulado',
    categoria: 'Meio Ambiente',
    descricao: 'Acúmulo de lixo na praça atraindo animais e gerando mau cheiro',
    latitude: -23.552520,
    longitude: -46.635308,
    endereco: 'Praça da República - São Paulo, SP',
    fotos: ['foto3.jpg'],
    dataCriacao: DateTime.now().subtract(const Duration(days: 10)),
    status: 'Resolvida',
  ),
];

final denunciasProvider =
    StateNotifierProvider<DenunciasNotifier, List<DenunciaModel>>((ref) {
      return DenunciasNotifier();
    });
