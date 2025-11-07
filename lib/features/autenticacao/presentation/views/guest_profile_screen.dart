import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/auth_notifier.dart';
import '../../../../core/theme/app_theme.dart';

class GuestProfileScreen extends ConsumerStatefulWidget {
  const GuestProfileScreen({super.key});

  @override
  ConsumerState<GuestProfileScreen> createState() => _GuestProfileScreenState();
}

class _GuestProfileScreenState extends ConsumerState<GuestProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  String? _validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Apelido é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Apelido deve ter pelo menos 3 caracteres';
    }
    if (value.trim().length > 20) {
      return 'Apelido deve ter no máximo 20 caracteres';
    }

    if (!RegExp(r'^[a-zA-Z0-9\s._-]+$').hasMatch(value)) {
      return 'Apelido contém caracteres inválidos';
    }
    return null;
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final nickname = _nicknameController.text.trim();

      await ref.read(authNotifierProvider.notifier).enterAsGuest(nickname);

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar apelido: $e'),
          backgroundColor: Colors.red,
        ),
      );

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
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.navbarText,
                    ),
                    onPressed: () => context.go('/'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  const SizedBox(height: AppSizes.spacing32),

                  const Text(
                    'Modo Visitante',
                    style: AppTextStyles.titleMedium,
                  ),

                  const SizedBox(height: AppSizes.spacing8),

                  const Text(
                    'Escolha um apelido para identificar suas denúncias e comentários',
                    style: AppTextStyles.subtitle,
                  ),

                  const SizedBox(height: AppSizes.spacing40),

                  const Text('Apelido', style: AppTextStyles.label),
                  const SizedBox(height: AppSizes.spacing8),

                  TextFormField(
                    controller: _nicknameController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                    decoration: AppInputDecoration.standard(
                      hintText: 'Ex: Cidadão Anônimo',
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    validator: _validateNickname,
                    onFieldSubmitted: (_) => _handleContinue(),
                    autofocus: true,
                  ),

                  const Spacer(),

                  Column(
                    children: [

                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleContinue,
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
                              : const Text('Continuar'),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacing16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Quer acesso completo? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.navbarText,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => context.go('/register'),
                            style: AppButtonStyles.text,
                            child: const Text('Criar conta'),
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
      ),
    );
  }
}
