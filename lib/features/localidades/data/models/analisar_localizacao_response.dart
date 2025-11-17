import 'package:equatable/equatable.dart';

/// Model para resposta da análise de localização por coordenadas
/// API retorna nomes E IDs das localidades
class AnalisarLocalizacaoResponse extends Equatable {
  final String? cidadeNome;
  final int? cidadeId;
  final bool? cidadeIdentificada;
  final String estadoNome;
  final int estadoId;
  final String jurisdicaoSugerida;
  final Map<String, dynamic>? dadosCompletosOsm;

  const AnalisarLocalizacaoResponse({
    this.cidadeNome,
    this.cidadeId,
    this.cidadeIdentificada,
    required this.estadoNome,
    required this.estadoId,
    required this.jurisdicaoSugerida,
    this.dadosCompletosOsm,
  });

  factory AnalisarLocalizacaoResponse.fromJson(Map<String, dynamic> json) {
    final estadoId = json['estado_id'];
    
    if (estadoId == null) {
      throw Exception(
        'Dados de localização inválidos: estado_id ausente na resposta'
      );
    }
    
    return AnalisarLocalizacaoResponse(
      cidadeNome: json['cidade'] as String?,
      cidadeId: json['cidade_id'] as int?,
      cidadeIdentificada: json['cidade_identificada'] as bool?,
      estadoNome: json['estado'] as String? ?? 'Desconhecido',
      estadoId: estadoId is int ? estadoId : int.parse(estadoId.toString()),
      jurisdicaoSugerida: json['jurisdicao_sugerida'] as String? ?? 'MUNICIPAL',
      dadosCompletosOsm: json['dados_completos_osm'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cidade': cidadeNome,
      'cidade_id': cidadeId,
      'cidade_identificada': cidadeIdentificada,
      'estado': estadoNome,
      'estado_id': estadoId,
      'jurisdicao_sugerida': jurisdicaoSugerida,
      'dados_completos_osm': dadosCompletosOsm,
    };
  }

  @override
  List<Object?> get props => [
        cidadeNome,
        cidadeId,
        cidadeIdentificada,
        estadoNome,
        estadoId,
        jurisdicaoSugerida,
        dadosCompletosOsm,
      ];

  @override
  String toString() => '$cidadeNome (ID: $cidadeId)/$estadoNome (ID: $estadoId) - $jurisdicaoSugerida';
}
