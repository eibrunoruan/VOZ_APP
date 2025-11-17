/// Classe para validação de campos da denúncia
class DenunciaValidator {
  /// Resultado da validação
  final bool tituloError;
  final bool categoriaError;
  final bool descricaoError;
  final bool localizacaoError;
  final bool enderecoError;
  
  final String? tituloErrorMessage;
  final String? categoriaErrorMessage;
  final String? descricaoErrorMessage;
  final String? localizacaoErrorMessage;
  final String? enderecoErrorMessage;
  
  const DenunciaValidator({
    required this.tituloError,
    required this.categoriaError,
    required this.descricaoError,
    required this.localizacaoError,
    required this.enderecoError,
    this.tituloErrorMessage,
    this.categoriaErrorMessage,
    this.descricaoErrorMessage,
    this.localizacaoErrorMessage,
    this.enderecoErrorMessage,
  });
  
  /// Retorna true se houver algum erro
  bool get hasError => 
    tituloError || categoriaError || descricaoError || localizacaoError || enderecoError;
  
  /// Valida campos obrigatórios
  factory DenunciaValidator.validate({
    required String titulo,
    required int? categoriaId,
    required String descricao,
    required double? latitude,
    required double? longitude,
    required String endereco,
  }) {
    final tituloVazio = titulo.trim().isEmpty;
    final categoriaVazia = categoriaId == null;
    final descricaoVazia = descricao.trim().isEmpty;
    final localizacaoVazia = latitude == null || longitude == null;
    final enderecoVazio = endereco.trim().isEmpty;
    
    return DenunciaValidator(
      tituloError: tituloVazio,
      categoriaError: categoriaVazia,
      descricaoError: descricaoVazia,
      localizacaoError: localizacaoVazia,
      enderecoError: enderecoVazio,
      tituloErrorMessage: tituloVazio ? 'Digite um título para a denúncia' : null,
      categoriaErrorMessage: categoriaVazia ? 'Selecione uma categoria' : null,
      descricaoErrorMessage: descricaoVazia ? 'Descreva a situação' : null,
      localizacaoErrorMessage: localizacaoVazia ? 'Informe a localização no mapa' : null,
      enderecoErrorMessage: enderecoVazio ? 'Endereço não foi carregado. Tente novamente.' : null,
    );
  }
}
