import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_bottom_sheet.dart';
import '../notifiers/auth_notifier.dart';

class GuestSettingsScreen extends ConsumerStatefulWidget {
  const GuestSettingsScreen({super.key});

  @override
  ConsumerState<GuestSettingsScreen> createState() =>
      _GuestSettingsScreenState();
}

class _GuestSettingsScreenState extends ConsumerState<GuestSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final currentNickname = ref.read(authNotifierProvider).guestNickname ?? '';
    _nicknameController = TextEditingController(text: currentNickname);
  }

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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 28),
            const SizedBox(width: AppSizes.spacing12),
            const Text(
              'Erro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navbarText,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: AppColors.navbarText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppTextStyles.button.copyWith(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final nickname = _nicknameController.text.trim();
      await ref
          .read(authNotifierProvider.notifier)
          .updateGuestNickname(nickname);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apelido atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      _showErrorDialog('Erro ao atualizar apelido: $e');
    }
  }

  Future<void> _showCreateAccountModal() async {
    final confirm = await ConfirmationBottomSheet.show(
      context: context,
      title: 'Criar Conta Completa',
      message:
          'Tenha acesso a recursos exclusivos como editar denúncias, '
          'acompanhar status, receber notificações e perfil personalizado.',
      icon: Icons.person_add,
      iconColor: AppColors.primaryRed,
      confirmText: 'Criar Conta',
      cancelText: 'Agora Não',
      isDanger: false,
    );

    if (confirm == true && mounted) {
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final displayName = authState.guestNickname ?? 'Visitante';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.navbarText,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: AppSizes.spacing24),

                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 56,
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: AppSizes.spacing24),

                Text(
                  'Editar Apelido',
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 28),
                ),

                const SizedBox(height: AppSizes.spacing8),

                Text(
                  'Seu apelido atual: $displayName',
                  style: AppTextStyles.subtitle.copyWith(color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSizes.spacing40),

                TextFormField(
                  controller: _nicknameController,
                  style: const TextStyle(fontSize: 16, color: AppColors.white),
                  decoration: InputDecoration(
                    labelText: 'Novo Apelido',
                    labelStyle: const TextStyle(color: AppColors.navbarText),
                    hintText: 'Digite seu novo apelido',
                    hintStyle: TextStyle(
                      color: AppColors.grey.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.primaryRed,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primaryRed,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primaryRed,
                        width: 1.5,
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
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    helperText: '3 a 20 caracteres',
                    helperStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isLoading,
                  validator: _validateNickname,
                ),

                const SizedBox(height: AppSizes.spacing32),

                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleUpdate,
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
                        : Text(
                            'Salvar Alterações',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),

                const SizedBox(height: AppSizes.spacing16),

                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.grey, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacing12,
                      ),
                      child: Text(
                        'ou',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColors.grey, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.spacing16),

                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: OutlinedButton(
                    onPressed: () => _showCreateAccountModal(),
                    style: AppButtonStyles.secondary,
                    child: Text(
                      'Criar Conta Completa',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.spacing32),

                Container(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    border: Border.all(color: AppColors.primaryRed, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primaryRed,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.spacing12),
                      Expanded(
                        child: Text(
                          'Seus dados estão salvos de forma segura no dispositivo.',
                          style: AppTextStyles.body.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spacing24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
