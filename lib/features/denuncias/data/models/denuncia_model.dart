import 'package:equatable/equatable.dart';

/// Modelo que representa uma denúncia do backend
class DenunciaModel extends Equatable {
  final int id;
  final String titulo;
  final String descricao;
  final int categoria;
  final String? categoriaNome;
  final int cidade;
  final String? cidadeNome;
  final int estado;
  final String? estadoNome;
  final double latitude;
  final double longitude;
  final String? endereco;
  final String jurisdicao;
  final String status;
  final String? foto;
  final int totalApoios;
  final int? autor; // Nullable para guests
  final String? autorUsername;
  final String? autorConvidado; // Nome do guest
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;
  final bool usuarioApoiou;
  final bool? ehAutor; // Se o usuário atual é o autor

  const DenunciaModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    this.categoriaNome,
    required this.cidade,
    this.cidadeNome,
    required this.estado,
    this.estadoNome,
    required this.latitude,
    required this.longitude,
    this.endereco,
    required this.jurisdicao,
    required this.status,
    this.foto,
    required this.totalApoios,
    this.autor, // Nullable
    this.autorUsername,
    this.autorConvidado, // Novo campo
    required this.dataCriacao,
    required this.dataAtualizacao,
    this.usuarioApoiou = false,
    this.ehAutor,
  });

  factory DenunciaModel.fromJson(Map<String, dynamic> json) {
    // Helper para parsear latitude/longitude que podem vir como string ou number
    double parseCoordinate(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.parse(value);
      }
      throw Exception('Valor inválido para coordenada: $value');
    }
    
    // Helper para parsear autor que pode vir como int, objeto ou null
    int? parseAutorId(dynamic value) {
      if (value == null) {
        return null; // Guest user
      } else if (value is int) {
        return value;
      } else if (value is Map) {
        return value['id'] as int?;
      }
      throw Exception('Valor inválido para autor: $value');
    }
    
    // Helper para parsear username do autor
    String? parseAutorUsername(dynamic value) {
      if (value is Map) {
        return value['username'] as String?;
      }
      return null;
    }
    
    return DenunciaModel(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      categoria: json['categoria'] as int,
      categoriaNome: json['categoria_nome'] as String?,
      cidade: json['cidade'] as int,
      cidadeNome: json['cidade_nome'] as String?,
      estado: json['estado'] as int,
      estadoNome: json['estado_nome'] as String?,
      latitude: parseCoordinate(json['latitude']),
      longitude: parseCoordinate(json['longitude']),
      endereco: json['endereco'] as String?,
      jurisdicao: json['jurisdicao'] as String,
      status: json['status'] as String,
      foto: json['foto'] as String?,
      totalApoios: json['total_apoios'] as int? ?? 0,
      autor: parseAutorId(json['autor']),
      autorUsername: json['autor_username'] as String? ?? parseAutorUsername(json['autor']),
      autorConvidado: json['autor_convidado'] as String?,
      dataCriacao: DateTime.parse(json['data_criacao'] as String),
      // data_atualizacao pode não existir em denúncias recém-criadas
      dataAtualizacao: json['data_atualizacao'] != null 
          ? DateTime.parse(json['data_atualizacao'] as String)
          : DateTime.parse(json['data_criacao'] as String),
      usuarioApoiou: json['usuario_apoiou'] as bool? ?? false,
      ehAutor: json['eh_autor'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'categoria_nome': categoriaNome,
      'cidade': cidade,
      'cidade_nome': cidadeNome,
      'estado': estado,
      'estado_nome': estadoNome,
      'latitude': latitude,
      'longitude': longitude,
      'endereco': endereco,
      'jurisdicao': jurisdicao,
      'status': status,
      'foto': foto,
      'total_apoios': totalApoios,
      'autor': autor,
      'autor_username': autorUsername,
      'autor_convidado': autorConvidado,
      'data_criacao': dataCriacao.toIso8601String(),
      'data_atualizacao': dataAtualizacao.toIso8601String(),
      'usuario_apoiou': usuarioApoiou,
      'eh_autor': ehAutor,
    };
  }

  /// Copia o modelo com novos valores
  DenunciaModel copyWith({
    int? id,
    String? titulo,
    String? descricao,
    int? categoria,
    String? categoriaNome,
    int? cidade,
    String? cidadeNome,
    int? estado,
    String? estadoNome,
    double? latitude,
    double? longitude,
    String? endereco,
    String? jurisdicao,
    String? status,
    String? foto,
    int? totalApoios,
    int? autor,
    String? autorUsername,
    String? autorConvidado,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    bool? usuarioApoiou,
    bool? ehAutor,
  }) {
    return DenunciaModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      categoriaNome: categoriaNome ?? this.categoriaNome,
      cidade: cidade ?? this.cidade,
      cidadeNome: cidadeNome ?? this.cidadeNome,
      estado: estado ?? this.estado,
      estadoNome: estadoNome ?? this.estadoNome,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      endereco: endereco ?? this.endereco,
      jurisdicao: jurisdicao ?? this.jurisdicao,
      status: status ?? this.status,
      foto: foto ?? this.foto,
      totalApoios: totalApoios ?? this.totalApoios,
      autor: autor ?? this.autor,
      autorUsername: autorUsername ?? this.autorUsername,
      autorConvidado: autorConvidado ?? this.autorConvidado,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      usuarioApoiou: usuarioApoiou ?? this.usuarioApoiou,
      ehAutor: ehAutor ?? this.ehAutor,
    );
  }

  @override
  List<Object?> get props => [
        id,
        titulo,
        descricao,
        categoria,
        categoriaNome,
        cidade,
        cidadeNome,
        estado,
        estadoNome,
        latitude,
        longitude,
        endereco,
        jurisdicao,
        status,
        foto,
        totalApoios,
        autor,
        autorUsername,
        autorConvidado,
        dataCriacao,
        dataAtualizacao,
        usuarioApoiou,
        ehAutor,
      ];
}
