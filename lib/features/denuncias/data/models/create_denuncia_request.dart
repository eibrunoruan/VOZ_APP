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
  final String? nomeConvidado;

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
    this.nomeConvidado,
  });

  /// Converte para FormData para envio multipart
  Map<String, dynamic> toFormData() {
    print('\n🔍 === CRIANDO FORMDATA ===');
    print('📝 Título: "$titulo"');
    print('📄 Descrição: "${descricao.substring(0, descricao.length > 50 ? 50 : descricao.length)}..."');
    print('🏷️ Categoria ID: $categoria');
    print('🏙️ Cidade ID: $cidade');
    print('🗺️ Estado ID: $estado');
    print('📍 Latitude: $latitude');
    print('📍 Longitude: $longitude');
    print('⚖️ Jurisdição: $jurisdicao');
    print('👤 Nome Convidado: ${nomeConvidado ?? "(null)"}');
    print('🏠 Endereço: ${endereco ?? "(null)"}');
    print('📸 Foto: ${foto != null ? "SIM (${foto!.path})" : "NÃO"}');
    
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
      print('✅ Endereço adicionado ao FormData');
    }
    
    // Adiciona autor_convidado se fornecido
    if (nomeConvidado != null && nomeConvidado!.isNotEmpty) {
      data['autor_convidado'] = nomeConvidado!;
      print('✅ autor_convidado adicionado: "$nomeConvidado"');
    } else {
      print('⚠️ autor_convidado NÃO adicionado (null ou vazio)');
      print('   nomeConvidado é null: ${nomeConvidado == null}');
      if (nomeConvidado != null) {
        print('   nomeConvidado isEmpty: ${nomeConvidado!.isEmpty}');
        print('   nomeConvidado length: ${nomeConvidado!.length}');
      }
    }
    
    print('\n📦 FormData final (${data.length} campos):');
    data.forEach((key, value) {
      print('   $key: "$value"');
    });
    print('=========================\n');
    
    return data;
  }
}
