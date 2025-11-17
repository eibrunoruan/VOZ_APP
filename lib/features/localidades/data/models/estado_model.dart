import 'package:equatable/equatable.dart';

/// Model para Estado do IBGE
class EstadoModel extends Equatable {
  final int id;
  final String sigla;
  final String nome;
  final String regiao;

  const EstadoModel({
    required this.id,
    required this.sigla,
    required this.nome,
    required this.regiao,
  });

  factory EstadoModel.fromJson(Map<String, dynamic> json) {
    return EstadoModel(
      id: json['id'] as int,
      sigla: json['sigla'] as String,
      nome: json['nome'] as String,
      regiao: json['regiao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sigla': sigla,
      'nome': nome,
      'regiao': regiao,
    };
  }

  EstadoModel copyWith({
    int? id,
    String? sigla,
    String? nome,
    String? regiao,
  }) {
    return EstadoModel(
      id: id ?? this.id,
      sigla: sigla ?? this.sigla,
      nome: nome ?? this.nome,
      regiao: regiao ?? this.regiao,
    );
  }

  @override
  List<Object?> get props => [id, sigla, nome, regiao];

  @override
  String toString() => '$nome ($sigla)';
}
