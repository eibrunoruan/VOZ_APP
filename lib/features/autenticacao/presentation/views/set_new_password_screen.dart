import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/exceptions/auth_exceptions.dart';

class SetNewPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const SetNewPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  ConsumerState<SetNewPasswordScreen> createState() =>
      _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends ConsumerState<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Senha deve conter pelo menos um número';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }
    if (value != _passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  Future<void> _handleSetPassword() async {
    setState(() {
      _errorMessage = null;
    });

    // Validar formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.confirmPasswordReset(
        widget.email,
        widget.code,
        _passwordController.text,
      );

      if (!mounted) return;

      // Mostrar sucesso e voltar para login
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: AppSizes.spacing12),
              const Text(
                'Senha Redefinida!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          content: const Text(
            'Sua senha foi alterada com sucesso. Faça login com sua nova senha.',
            style: TextStyle(fontSize: 16, color: AppColors.black),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: AppButtonStyles.primary,
              child: const Text(
                'Fazer Login',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      );
    } on InvalidVerificationCodeException catch (e) {
      setState(() {
        _errorMessage = e.message.isNotEmpty
            ? e.message
            : 'Código inválido ou expirado. Tente novamente.';
        _isLoading = false;
      });
    } on NetworkException {
      setState(() {
        _errorMessage = 'Erro de conexão. Verifique sua internet';
        _isLoading = false;
      });
    } on UnknownAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado. Tente novamente';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header com botão voltar
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.black,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: AppSizes.spacing24),

                // Ícone
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 56,
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: AppSizes.spacing24),

                // Título
                Text(
                  'Nova Senha',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 28,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: AppSizes.spacing8),

                // Subtítulo
                Text(
                  widget.email,
                  style: AppTextStyles.subtitle.copyWith(color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSizes.spacing40),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.spacing16),
                    margin: const EdgeInsets.only(bottom: AppSizes.spacing24),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: AppSizes.spacing12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Nova Senha
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Nova Senha',
                    hintText: 'Digite sua nova senha',
                    prefixIcon: const Icon(Icons.lock, color: AppColors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(color: AppColors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(color: AppColors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primaryRed,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    helperText: 'Mínimo 8 caracteres, letra maiúscula e número',
                    helperStyle: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: _validatePassword,
                  style: AppTextStyles.body,
                  onChanged: (_) {
                    if (_confirmPasswordController.text.isNotEmpty) {
                      _formKey.currentState!.validate();
                    }
                  },
                ),

                const SizedBox(height: AppSizes.spacing16),

                // Confirmar Senha
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    hintText: 'Digite sua senha novamente',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(color: AppColors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(color: AppColors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primaryRed,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  validator: _validateConfirmPassword,
                  style: AppTextStyles.body,
                  onFieldSubmitted: (_) => _handleSetPassword(),
                ),

                const SizedBox(height: AppSizes.spacing32),

                // Botão Redefinir
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSetPassword,
                    style: AppButtonStyles.primary,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text('Redefinir Senha', style: AppTextStyles.button),
                  ),
                ),

                const SizedBox(height: AppSizes.spacing24),

                // Info box
                Container(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.spacing12),
                      Expanded(
                        child: Text(
                          'Código validado! Defina uma senha forte para sua conta.',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 13,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
