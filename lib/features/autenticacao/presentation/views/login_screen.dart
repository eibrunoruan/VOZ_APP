import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../data/repositories/auth_repository.dart';
import '../notifiers/auth_notifier.dart';
import '../widgets/widgets.dart';

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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) =>
      (value == null || value.isEmpty) ? 'Nome de usuário é obrigatório' : null;

  String? _validatePassword(String? value) =>
      (value == null || value.isEmpty) ? 'Senha é obrigatória' : null;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authRepositoryProvider)
          .login(_usernameController.text.trim(), _passwordController.text);

      if (!mounted) return;
      ref.read(authNotifierProvider.notifier).login();
      context.go('/home');
    } on EmailNotVerifiedException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthErrorDialog.show(
        context,
        'Email não verificado. Verifique seu email antes de fazer login.',
      );
    } on InvalidCredentialsException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthErrorDialog.show(
        context,
        e.message.isNotEmpty ? e.message : 'Usuário ou senha incorretos',
      );
    } on NetworkException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthErrorDialog.show(context, 'Erro de conexão. Verifique sua internet');
    } on UnknownAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthErrorDialog.show(context, e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthErrorDialog.show(context, 'Erro inesperado. Tente novamente');
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
                    // Header
                    AuthHeader(
                      title: 'Login',
                      subtitle: 'Entre com suas credenciais',
                      onBack: () => context.go('/'),
                    ),

                    const SizedBox(height: AppSizes.spacing40),

                    // Campo Nome de Usuário
                    AuthFormField(
                      controller: _usernameController,
                      label: 'Nome de Usuário',
                      hintText: 'Digite seu nome de usuário',
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                      validator: _validateUsername,
                    ),

                    const SizedBox(height: AppSizes.spacing20),

                    // Campo Senha
                    AuthPasswordField(
                      controller: _passwordController,
                      label: 'Senha',
                      hintText: 'Digite sua senha',
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
                    AuthLoadingButton(
                      onPressed: _handleLogin,
                      text: 'Entrar',
                      isLoading: _isLoading,
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
