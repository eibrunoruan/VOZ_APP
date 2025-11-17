import 'package:equatable/equatable.dart';

/// Model para Cidade do IBGE
class CidadeModel extends Equatable {
  final int id;
  final String nome;
  final int estadoId;
  final String estadoSigla;
  final String estadoNome;

  const CidadeModel({
    required this.id,
    required this.nome,
    required this.estadoId,
    required this.estadoSigla,
    required this.estadoNome,
  });

  factory CidadeModel.fromJson(Map<String, dynamic> json) {
    return CidadeModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      estadoId: json['estado_id'] as int,
      estadoSigla: json['estado_sigla'] as String,
      estadoNome: json['estado_nome'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'estado_id': estadoId,
      'estado_sigla': estadoSigla,
      'estado_nome': estadoNome,
    };
  }

  CidadeModel copyWith({
    int? id,
    String? nome,
    int? estadoId,
    String? estadoSigla,
    String? estadoNome,
  }) {
    return CidadeModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      estadoId: estadoId ?? this.estadoId,
      estadoSigla: estadoSigla ?? this.estadoSigla,
      estadoNome: estadoNome ?? this.estadoNome,
    );
  }

  @override
  List<Object?> get props => [id, nome, estadoId, estadoSigla, estadoNome];

  @override
  String toString() => '$nome - $estadoSigla';
}
