import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

/// Widget para o step de título da denúncia
class TituloStepWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  const TituloStepWidget({
    super.key,
    required this.controller,
    required this.hasError,
    this.errorMessage,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qual o título da sua denúncia?',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Seja breve e direto',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing32),
        TextFormField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: 'Ex: Buraco na rua principal',
            hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primaryRed,
                width: hasError ? 2 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primaryRed,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          style: const TextStyle(fontSize: 16, color: AppColors.white),
          onFieldSubmitted: (_) => onSubmit(),
        ),
        if (hasError && errorMessage != null) ...
        [
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
