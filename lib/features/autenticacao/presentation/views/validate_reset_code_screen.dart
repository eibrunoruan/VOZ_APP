import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/theme/app_theme.dart';

class ValidateResetCodeScreen extends ConsumerStatefulWidget {
  final String email;

  const ValidateResetCodeScreen({super.key, required this.email});

  @override
  ConsumerState<ValidateResetCodeScreen> createState() =>
      _ValidateResetCodeScreenState();
}

class _ValidateResetCodeScreenState
    extends ConsumerState<ValidateResetCodeScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(
    5,
    (index) => FocusNode(),
  );

  bool _isLoading = false;

  // Timer para expiração do código
  int _expirationTimer = 300; // 5 minutos = 300 segundos
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startExpirationTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getCode() {
    return _codeControllers.map((c) => c.text).join();
  }

  bool _isCodeComplete() {
    return _codeControllers.every((controller) => controller.text.isNotEmpty);
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

  void _startExpirationTimer() {
    _timer?.cancel();
    setState(() {
      _expirationTimer = 300; // 5 minutos
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_expirationTimer > 0) {
          _expirationTimer--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _clearCode() {
    for (var controller in _codeControllers) {
      controller.clear();
    }
    _codeFocusNodes[0].requestFocus();
  }

  Future<void> _handleValidateCode() async {
    // Validar código
    if (!_isCodeComplete()) {
      _showErrorDialog('Digite o código completo de 5 dígitos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.validatePasswordResetCode(widget.email, _getCode());

      if (!mounted) return;

      // Código válido! Navega para tela de nova senha
      context.push(
        '/set-new-password',
        extra: {'email': widget.email, 'code': _getCode()},
      );
    } on InvalidVerificationCodeException catch (e) {
      if (mounted) {
        _showErrorDialog(
          e.message.isNotEmpty ? e.message : 'Código inválido ou expirado',
        );
      }
      setState(() {
        _isLoading = false;
      });
      _clearCode();
    } on NetworkException {
      if (mounted) {
        _showErrorDialog('Erro de conexão. Verifique sua internet');
      }
      setState(() {
        _isLoading = false;
      });
    } on UnknownAuthException catch (e) {
      if (mounted) {
        _showErrorDialog(e.message);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro inesperado. Tente novamente');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResendCode() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.requestPasswordReset(widget.email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Novo código enviado para seu email'),
          backgroundColor: Colors.green,
        ),
      );

      _clearCode();
      _startExpirationTimer(); // Reinicia o timer
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro ao reenviar código');
      }
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
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botão Voltar
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.black),
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(height: AppSizes.spacing32),

                // Título
                const Text('Validar Código', style: AppTextStyles.titleMedium),

                const SizedBox(height: AppSizes.spacing8),

                // Subtítulo
                const Text(
                  'Digite o código de 5 dígitos enviado para seu email',
                  style: AppTextStyles.subtitle,
                ),

                const SizedBox(height: AppSizes.spacing40),

                // Campos de código
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    return SizedBox(
                      width: 56,
                      height: 64,
                      child: TextField(
                        controller: _codeControllers[index],
                        focusNode: _codeFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        enabled: !_isLoading,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.greyLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.black,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.black,
                              width: 1,
                            ),
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: AppSizes.spacing16,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 4) {
                            _codeFocusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _codeFocusNodes[index - 1].requestFocus();
                          }

                          // Auto-submit quando completar código
                          if (_isCodeComplete()) {
                            _handleValidateCode();
                          }
                        },
                        onTap: () {
                          _codeControllers[index].selection =
                              TextSelection.fromPosition(
                                TextPosition(
                                  offset: _codeControllers[index].text.length,
                                ),
                              );
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: AppSizes.spacing16),

                // Cronômetro de expiração
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: _expirationTimer > 60
                          ? AppColors.grey
                          : AppColors.primaryRed,
                    ),
                    const SizedBox(width: AppSizes.spacing8),
                    Text(
                      'Expira em ${_formatTime(_expirationTimer)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _expirationTimer > 60
                            ? AppColors.grey
                            : AppColors.primaryRed,
                        fontWeight: _expirationTimer <= 60
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Botões fixados na parte inferior
                Column(
                  children: [
                    // Botão Validar
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleValidateCode,
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
                            : const Text('Validar'),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacing16),

                    // Reenviar código
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não recebeu o código? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _handleResendCode,
                          style: AppButtonStyles.text,
                          child: const Text('Reenviar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
