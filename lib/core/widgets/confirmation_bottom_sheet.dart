import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';


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
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.spacing24),
              topRight: Radius.circular(AppSizes.spacing24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

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

                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 40, color: AppColors.primaryRed),
                ),

                const SizedBox(height: AppSizes.spacing24),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing24,
                  ),
                  child: Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppSizes.spacing12),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing32,
                  ),
                  child: Text(
                    message,
                    style: AppTextStyles.body.copyWith(height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppSizes.spacing32),

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

                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeight,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryRed,
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
                              color: AppColors.primaryRed,
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
