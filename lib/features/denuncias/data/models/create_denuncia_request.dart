import 'dart:io';

/// Request para criar uma nova denúncia
class CreateDenunciaRequest {
  final String titulo;
  final String descricao;
  final int categoria;
  final int cidade;
  final int estado;
  final double latitude;
  final double longitude;
  final String? endereco;
  final String jurisdicao;
  final File? foto;

  const CreateDenunciaRequest({
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.cidade,
    required this.estado,
    required this.latitude,
    required this.longitude,
    this.endereco,
    required this.jurisdicao,
    this.foto,
  });

  /// Converte para FormData para envio multipart
  Map<String, dynamic> toFormData() {
    final data = {
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria.toString(),
      'cidade': cidade.toString(),
      'estado': estado.toString(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'jurisdicao': jurisdicao,
    };
    
    // Adiciona endereço se disponível
    if (endereco != null && endereco!.isNotEmpty) {
      data['endereco'] = endereco!;
    }
    
    return data;
  }
}
