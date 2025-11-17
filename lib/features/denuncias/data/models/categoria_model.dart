import 'package:equatable/equatable.dart';

/// Modelo que representa uma categoria de denúncia
class CategoriaModel extends Equatable {
  final int id;
  final String nome;
  final String? icone;
  final String? cor;

  const CategoriaModel({
    required this.id,
    required this.nome,
    this.icone,
    this.cor,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      icone: json['icone'] as String?,
      cor: json['cor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      if (icone != null) 'icone': icone,
      if (cor != null) 'cor': cor,
    };
  }

  @override
  List<Object?> get props => [id, nome, icone, cor];
}
