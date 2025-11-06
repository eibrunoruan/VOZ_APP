class RegisterValidators {
  static String? validateUsername(String? value) =>
      (value == null || value.isEmpty)
      ? 'Nome de usuário é obrigatório'
      : value.length < 3
      ? 'Nome de usuário deve ter pelo menos 3 caracteres'
      : !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)
      ? 'Use apenas letras, números e underscore'
      : null;

  static String? validateEmail(String? value) =>
      (value == null || value.isEmpty)
      ? 'Email é obrigatório'
      : !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)
      ? 'Digite um email válido'
      : null;

  static String? validateFirstName(String? value) =>
      (value == null || value.isEmpty)
      ? 'Nome é obrigatório'
      : value.length < 2
      ? 'Nome deve ter pelo menos 2 caracteres'
      : null;

  static String? validatePassword(String? value) =>
      (value == null || value.isEmpty)
      ? 'Senha é obrigatória'
      : value.length < 8
      ? 'Senha deve ter pelo menos 8 caracteres'
      : !RegExp(r'[A-Z]').hasMatch(value)
      ? 'Senha deve conter pelo menos uma letra maiúscula'
      : !RegExp(r'[a-z]').hasMatch(value)
      ? 'Senha deve conter pelo menos uma letra minúscula'
      : !RegExp(r'[0-9]').hasMatch(value)
      ? 'Senha deve conter pelo menos um número'
      : null;

  static String? validateConfirmPassword(String? value, String password) =>
      (value == null || value.isEmpty)
      ? 'Confirme sua senha'
      : value != password
      ? 'As senhas não coincidem'
      : null;
}
