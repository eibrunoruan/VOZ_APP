import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/theme/app_theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Digite um email válido';
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

  Future<void> _handleRequestReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.requestPasswordReset(_emailController.text.trim());

      if (!mounted) return;

      // Navegar para tela de validar código
      context.push(
        '/validate-reset-code',
        extra: {'email': _emailController.text.trim()},
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
        resizeToAvoidBottomInset: false,
        body: SafeArea(
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
                      onPressed: () => context.pop(),
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
                  const Text(
                    'Esqueci minha senha',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  const Text(
                    'Digite seu email para receber o código de recuperação',
                    style: AppTextStyles.subtitle,
                  ),

                  const SizedBox(height: AppSizes.spacing40),

                  // Label Email
                  const Text('Email', style: AppTextStyles.label),
                  const SizedBox(height: AppSizes.spacing8),

                  // Campo Email
                  TextFormField(
                    controller: _emailController,
                    decoration: AppInputDecoration.standard(
                      hintText: 'Digite seu email cadastrado',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    validator: _validateEmail,
                    onFieldSubmitted: (_) => _handleRequestReset(),
                  ),

                  const Spacer(),

                  // Botões fixados na parte inferior
                  Column(
                    children: [
                      // Botão Seguir
                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRequestReset,
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
                              : const Text('Seguir'),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacing16),

                      // Botão Voltar
                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeight,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => context.pop(),
                          style: AppButtonStyles.secondary,
                          child: const Text('Voltar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
