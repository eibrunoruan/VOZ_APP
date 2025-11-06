import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../autenticacao/presentation/notifiers/auth_notifier.dart';

/// Dialog de confirmação de logout
class LogoutConfirmationDialog extends ConsumerWidget {
  const LogoutConfirmationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const LogoutConfirmationDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      title: Row(
        children: [
          Icon(Icons.logout, color: AppColors.error),
          const SizedBox(width: AppSizes.spacing12),
          const Text(
            'Sair da Conta',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        'Tem certeza que deseja sair da sua conta?',
        style: AppTextStyles.body.copyWith(color: AppColors.grey),
      ),
      actions: [
        // Botão Cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: AppTextStyles.body.copyWith(
              color: AppColors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Botão Sair
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Fecha o dialog
            await ref.read(authNotifierProvider.notifier).logout();
            if (context.mounted) {
              context.go('/'); // Vai para WelcomeScreen
            }
          },
          child: Text(
            'Sair',
            style: AppTextStyles.body.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
