import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modal bottom sheet para confirmações importantes
/// Ocupa 50% da tela com blur no background
class ConfirmationBottomSheet {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    Color iconColor = AppColors.error,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDanger = true,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.spacing24),
              topRight: Radius.circular(AppSizes.spacing24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: AppSizes.spacing12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: AppSizes.spacing32),

                // Ícone
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 40, color: iconColor),
                ),

                const SizedBox(height: AppSizes.spacing24),

                // Título
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing24,
                  ),
                  child: Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 24,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppSizes.spacing12),

                // Mensagem
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing32,
                  ),
                  child: Text(
                    message,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppSizes.spacing32),

                // Botões
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.spacing24,
                    AppSizes.spacing24,
                    AppSizes.spacing24,
                    AppSizes.spacing24 +
                        MediaQuery.of(context).viewPadding.bottom,
                  ),
                  child: Column(
                    children: [
                      // Botão de ação principal (danger ou primary)
                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeight,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDanger
                                ? AppColors.error
                                : AppColors.primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.borderRadius,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            confirmText,
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacing12),

                      // Botão cancelar
                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeight,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDanger
                                  ? AppColors.grey
                                  : AppColors.primaryRed,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.borderRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            cancelText,
                            style: AppTextStyles.button.copyWith(
                              color: isDanger
                                  ? AppColors.grey
                                  : AppColors.primaryRed,
                            ),
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
