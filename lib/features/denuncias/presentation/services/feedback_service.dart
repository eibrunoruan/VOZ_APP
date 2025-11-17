import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_bottom_sheet.dart';

/// Serviço para gerenciar feedback visual (dialogs, snackbars)
class FeedbackService {
  final BuildContext context;

  FeedbackService(this.context);

  /// Mostra dialog de sucesso
  Future<bool?> showSuccessDialog({
    required String title,
    required String message,
  }) async {
    return await ConfirmationBottomSheet.show(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
      confirmText: 'Ver Denúncias',
      cancelText: 'Fechar',
      isDanger: false,
    );
  }

  /// Mostra snackbar de erro
  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        margin: const EdgeInsets.all(AppSizes.spacing16),
      ),
    );
  }

  /// Mostra snackbar de loading
  void showLoadingSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Mostra snackbar de sucesso
  void showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
