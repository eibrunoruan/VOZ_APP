import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../notifiers/auth_notifier.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome de usuário é obrigatório';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    return null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.primaryRed, size: 28),
            const SizedBox(width: AppSizes.spacing12),
            const Text(
              'Erro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: AppButtonStyles.text,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);

      await repository.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // IMPORTANTE: Atualizar o estado de autenticação
      ref.read(authNotifierProvider.notifier).login();

      // Navigate to home screen after successful login
      context.go('/home');
    } on EmailNotVerifiedException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog(
        'Email não verificado. Verifique seu email antes de fazer login.',
      );
    } on InvalidCredentialsException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog(
        e.message.isNotEmpty ? e.message : 'Usuário ou senha incorretos',
      );
    } on NetworkException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog('Erro de conexão. Verifique sua internet');
    } on UnknownAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog('Erro inesperado. Tente novamente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacing32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Botão voltar
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => context.go('/'),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: AppSizes.iconSizeButton,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacing40),

                    // Título
                    const Text('Login', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSizes.spacing8),
                    const Text(
                      'Entre com suas credenciais',
                      style: AppTextStyles.subtitle,
                    ),

                    const SizedBox(height: AppSizes.spacing40),

                    // Label Nome de Usuário
                    const Text('Nome de Usuário', style: AppTextStyles.label),
                    const SizedBox(height: AppSizes.spacing8),

                    // Campo Nome de Usuário
                    TextFormField(
                      controller: _usernameController,
                      decoration: AppInputDecoration.standard(
                        hintText: 'Digite seu nome de usuário',
                      ),
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                      validator: _validateUsername,
                    ),
                    const SizedBox(height: AppSizes.spacing20),

                    // Label Senha
                    const Text('Senha', style: AppTextStyles.label),
                    const SizedBox(height: AppSizes.spacing8),

                    // Campo Senha
                    TextFormField(
                      controller: _passwordController,
                      decoration: AppInputDecoration.standard(
                        hintText: 'Digite sua senha',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !_isLoading,
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),

                    // Esqueceu a senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => context.push('/forgot-password'),
                        style: AppButtonStyles.text,
                        child: const Text('Esqueceu sua senha?'),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacing8),

                    // Botão Entrar
                    SizedBox(
                      height: AppSizes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: AppButtonStyles.primary.copyWith(
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.disabled)
                                ? AppColors.primaryRed.withOpacity(0.6)
                                : AppColors.primaryRed,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacing24),

                    // Link para cadastro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não tem uma conta? ',
                          style: TextStyle(color: AppColors.grey),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => context.go('/register'),
                          style: AppButtonStyles.text.copyWith(
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.zero,
                            ),
                            minimumSize: const WidgetStatePropertyAll(
                              Size.zero,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Cadastre-se'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
