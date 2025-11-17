/// Exceções relacionadas a denúncias

/// Exceção base para erros de denúncias
abstract class DenunciaException implements Exception {
  final String message;
  const DenunciaException([this.message = 'Erro ao processar denúncia']);

  @override
  String toString() => message;
}

/// Exceção quando a denúncia não é encontrada
class DenunciaNotFoundException extends DenunciaException {
  const DenunciaNotFoundException([super.message = 'Denúncia não encontrada']);
}

/// Exceção quando o usuário não tem permissão
class DenunciaUnauthorizedException extends DenunciaException {
  const DenunciaUnauthorizedException([
    super.message = 'Você não tem permissão para realizar esta ação',
  ]);
}

/// Exceção para dados inválidos
class InvalidDenunciaDataException extends DenunciaException {
  const InvalidDenunciaDataException([
    super.message = 'Dados da denúncia inválidos',
  ]);
}

/// Exceção para erro de rede
class DenunciaNetworkException extends DenunciaException {
  const DenunciaNetworkException([
    super.message = 'Erro de conexão. Verifique sua internet',
  ]);
}

/// Exceção genérica
class UnknownDenunciaException extends DenunciaException {
  const UnknownDenunciaException([super.message = 'Erro desconhecido']);
}

/// Exceção quando a categoria não é encontrada
class CategoriaNotFoundException extends DenunciaException {
  const CategoriaNotFoundException([super.message = 'Categoria não encontrada']);
}
