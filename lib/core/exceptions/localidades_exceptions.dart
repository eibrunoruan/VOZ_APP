/// Exceção base para erros relacionados a localidades
class LocalidadesException implements Exception {
  final String message;

  LocalidadesException(this.message);

  @override
  String toString() => 'LocalidadesException: $message';
}

/// Exceção quando um estado não é encontrado
class EstadoNotFoundException extends LocalidadesException {
  EstadoNotFoundException(super.message);

  @override
  String toString() => 'EstadoNotFoundException: $message';
}

/// Exceção quando uma cidade não é encontrada
class CidadeNotFoundException extends LocalidadesException {
  CidadeNotFoundException(super.message);

  @override
  String toString() => 'CidadeNotFoundException: $message';
}

/// Exceção quando não é possível determinar localização por coordenadas
class LocalizacaoNaoEncontradaException extends LocalidadesException {
  LocalizacaoNaoEncontradaException(super.message);

  @override
  String toString() => 'LocalizacaoNaoEncontradaException: $message';
}

/// Exceção quando há erro ao carregar dados de localidades
class LocalidadesLoadException extends LocalidadesException {
  LocalidadesLoadException(super.message);

  @override
  String toString() => 'LocalidadesLoadException: $message';
}
