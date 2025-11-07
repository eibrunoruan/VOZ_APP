
abstract class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class EmailNotVerifiedException extends AuthException {
  const EmailNotVerifiedException([String? message])
    : super(
        message ??
            'Email não verificado. Verifique seu email antes de fazer login.',
      );
}

class InvalidVerificationCodeException extends AuthException {
  const InvalidVerificationCodeException([String? message])
    : super(message ?? 'Código de verificação inválido ou expirado.');
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([String? message])
    : super(message ?? 'Usuário ou senha incorretos.');
}

class EmailAlreadyExistsException extends AuthException {
  const EmailAlreadyExistsException([String? message])
    : super(message ?? 'Este email já está em uso.');
}

class UsernameAlreadyExistsException extends AuthException {
  const UsernameAlreadyExistsException([String? message])
    : super(message ?? 'Este nome de usuário já está em uso.');
}

class NetworkException extends AuthException {
  const NetworkException([String? message])
    : super(message ?? 'Erro de conexão. Verifique sua internet.');
}

class UnknownAuthException extends AuthException {
  const UnknownAuthException([String? message])
    : super(message ?? 'Ocorreu um erro inesperado.');
}
