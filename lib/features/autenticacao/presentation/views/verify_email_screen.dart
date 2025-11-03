import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/theme/app_theme.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  final String? name;

  const VerifyEmailScreen({super.key, required this.email, this.name});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());

  bool _isLoading = false;

  // Timer para reenvio
  int _resendTimer = 60;
  Timer? _resendTimerObj;
  bool _canResend = false;

  // Timer para expiração do código
  int _expirationTimer = 300; // 5 minutos = 300 segundos
  Timer? _expirationTimerObj;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _startExpirationTimer();

    // Auto-focus no primeiro campo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _resendTimerObj?.cancel();
    _expirationTimerObj?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimerObj?.cancel();
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });

    _resendTimerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _startExpirationTimer() {
    _expirationTimerObj?.cancel();
    setState(() {
      _expirationTimer = 300; // 5 minutos
    });

    _expirationTimerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  String _getCode() {
    return _controllers.map((c) => c.text).join();
  }

  bool _isCodeComplete() {
    return _getCode().length == 5;
  }

  Future<void> _handleVerify() async {
    if (!_isCodeComplete()) {
      _showErrorDialog('Digite o código completo');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .verifyEmail(widget.email, _getCode());

      if (mounted) {
        // Sucesso! Navega para login
        context.go('/login');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✓ Email verificado com sucesso! Faça login para continuar.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } on InvalidVerificationCodeException catch (e) {
      if (mounted) {
        _showErrorDialog(e.message);
      }
      setState(() {
        _isLoading = false;
      });

      // Limpa os campos
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } on NetworkException catch (e) {
      if (mounted) {
        _showErrorDialog(e.message);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro ao verificar email: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResendCode() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .resendVerificationCode(widget.email);

      _startResendTimer();
      _startExpirationTimer(); // Reinicia o timer de expiração

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código reenviado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro ao reenviar código');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                  onPressed: () => context.go('/'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(height: AppSizes.spacing32),

                // Título
                const Text('Verificar Email', style: AppTextStyles.titleMedium),

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
                  children: List.generate(
                    5,
                    (index) => SizedBox(
                      width: 56,
                      height: 64,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
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
                            // Avança para próximo campo
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            // Volta para campo anterior ao apagar
                            _focusNodes[index - 1].requestFocus();
                          }

                          // Auto-submit quando completo
                          if (_isCodeComplete()) {
                            _handleVerify();
                          }
                        },
                      ),
                    ),
                  ),
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
                    // Botão Verificar
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleVerify,
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
                            : const Text('Verificar'),
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
                        if (_canResend)
                          TextButton(
                            onPressed: _isLoading ? null : _handleResendCode,
                            style: AppButtonStyles.text,
                            child: const Text('Reenviar'),
                          )
                        else
                          Text(
                            'Reenviar em ${_resendTimer}s',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.grey,
                            ),
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
