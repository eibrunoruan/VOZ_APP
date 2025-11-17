import 'denuncia_model.dart';

/// Resposta ao criar uma denúncia (pode ser nova denúncia ou apoio)
class DenunciaResponse {
  final bool apoioAdicionado;
  final String? message;
  final DenunciaModel denuncia;

  const DenunciaResponse({
    required this.apoioAdicionado,
    this.message,
    required this.denuncia,
  });

  factory DenunciaResponse.fromJson(Map<String, dynamic> json) {
    // Se tem "apoio_adicionado", significa que foi agrupada
    final bool apoioAdicionado = json['apoio_adicionado'] as bool? ?? false;
    
    // A denúncia pode estar em "denuncia" (quando agrupada) ou direto no root
    final denunciaData = json['denuncia'] ?? json;
    
    return DenunciaResponse(
      apoioAdicionado: apoioAdicionado,
      message: json['message'] as String?,
      denuncia: DenunciaModel.fromJson(denunciaData as Map<String, dynamic>),
    );
  }
}
